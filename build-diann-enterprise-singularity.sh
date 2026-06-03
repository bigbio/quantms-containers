#!/usr/bin/env bash
# Build the DIA-NN Enterprise Docker image from a *local* zip + license
# file, then convert it to a Singularity/Apptainer image using the
# Nextflow cache naming convention used by the quantmsdiann pipeline:
#
#     ghcr.io-bigbio-diann-enterprise-<version>.img
#
# Drop the resulting `.img` into NXF_SINGULARITY_CACHEDIR.
#
# Usage:
#   ./build-diann-enterprise-singularity.sh                # build 2.5.1 (default)
#   ./build-diann-enterprise-singularity.sh 2.5.1          # explicit
#   OUTDIR=/data/sif ./build-diann-enterprise-singularity.sh
#   ENTERPRISE_SRC=/path/with/zip-and-license ./build-diann-enterprise-singularity.sh
#   SKIP_DOCKER_BUILD=1 ./build-diann-enterprise-singularity.sh  # reuse local image
#
# Environment variables:
#   OUTDIR              Directory for .img files (default: ./singularity-cache)
#   ENTERPRISE_SRC      Directory holding DIA-NN-<ver>-Enterprise-Linux.zip
#                       and diann-license-key.txt (required; no default)
#   SKIP_DOCKER_BUILD   If 1, skip "docker build" and reuse existing tag
#   FORCE               If 1, rebuild even if the .img already exists
#   KEEP_STAGED         If 1, leave the staged zip + license in the build
#                       context after the build instead of removing them
#
# Unlike build-diann-singularity.sh, this script does not pull the binary
# from a public URL — the enterprise distribution is not redistributable.
# Neither the zip nor the license is committed to the repository; both are
# .gitignored inside the build context.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTDIR="${OUTDIR:-${REPO_ROOT}/singularity-cache}"
ENTERPRISE_SRC="${ENTERPRISE_SRC:-}"
SKIP_DOCKER_BUILD="${SKIP_DOCKER_BUILD:-0}"
FORCE="${FORCE:-0}"
KEEP_STAGED="${KEEP_STAGED:-0}"

if [[ -z "${ENTERPRISE_SRC}" ]]; then
    echo "ERROR: ENTERPRISE_SRC is not set. Point it at the directory that holds" >&2
    echo "       DIA-NN-<ver>-Enterprise-Linux.zip and diann-license-key.txt, e.g.:" >&2
    echo "       ENTERPRISE_SRC=/path/to/enterprise $0" >&2
    exit 1
fi

ALL_VERSIONS=(2.5.1)

if [[ $# -gt 0 ]]; then
    VERSIONS=("$@")
else
    VERSIONS=("${ALL_VERSIONS[@]}")
fi

if command -v singularity >/dev/null 2>&1; then
    SIF_BIN="singularity"
elif command -v apptainer >/dev/null 2>&1; then
    SIF_BIN="apptainer"
else
    echo "ERROR: neither singularity nor apptainer is installed." >&2
    exit 1
fi

if ! command -v docker >/dev/null 2>&1; then
    echo "ERROR: docker is required to build the source images." >&2
    exit 1
fi

mkdir -p "$OUTDIR"

clean_sif_cache() {
    if [[ "${SKIP_CACHE_CLEAN:-0}" == "1" ]]; then
        return
    fi
    echo "  [cache clean] $SIF_BIN cache clean --force"
    $SIF_BIN cache clean --force >/dev/null 2>&1 || \
        $SIF_BIN cache clean --all --force >/dev/null 2>&1 || true
}

# Stage zip + license into the build context. Prefers a hardlink (same
# filesystem) to avoid duplicating 360 MB, falls back to cp otherwise.
stage_artifact() {
    local src="$1"
    local dst="$2"

    if [[ ! -f "$src" ]]; then
        echo "ERROR: required file not found: $src" >&2
        echo "       Set ENTERPRISE_SRC to the directory that contains it." >&2
        exit 1
    fi

    if [[ -e "$dst" ]]; then
        rm -f "$dst"
    fi

    if ln "$src" "$dst" 2>/dev/null; then
        :
    else
        cp "$src" "$dst"
    fi
}

unstage_artifacts() {
    local context="$1"
    if [[ "$KEEP_STAGED" == "1" ]]; then
        return
    fi
    rm -f "${context}/DIA-NN-"*"-Enterprise-Linux.zip" \
          "${context}/diann-license-key.txt"
}

echo "Output directory : $OUTDIR"
echo "Enterprise src   : $ENTERPRISE_SRC"
echo "Singularity tool : $SIF_BIN ($($SIF_BIN --version))"
echo "Versions to build: ${VERSIONS[*]}"
echo

clean_sif_cache

for version in "${VERSIONS[@]}"; do
    context="${REPO_ROOT}/diann-enterprise-${version}"
    docker_tag="ghcr.io/bigbio/diann-enterprise:${version}"
    sif_name="ghcr.io-bigbio-diann-enterprise-${version}.img"
    sif_path="${OUTDIR}/${sif_name}"
    zip_name="DIA-NN-${version}-Enterprise-Linux.zip"
    src_zip="${ENTERPRISE_SRC}/${zip_name}"
    src_license="${ENTERPRISE_SRC}/diann-license-key.txt"

    echo "=============================================================="
    echo "DIA-NN Enterprise ${version}"
    echo "  context : ${context}"
    echo "  docker  : ${docker_tag}"
    echo "  sif     : ${sif_path}"
    echo "=============================================================="

    if [[ ! -d "$context" ]]; then
        echo "  [skip] ${context} does not exist" >&2
        continue
    fi

    if [[ -f "$sif_path" && "$FORCE" != "1" ]]; then
        echo "  [skip] ${sif_path} already exists (set FORCE=1 to rebuild)"
        continue
    fi

    if [[ "$SKIP_DOCKER_BUILD" != "1" ]]; then
        echo "  [stage] ${src_zip} -> ${context}/${zip_name}"
        stage_artifact "$src_zip" "${context}/${zip_name}"
        echo "  [stage] ${src_license} -> ${context}/diann-license-key.txt"
        stage_artifact "$src_license" "${context}/diann-license-key.txt"

        trap 'unstage_artifacts "'"$context"'"' EXIT

        echo "  [docker build] ${docker_tag}"
        DOCKER_BUILDKIT=1 docker build -t "$docker_tag" "$context"

        unstage_artifacts "$context"
        trap - EXIT
    else
        echo "  [docker build] skipped (SKIP_DOCKER_BUILD=1)"
        if ! docker image inspect "$docker_tag" >/dev/null 2>&1; then
            echo "  ERROR: ${docker_tag} not found locally and SKIP_DOCKER_BUILD=1" >&2
            exit 1
        fi
    fi

    echo "  [singularity build] ${sif_path}"
    tmp_sif="${sif_path}.tmp"
    rm -f "$tmp_sif"
    $SIF_BIN build --force "$tmp_sif" "docker-daemon://${docker_tag}"
    mv "$tmp_sif" "$sif_path"

    echo "  [done] $(ls -lh "$sif_path" | awk '{print $5, $9}')"

    clean_sif_cache
    echo
done

echo "All requested DIA-NN Enterprise Singularity images are in: $OUTDIR"
ls -lh "$OUTDIR"/ghcr.io-bigbio-diann-enterprise-*.img 2>/dev/null || true
