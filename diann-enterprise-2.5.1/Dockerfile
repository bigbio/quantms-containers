# syntax=docker/dockerfile:1.4
#
# DIA-NN 2.5.1 Enterprise build.
#
# Unlike the Academic Dockerfiles, this image is built from a *local* enterprise
# zip plus a per-licensee license key file. Neither artefact is hosted on a
# public URL, so both must be present in the build context before `docker build`
# is invoked:
#
#   diann-enterprise-2.5.1/
#     Dockerfile
#     DIA-NN-2.5.1-Enterprise-Linux.zip    (provided by you; .gitignored)
#     diann-license-key.txt                (provided by you; .gitignored)
#
# Build with build-diann-enterprise-singularity.sh, which stages those files
# automatically from /srv/data/diann-enterprise (or $ENTERPRISE_SRC).
#
# The license is copied to /usr/diann-2.5.1/ so it sits next to the DIA-NN
# binary, and is also linked into the root user's XDG data dir, which is one
# of the locations DIA-NN searches for `diann-license-key.txt` at runtime.
#
# IMPORTANT: this image embeds a license key. Do NOT push it to a public
# registry.

FROM ubuntu:22.04 AS extractor

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
        unzip \
        ca-certificates && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /stage
COPY DIA-NN-2.5.1-Enterprise-Linux.zip ./
RUN unzip -q DIA-NN-2.5.1-Enterprise-Linux.zip -d /opt && \
    rm DIA-NN-2.5.1-Enterprise-Linux.zip


FROM ubuntu:22.04

LABEL base_image="ubuntu:22.04"
LABEL version="1"
LABEL software="diann-enterprise"
LABEL software.version="2.5.1"
LABEL about.summary="DIA-NN 2.5.1 Enterprise - a universal software for data-independent acquisition (DIA) proteomics data processing."
LABEL about.home="https://github.com/vdemichev/DiaNN"
LABEL about.documentation="https://github.com/vdemichev/DiaNN"
LABEL about.license="Commercial - per-licensee key required"
LABEL about.tags="Proteomics"
LABEL maintainer="Yasset Perez-Riverol <ypriverol@gmail.com>"

ENV DEBIAN_FRONTEND=noninteractive

# dotnet-sdk-8.0 is required for DIA-NN >= 2.1.0 to read Thermo .raw natively on Linux
# (DIA-NN bundles Thermo DLLs targeting net8.0 and invokes `dotnet --list-sdks` at startup).
RUN apt-get update && apt-get install -y --no-install-recommends \
        libgomp1 \
        locales \
        ca-certificates \
        dotnet-sdk-8.0 && \
    rm -rf /var/lib/apt/lists/*

RUN locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Bring the extracted DIA-NN tree from the extractor stage so the final image
# never carries the zip as a layer.
COPY --from=extractor /opt/diann-2.5.1 /usr/diann-2.5.1

# Stage the license alongside the binary; DIA-NN searches the install directory
# (and CWD, and $HOME/.config/DIA-NN) for `diann-license-key.txt`.
COPY diann-license-key.txt /usr/diann-2.5.1/diann-license-key.txt
RUN mkdir -p /root/.config/DIA-NN && \
    cp /usr/diann-2.5.1/diann-license-key.txt /root/.config/DIA-NN/diann-license-key.txt && \
    chmod 0644 /usr/diann-2.5.1/diann-license-key.txt /root/.config/DIA-NN/diann-license-key.txt

RUN chmod +x /usr/diann-2.5.1/diann-linux && \
    ln -s /usr/diann-2.5.1/diann-linux /usr/diann-2.5.1/diann

ENV PATH="$PATH:/usr/diann-2.5.1"

WORKDIR /data/

# NOTE: It is entirely the user's responsibility to ensure compliance with DIA-NN license terms.
