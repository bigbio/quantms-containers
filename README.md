# DIA-NN Docker Container

This repository provides a lightweight Docker image for **DIA-NN**, a universal software tool for data-independent acquisition (DIA) proteomics data processing.

## **Overview**

[DIA-NN](https://github.com/vdemichev/DiaNN) is an advanced software solution for DIA proteomics data analysis. This container simplifies the installation and execution of DIA-NN by providing a pre-configured environment, ensuring compatibility and ease of use.

## **DIANN License**

quantms by default uses diann 1.8.1 which license allows quantms to distribute the docker and singularity images. The [current version of diann is 1.9.2 which license](DIANN1.9.2-LICENSE.txt) does not allow quantms or any other platform to distribute the docker and singularity images. Please before using this image, check the license of the diann version you are using and make sure you are compliant with the license.

## **Image Details**

- **Base Image**: `ubuntu:22.04`
- **DIA-NN Version**: `1.9.2`
- **Maintainer**: 
  - Yasset Perez-Riverol ([ypriverol@gmail.com](mailto:ypriverol@gmail.com))
  - Ryan Smith ([ryan.smith@imperial.ac.uk](ryan.smith@imperial.ac.uk))

## **Features**

- Pre-installed dependencies for running DIA-NN:
  - `g++`, `build-essential`, `cmake`
  - Compression libraries: `zlib1g-dev`, `libbz2-dev`
  - Boost libraries: `libboost-all-dev`
  - Tools: `wget`, `locales`, `unzip`
- Configured with `en_US.UTF-8` locale for compatibility.
- Includes the latest DIA-NN binary for Linux (`1.9.2`) as of October 2024.

## **Usage**

### **Building the Image**

To build the Docker image locally:

```bash
docker build -t diann:1.9.2 .
```

### **Running the Container**

```bash
docker run -it diann:1.9.2 diann --help
```
