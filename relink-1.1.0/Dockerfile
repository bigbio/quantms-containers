FROM python:3.12-slim AS build

# Metadata
LABEL base_image="python:3.12-slim"
LABEL version="1.1.0"
LABEL software="relink"
LABEL software.version="1.1.0"
LABEL about.summary="Container for relink pipeline: xiSEARCH 1.8.11, xiFDR 2.3.10, Scout 2.1.0, xi-mzidentml-converter, and dependencies for crosslinking mass spectrometry analysis"
LABEL about.home="https://github.com/bigbio/relink"
LABEL about.documentation="https://github.com/bigbio/relink"
LABEL about.license="Apache-2.0"
LABEL about.tags="Proteomics,Crosslinking,Mass Spectrometry"
LABEL maintainer="Yasset Perez-Riverol <ypriverol@gmail.com>"

ENV DEBIAN_FRONTEND=noninteractive

# Build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
	wget \
	unzip \
	ca-certificates \
	&& rm -rf /var/lib/apt/lists/* && \
	wget https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb \
	-O packages-microsoft-prod.deb

# Install xiSEARCH 1.8.11 and xiFDR
RUN mkdir -p /opt/xisearch && wget -q \
    https://www.rappsilberlab.org/wp-content/uploads/2025/12/xiSEARCH_1.8.11.zip \
    -O /tmp/xiSEARCH.zip && \
    unzip /tmp/xiSEARCH.zip -d /opt/xisearch && \
    rm /tmp/xiSEARCH.zip && \
    cp /opt/xisearch/xiSEARCH_1.8.11/xiSEARCH.jar /opt/xisearch/xiSEARCH.jar && \
    cp /opt/xisearch/xiSEARCH_1.8.11/xiFDR-2.3.10.jar /opt/xisearch/xiFDR.jar

# Install Scout 2.1.0
RUN mkdir -p /opt/scout && wget -q \
	https://github.com/diogobor/Scout/releases/download/2.1.0/Scout_2_1_0_Linux64.zip \
	-O /tmp/Scout.zip && \
	unzip /tmp/Scout.zip -d /opt/scout && \
	rm /tmp/Scout.zip && \
	scout_dir="$(find /opt/scout -mindepth 1 -maxdepth 1 -type d ! -name '__MACOSX' | head -n 1)" && \
	cp -a "${scout_dir}/." /opt/scout/ && \
	rm -rf "${scout_dir}" /opt/scout/__MACOSX && \
	test -s /opt/scout/run_scout.sh && \
	sed -i 's|^dotnet Scout_Unix.dll|export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-/tmp/csmsl-config-$(id -u)}"; mkdir -p "$XDG_CONFIG_HOME"; dotnet /opt/scout/Scout_Unix.dll|' /opt/scout/run_scout.sh && \
	chmod +x /opt/scout/run_scout.sh && \
	chmod -R a+rX /opt/scout

FROM python:3.12-slim AS runtime

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

# Copy necessary package for dotnet-runtime from build stage
COPY --from=build packages-microsoft-prod.deb /tmp/packages-microsoft-prod.deb

# Install Java runtime (required for xiSEARCH and xiFDR) Dotnet runtime, MPFR, and GMP (required for Scout)
RUN dpkg -i /tmp/packages-microsoft-prod.deb && \
	rm /tmp/packages-microsoft-prod.deb && \
	apt-get --allow-insecure-repositories --allow-unauthenticated update && apt-get install --allow-unauthenticated -y --no-install-recommends \
	dotnet-runtime-9.0 && \
	apt-get install -y --no-install-recommends \
	libmpfr6 \
	libgmp10 \
	openjdk-21-jre \
    && rm -rf /var/lib/apt/lists/*

# Copy xiSEARCH 1.8.11 and xiFDR from build stage
COPY --from=build /opt/xisearch /opt/xisearch

# Copy Scout 2.1.0 from build stage. The upstream run_scout.sh has already
# been patched (see the build stage above) to (a) use an absolute dll path
# and (b) export XDG_CONFIG_HOME to a writable /tmp dir before invoking
# dotnet. The latter prevents CSMSL's Protease static initializer ("Unable
# to prepare the database" / TypeInitializationException) from crashing
# when the container is run with `-u $(id -u):$(id -g)` (as Nextflow does)
# and HOME (still /root from the image) is not writable for that UID.
# The build stage also applies `chmod -R a+rX /opt/scout`: the upstream
# archive ships as 0700/0600, which makes the script and dlls unreadable
# for non-root UIDs in the Nextflow scenario above (bash would otherwise
# fail with "Permission denied" before even reaching dotnet).
COPY --from=build /opt/scout /opt/scout

# Install per-tool wrappers on PATH: scout, xisearch, xifdr.
# (`process_dataset` is already on PATH via the xi-mzidentml-converter pip package.)
# The Java wrappers accept `--java-options "..."` (GATK convention) for passing
# JVM flags such as -Xmx and -XX:..., which is robust across Nextflow / Singularity
# quoting layers.
COPY scout xisearch xifdr /usr/local/bin/
RUN chmod +x /usr/local/bin/scout /usr/local/bin/xisearch /usr/local/bin/xifdr

# Set necessary env for scout
ENV MPFR_PATH=/usr/lib/x86_64-linux-gnu GMP_PATH=/usr/lib/x86_64-linux-gnu

# Install Python packages for mass recalibration.
# xi-mzidentml-converter exposes the `process_dataset` CLI.
RUN pip install --no-cache-dir \
    pyopenms \
    xi-mzidentml-converter \
    polars==1.35.1 \
    polars-runtime-32==1.35.1 \
    matplotlib==3.10.7 \
    seaborn==0.13.2 \
    numpy==2.3.4 \
    pandas==2.3.3 \
    contourpy==1.3.3 \
    cycler==0.12.1 \
    fonttools==4.60.1 \
    kiwisolver==1.4.9 \
    packaging==25.0 \
    pillow==12.0.0 \
    pyparsing==3.2.5 \
    python-dateutil==2.9.0.post0 \
    pytz==2025.2 \
    psutil==7.1.3 \
    pyarrow==22.0.0 \
    six==1.17.0 \
    tzdata==2025.2

# Set working directory
WORKDIR /data/

# Verify installation
RUN set -e; \
    for cmd in scout xisearch xifdr process_dataset; do command -v "$cmd" >/dev/null || { echo "$cmd not on PATH"; exit 1; }; done; \
    test -s /opt/scout/Scout_Unix.dll; \
    test -x /opt/scout/run_scout.sh; \
    grep -q 'XDG_CONFIG_HOME' /opt/scout/run_scout.sh || { echo "run_scout.sh missing XDG_CONFIG_HOME patch"; exit 1; }; \
    dotnet --info >/dev/null; \
    test -e /usr/lib/x86_64-linux-gnu/libgmp.so.10; \
    test -e /usr/lib/x86_64-linux-gnu/libmpfr.so.6; \
    ls -lh /opt/xisearch/*.jar /opt/scout/Scout_Unix.dll /opt/scout/run_scout.sh; \
    xisearch --help >/dev/null && echo "xiSEARCH OK"; \
    xifdr --help >/dev/null && echo "xiFDR OK"; \
    process_dataset --help >/dev/null && echo "process_dataset OK"; \
    xisearch --java-options "-Xmx128m -Dxisearch.test=1" --help >/dev/null && echo "xiSEARCH --java-options OK"; \
    xifdr --java-options "-Xmx128m" --help >/dev/null && echo "xiFDR --java-options OK"; \
    out="$(timeout 30s scout 2>&1 || true)"; \
    echo "$out" | head -n 30; \
    echo "$out" | grep -q "INFO: Python:" || { echo "Scout wrapper did not detect Python"; exit 1; }; \
    echo "$out" | grep -qE "It was not possible to find any compatible framework version|Could not execute because the specified command or file was not found|A fatal error was encountered|trying to start process '-" && { echo "Scout startup error"; exit 1; } || true; \
    echo "Scout OK (root)"; \
    # Re-run as a non-root UID with HOME=/root not writable, to reproduce the
    # Nextflow `docker run -u $(id -u):$(id -g)` environment. The smoke test
    # must exercise `-search` so CSMSL's Protease static initializer actually
    # runs — without args, Scout exits before touching CSMSL and the bug from
    # PR #15 hid. The XDG_CONFIG_HOME path is UID-namespaced
    # (`/tmp/csmsl-config-$(id -u)`) so the runtime mkdir always succeeds and
    # is owned by the caller; a non-namespaced path created at build time by
    # root would be 0755 and fail with EACCES under the Nextflow UID.
    useradd -M -u 12345 relinkverify; \
    mkdir -p /tmp/scout-verify; \
    chmod 777 /tmp/scout-verify; \
    printf '{}\n' > /tmp/scout-verify/filter_params.json; \
    printf '{"FastaFile":"dummy.fasta","RawPath":".","OutputFolder":"."}\n' > /tmp/scout-verify/search_params.json; \
    printf '>sp|P00001|TEST_PROTEIN\nMKKKKKKKKKKKKKKKKKK\n' > /tmp/scout-verify/dummy.fasta; \
    out2="$(su -s /bin/bash -c 'cd /tmp/scout-verify && HOME=/root timeout 60s /opt/scout/run_scout.sh -search -no_filter search_params.json filter_params.json 2>&1' relinkverify || true)"; \
    echo "$out2" | tail -n 40; \
    echo "$out2" | grep -q "INFO: Python:" || { echo "Scout wrapper failed under non-root UID"; exit 1; }; \
    echo "$out2" | grep -q "INFO: Preparing database" || { echo "Scout did not reach Preparing database stage under non-root UID"; exit 1; }; \
    echo "$out2" | grep -qE "type initializer for 'CSMSL\\.Proteomics\\.Protease'|at CSMSL\\.Proteomics\\.Protease\\.\\.ctor|System\\.UnauthorizedAccessException.*CSMSL" && { echo "CSMSL/Protease init regression under non-root UID"; exit 1; } || true; \
    echo "$out2" | grep -q "lines parsed in the fasta DB" || { echo "Scout did not reach FASTA parsing — Protease init may have failed silently"; exit 1; }; \
    rm -rf /tmp/scout-verify; \
    echo "Scout OK (non-root UID + -search + read-only HOME)"; \
    python -c "from importlib.metadata import version; print(f'xi-mzidentml-converter {version(\"xi-mzidentml-converter\")}')"; \
    python -c "import pyopenms; print(f'pyopenms {pyopenms.__version__}')"; \
    python -c "import polars; print(f'polars {polars.__version__}')"
