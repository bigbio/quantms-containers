FROM ubuntu:22.04

LABEL base_image="ubuntu:22.04"
LABEL version="1"
LABEL software="diann"
LABEL software.version="1.9.2"
LABEL about.summary="DIA-NN - a universal software for data-independent acquisition (DIA) proteomics data processing."
LABEL about.home="https://github.com/vdemichev/DiaNN"
LABEL about.documentation="https://github.com/vdemichev/DiaNN"
LABEL about.license_file="https://github.com/vdemichev/DiaNN/LICENSE.txt"
LABEL about.tags="Proteomics"
LABEL maintainer="Yasset Perez-Riverol <ypriverol@gmail.com>"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    unzip \
    libgomp1 \
    locales && \
    rm -rf /var/lib/apt/lists/*

RUN locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Download DIA-NN 1.9.2 (release tag: 1.9.2)
RUN wget --no-check-certificate https://github.com/vdemichev/DiaNN/releases/download/1.9.2/diann-1.9.2.Linux.zip && \
    unzip diann-1.9.2.Linux.zip -d /usr/diann-1.9.2/ && \
    rm diann-1.9.2.Linux.zip

RUN apt-get remove -y wget unzip && apt-get autoremove -y && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN chmod +x /usr/diann-1.9.2/diann-linux || chmod +x /usr/diann-1.9.2/diann
RUN ln -sf /usr/diann-1.9.2/diann-linux /usr/diann-1.9.2/diann 2>/dev/null || true
ENV PATH="$PATH:/usr/diann-1.9.2"

WORKDIR /data/

# NOTE: It is entirely the user's responsibility to ensure compliance with DIA-NN license terms.
