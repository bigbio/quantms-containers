# QuantMS Docker Containers

A repository of production-ready Docker and Singularity containers for proteomics tools used in quantms pipelines, including **DIA-NN**, **Relink**, and **OpenMS**.

## Overview

This repository provides containerized versions of popular proteomics tools:

- [DIA-NN](https://github.com/vdemichev/DiaNN): A powerful software solution for analyzing DIA proteomics data
- [Relink](https://github.com/bigbio/relink): Crosslinking mass spectrometry analysis pipeline (xiSEARCH, xiFDR, Scout)
- [OpenMS](https://www.openms.de/): A versatile open-source software for mass spectrometry data analysis

These containerized versions offer:

- Simplified installation and deployment
- Consistent runtime environment across platforms
- Pre-configured dependencies and optimizations
- Automatic builds and releases via GitHub Actions
- Both Docker and Singularity container formats

## Container Availability

### DIA-NN Containers

**Important**: Due to licensing restrictions, DIA-NN containers are not publicly distributed. Users must build these containers locally or have access to the private `ghcr.io/bigbio/diann` registry.

| Version | Directory | Key Features | Container Tag |
|---------|-----------|-------------|---------------|
| 1.8.1 | `diann-1.8.1/` | Core DIA-NN, library-free analysis | `ghcr.io/bigbio/diann:1.8.1` |
| 1.9.2 | `diann-1.9.2/` | QuantUMS quantification, redesigned NN | `ghcr.io/bigbio/diann:1.9.2` |
| 2.0.2 | `diann-2.0/` | Parquet output, proteoform confidence | `ghcr.io/bigbio/diann:2.0.2` |
| 2.1.0 | `diann-2.1.0/` | Native .raw on Linux | `ghcr.io/bigbio/diann:2.1.0` |
| 2.2.0 | `diann-2.2.0/` | Latest release | `ghcr.io/bigbio/diann:2.2.0` |

```bash
# Build Docker container locally
cd diann-2.1.0/
docker build -t diann:2.1.0 .

# Build Singularity container from Docker
singularity build diann-2.1.0.sif docker-daemon://diann:2.1.0
```

### Relink Container

The Relink container provides a complete crosslinking mass spectrometry analysis environment.

| Component | Version | Description |
|-----------|---------|-------------|
| xiSEARCH | 1.8.11 | Crosslink identification search engine |
| xiFDR | 2.3.10 | FDR estimation for crosslinked peptides |
| Scout | 2.0.0 | Crosslink analysis tool |
| pyOpenMS | latest | Python bindings for OpenMS |
| .NET Runtime | 9.0 | Required by Scout |
| Java JRE | 21 | Required by xiSEARCH and xiFDR |

| Container Type | Tag | URL |
|----------------|-----|-----|
| Docker | 1.0.0 | `ghcr.io/bigbio/relink:1.0.0` |
| Docker | latest | `ghcr.io/bigbio/relink:latest` |
| Singularity | 1.0.0 | `oras://ghcr.io/bigbio/relink-sif:1.0.0` |

```bash
# Pull Relink Docker image
docker pull ghcr.io/bigbio/relink:latest

# Run xiSEARCH
docker run -v /path/to/data:/data ghcr.io/bigbio/relink:latest \
  java -jar /opt/xisearch/xiSEARCH.jar --help

# Run Scout
docker run -v /path/to/data:/data ghcr.io/bigbio/relink:latest \
  dotnet /opt/scout/Scout_Unix.dll --help
```

### OpenMS Containers

OpenMS containers are publicly available and can be pulled directly:

| Container Type | Version | URL |
|----------------|---------|-----|
| Docker | date-tagged | `ghcr.io/bigbio/openms-tools-thirdparty:YYYY.MM.DD` |
| Docker | latest | `ghcr.io/bigbio/openms-tools-thirdparty:latest` |
| Singularity | date-tagged | `oras://ghcr.io/bigbio/openms-tools-thirdparty-sif:YYYY.MM.DD` |
| Singularity | latest | `oras://ghcr.io/bigbio/openms-tools-thirdparty-sif:latest` |

The date tag (YYYY.MM.DD) is manually set for each release to ensure version stability.

## License Information

Please note the following license restrictions:

- **DIA-NN**: Custom academic license with restrictions. Please review the [DIA-NN license](diann-2.1.0/LICENSE.txt) before using. No commercial use or cloud deployment without collaboration agreement.
- **Relink/xiSEARCH/xiFDR/Scout**: Please review the individual tool licenses
- **OpenMS**: Available under the [BSD 3-Clause License](https://github.com/OpenMS/OpenMS/blob/develop/LICENSE)

## Technical Specifications

### DIA-NN Containers
- Base Image: `ubuntu:22.04`
- Available Versions: 1.8.1, 1.9.2, 2.0.2, 2.1.0, 2.2.0
- Architecture: `amd64`/`x86_64`

### Relink Container
- Base Image: `python:3.12-slim` (multi-stage build)
- Version: 1.0.0
- Architecture: `amd64`/`x86_64`
- Includes: Java 21, .NET 9.0, Python 3.12, pyOpenMS, polars, pandas

### OpenMS Containers
- Sourced from: `ghcr.io/openms/openms-tools-thirdparty`
- Architecture: `amd64`/`x86_64`

## Installation & Usage

### Fork repository to get access to private quantms containers

The workflow in `.github/workflows/quantms-containers.yml` is configured to build and push
DIA-NN containers to the private `ghcr.io/{owner}/diann` and `ghcr.io/{owner}/diann-sif` 
registries. To access these 
containers, which runs the action in your own GitHub organization. If this fails,
you will need to configure the packages on ghcr.io to allow pushing from 
the GitHub Actions. This can be configured for the entire organization or for each
package individually. Please refer to the
[GitHub documentation](https://docs.github.com/en/packages/learn-github-packages/configuring-a-packages-access-control-and-visibility#configuring-access-to-packages-for-your-personal-account) 
for more details. See also the gif for details on the biosustain fork (do it for both
`diann` and `diann-sif` packages):

![GIF about the setting on biosustain fork](assets/quantms_containers_setup.mp4)

> Below you then need to replace `bigbio` with your GitHub username or organization name
> in the container tags.

### Using Pre-built Docker Images

```bash
# Pull DIA-NN Docker image (requires GHCR access)
docker pull ghcr.io/bigbio/diann:2.1.0

# Pull Relink Docker image
docker pull ghcr.io/bigbio/relink:latest

# Pull OpenMS Docker image
docker pull ghcr.io/bigbio/openms-tools-thirdparty:latest
```

### Building Images Locally

```bash
# Build DIA-NN (any version)
cd diann-2.1.0/ && docker build -t diann:2.1.0 .

# Build Relink
cd relink-1.0.0/ && docker build -t relink:1.0.0 .
```

### Basic Usage

#### DIA-NN
```bash
docker run -v /path/to/data:/data ghcr.io/bigbio/diann:2.1.0 diann \
  --f /data/input.raw \
  --lib /data/library.tsv \
  --out /data/results.tsv
```

#### DIA-NN in quantmsdiann pipeline

After building your container, create a custom configuration file to override the DIA-NN container:

```nextflow
process {
    withLabel: diann {
        container = '/path-singularity-file/diann-2.1.0.sif'
    }
}
```

Please check [quantmsdiann documentation](https://github.com/bigbio/quantmsdiann) for more information.

#### Relink
```bash
# Run xiSEARCH
docker run -v /path/to/data:/data ghcr.io/bigbio/relink:latest \
  java -jar /opt/xisearch/xiSEARCH.jar [options]

# Run Scout
docker run -v /path/to/data:/data ghcr.io/bigbio/relink:latest \
  dotnet /opt/scout/Scout_Unix.dll [options]
```

#### OpenMS
```bash
docker run -v /path/to/data:/data ghcr.io/bigbio/openms-tools-thirdparty:latest \
  PeakPickerHiRes -in /data/input.mzML -out /data/output.mzML
```

### Data Mounting
When processing data, mount your local directories using Docker volumes:
```bash
docker run -v /local/path:/container/path -it <container> [commands]
```

## CI/CD Workflow

This repository includes a GitHub Actions workflow that builds and syncs all containers:

**QuantMS Containers Build and Sync**: A combined workflow that:
1. Builds and pushes DIA-NN Docker and Singularity containers (all versions)
2. Builds and pushes Relink Docker and Singularity containers
3. Syncs OpenMS containers from the official repository to BigBio

The workflow is triggered by:
- Pushes to the main branch
- Pull requests (for Dockerfile changes)
- Release events (which also tag images as "latest")
- Manual dispatch with configurable options

## Troubleshooting

1. **Permission Errors**
   ```bash
   chown -R $(id -u):$(id -g) /path/to/output
   ```

2. **Memory Issues**: Increase Docker memory allocation in Docker Desktop settings

3. **DIA-NN Container Issues**: Must be built locally or with GHCR access due to licensing

4. **Relink Java/Dotnet Issues**: Ensure the container has sufficient memory (recommend >= 4GB)

## Maintainers

- Yasset Perez-Riverol ([@ypriverol](https://github.com/ypriverol)) - [ypriverol@gmail.com](mailto:ypriverol@gmail.com)

## Contributing

We welcome contributions! Please:

1. Fork the repository
2. Create a feature branch
3. Submit a pull request

## Citation

If you use these containers in your research, please cite:

```bibtex
@software{quantms_containers,
  author = {Perez-Riverol, Yasset},
  title = {QuantMS Docker Containers},
  year = {2025},
  url = {https://github.com/bigbio/quantms-containers}
}
```
