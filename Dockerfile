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

USER root
ENV DEBIAN_FRONTEND=noninteractive

# Update package lists and ensure package versions are up to date
RUN apt-get update && apt-get upgrade -y

# Install necessary packages including locales
RUN apt-get install wget unzip libgomp1 locales -y

# Configure locale to avoid runtime errors
RUN locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8

# Set environment variables for locale
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Download DIA-NN version <version>
RUN wget https://github.com/vdemichev/DiaNN/releases/download/1.9.2/diann-1.9.2.Linux.zip -O diann-1.9.2.Linux.zip

# Unzip the DIA-NN package
RUN unzip diann-1.9.2.Linux.zip

# Set appropriate permissions for the DIA-NN folder
RUN chmod -R 775 /diann-1.9.2

# NOTE: It is entirely the user's responsibility to ensure compliance with DIA-NN license terms.
# Please review the licensing terms for DIA-NN before using or distributing this Docker image.