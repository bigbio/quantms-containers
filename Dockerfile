FROM debian:12
USER root
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y \
        locales && \
    rm -r /var/lib/apt/lists/*

RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    sed -i -e 's/# de_DE.UTF-8 UTF-8/de_DE.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales

RUN apt update && apt install -y libgomp1 build-essential

ARG DIANNV=2.0
COPY diann-$DIANNV /diann-$DIANNV

RUN echo ls
RUN chmod -R 775 /diann-$DIANNV
