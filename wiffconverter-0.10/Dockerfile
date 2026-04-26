FROM sciex/wiffconverter:0.10

# Some metadata
LABEL base_image="sciex/wiffconverter:0.10"
LABEL version="2"
LABEL software="wiffconverter"
LABEL software.version="0.10"
LABEL about.summary="SCIEX WIFF to indexed mzML converter (bundled OneOmics.WiffConverter + Mono)."
LABEL about.home="https://hub.docker.com/r/sciex/wiffconverter"
LABEL about.documentation="https://sciex.com/products/software/"
LABEL about.license="Proprietary (SCIEX)"
LABEL about.tags="Proteomics,AbSciex,WIFF,MassSpectrometry"
LABEL maintainer="Yasset Perez-Riverol <ypriverol@gmail.com>"

# Sanity check: upstream image must ship mono and the WiffConverter .NET assembly.
RUN test -x /usr/bin/mono && \
    test -f /usr/local/bin/sciex/wiffconverter/OneOmics.WiffConverter.exe

# Install the `convert` CLI on PATH.
COPY convert /usr/local/bin/convert
RUN chmod +x /usr/local/bin/convert

# Reset ENTRYPOINT/CMD so the container behaves like a normal shell image
# (matches the DIA-NN / Relink / OpenMS containers in this repo).
ENTRYPOINT []
CMD ["/bin/bash"]

WORKDIR /data/
