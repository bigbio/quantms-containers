FROM ubuntu:22.04

# Some metadata
LABEL base_image="ubuntu:22.04"
LABEL version="2"
LABEL software="diann"
LABEL software.version="1.9.2"
LABEL about.summary="DIA-NN - a universal software for data-independent acquisition (DIA) proteomics data processing."
LABEL about.home="https://github.com/vdemichev/DiaNN"
LABEL about.documentation="https://github.com/vdemichev/DiaNN"
LABEL about.license_file="https://github.com/vdemichev/DiaNN/LICENSE.txt"
LABEL about.tags="Proteomics"
LABEL maintainer="Yasset Perez-Riverol <ypriverol@gmail.com>"

ENV DEBIAN_FRONTEND=noninteractive

# Update package lists and ensure package versions are up to date, Install necessary packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    unzip \
    libgomp1 \
    locales && \
    rm -rf /var/lib/apt/lists/*

# Configure locale to avoid runtime errors
RUN locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8

# Set environment variables for locale
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Download and install DIA-NN
RUN wget --no-check-certificate https://github.com/vdemichev/DiaNN/releases/download/1.9.2/diann-1.9.2.Linux.zip -O /tmp/diann-1.9.2.Linux.zip && \
    unzip /tmp/diann-1.9.2.Linux.zip -d /usr/ && \
    rm /tmp/diann-1.9.2.Linux.zip

# Remove unnecessary packages
RUN apt-get remove -y wget unzip && apt-get autoremove -y && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set appropriate permissions for the DIA-NN folder
RUN chmod -R 775 /usr/diann-1.9.2
RUN chmod +x /usr/diann-1.9.2/diann-linux

# Create a symbolic link and add to PATH
RUN ln -s /usr/diann-1.9.2/diann-linux /usr/diann-1.9.2/diann
ENV PATH="$PATH:/usr/diann-1.9.2"

WORKDIR /data/

# NOTE: It is entirely the user's responsibility to ensure compliance with DIA-NN license terms.
# Please review the licensing terms for DIA-NN before using or distributing this Docker image.