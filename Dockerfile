FROM ubuntu:22.04

LABEL base_image="ubuntu:22.04"
LABEL version="2"
LABEL software="diann"
LABEL software.version="1.9.2"
LABEL about.summary="DIA-NN - a universal software for data-independent acquisition (DIA) proteomics data processing."
LABEL about.home="https://github.com/vdemichev/DiaNN"
LABEL about.documentation="https://github.com/vdemichev/DiaNN"
LABEL about.license_file="https://github.com/vdemichev/DiaNN/LICENSE.txt"
LABEL about.license="SPDX:CC-BY-NC-4.0"
LABEL about.tags="Proteomics"
LABEL maintainer="Yasset Perez-Riverol <ypriverol@gmail.com>"

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -y && apt-get install -y \
    g++ build-essential cmake zlib1g-dev libbz2-dev libboost-all-dev wget locales unzip && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen && update-locale LANG=en_US.UTF-8

RUN mkdir -p /opt/software && \
    wget https://github.com/vdemichev/DiaNN/releases/download/1.9.2/diann-1.9.2.Linux_update_2024-10-31.zip -O /opt/software/diann-1.9.2.Linux_update_2024-10-31.zip && \
    unzip /opt/software/diann-1.9.2.Linux_update_2024-10-31.zip -d /opt/software && \
    mv /opt/software/diann-1.9.2 /usr/diann-1.9.2 && \
    ln -s /usr/diann-1.9.2/diann-linux /usr/diann-1.9.2/diann && \
    rm -rf /opt/software

RUN chmod +x /usr/diann-1.9.2/diann-linux

ENV PATH="$PATH:/usr/diann-1.9.2"
ENV DIA_NN_PATH="/usr/diann-1.9.2"

WORKDIR /data/
