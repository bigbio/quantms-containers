# DIA-NN 2.5.1 Enterprise

This image is **built locally only** — there is no CI workflow and no GHCR
push. The enterprise zip and the per-licensee `diann-license-key.txt` are
not redistributable and are never committed to the repository (see
`.gitignore`).

## Required build context

Before building, the directory must contain:

```
diann-enterprise-2.5.1/
  Dockerfile
  DIA-NN-2.5.1-Enterprise-Linux.zip
  diann-license-key.txt
```

`build-diann-enterprise-singularity.sh` stages both files from the directory
given by `ENTERPRISE_SRC` (the folder that holds the Enterprise zip and your
license key) using hardlinks when possible, so it does not duplicate the
360 MB zip on disk.

## Build

```bash
# From the repo root:
./build-diann-enterprise-singularity.sh                # builds 2.5.1 by default
ENTERPRISE_SRC=/path/to/enterprise ./build-diann-enterprise-singularity.sh
```

Produces:

- Docker image: `ghcr.io/bigbio/diann-enterprise:2.5.1`
- Singularity image: `singularity-cache/ghcr.io-bigbio-diann-enterprise-2.5.1.img`

The Singularity filename follows the Nextflow cache convention used by the
quantmsdiann pipeline; drop it into `NXF_SINGULARITY_CACHEDIR`.

## License placement

The license is copied to **two** locations inside the image so DIA-NN finds
it regardless of how it is invoked:

- `/usr/diann-2.5.1/diann-license-key.txt` (alongside the binary)
- `/root/.config/DIA-NN/diann-license-key.txt` (XDG config dir for the
  container's default user)

## Do not push this image to a public registry.
