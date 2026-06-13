FROM python:3.12-slim

# Metadata
LABEL base_image="python:3.12-slim"
LABEL version="1"
LABEL software="pyonsite"
LABEL software.version="0.0.3"
LABEL about.summary="onsite: mass spectrometry post-translational modification localization tool (AScore, PhosphoRS, LucXor)"
LABEL about.home="https://github.com/bigbio/onsite"
LABEL about.documentation="https://github.com/bigbio/onsite"
LABEL about.license="MIT"
LABEL about.tags="Proteomics,PTM,Phosphorylation,MassSpectrometry"
LABEL maintainer="Yasset Perez-Riverol <ypriverol@gmail.com>"

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

# Install system dependencies required by pyopenms (libglib-2.0)
RUN apt-get update && apt-get install -y --no-install-recommends \
        libglib2.0-0 && \
    rm -rf /var/lib/apt/lists/*

# Install pyonsite and its dependencies (pyopenms, numpy, scipy, pyarrow, click)
RUN pip install --no-cache-dir pyonsite==0.0.3

# Verify installation
RUN set -e; \
    echo "=== Version checks ===" && \
    python -c "from importlib.metadata import version; print(f'pyonsite {version(\"pyonsite\")}')" && \
    python -c "import pyopenms; print(f'pyopenms {pyopenms.__version__}')" && \
    python -c "import numpy; print(f'numpy {numpy.__version__}')" && \
    python -c "import scipy; print(f'scipy {scipy.__version__}')" && \
    python -c "import pyarrow; print(f'pyarrow {pyarrow.__version__}')" && \
    echo "=== CLI smoke test ===" && \
    onsite --help && \
    echo "=== Subcommand help ===" && \
    onsite ascore --help && \
    onsite phosphors --help && \
    onsite lucxor --help && \
    echo "=== All checks passed ==="

WORKDIR /data/

# Reset ENTRYPOINT/CMD so the container behaves like the other images in this repo
ENTRYPOINT []
CMD ["/bin/bash"]
