# QuantMS Docker Containers

A repository of production-ready Docker and Singularity containers for proteomics tools, including **DIA-NN** and **OpenMS**.

## Overview

This repository provides containerized versions of popular proteomics tools:

- [DIA-NN](https://github.com/vdemichev/DiaNN): A powerful software solution for analyzing DIA proteomics data
- [OpenMS](https://www.openms.de/): A versatile open-source software for mass spectrometry data analysis

These containerized versions offer:

- Simplified installation and deployment
- Consistent runtime environment across platforms
- Pre-configured dependencies and optimizations
- Automatic builds and releases via GitHub Actions
- Both Docker and Singularity container formats

## Container Availability

### DIA-NN Containers

**Important**: Due to licensing restrictions, DiaNN containers are not publicly distributed. Users must build these containers locally:

```bash
# Build Docker container
cd diann-2.1.0/
docker build -t diann:2.1.0 .

# Build Singularity container from Docker
singularity build diann-2.1.0.sif docker-daemon://diann:2.1.0
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

## ⚠️ Important License Information

Please note the following license restrictions:

- DIA-NN: Please review the [DIA-NN 2.1.0 license](diann-2.1.0/LICENSE.txt) before using
- OpenMS: OpenMS is available under the [BSD 3-Clause License](https://github.com/OpenMS/OpenMS/blob/develop/LICENSE)

## Technical Specifications

### DIA-NN Container Details
- Base Image: `ubuntu:22.04`
- Available Version: DIA-NN 2.1.0
- Architecture Support: `amd64`/`x86_64`

### OpenMS Container Details
- Sourced from: `ghcr.io/openms/openms-tools-thirdparty`
- Architecture Support: `amd64`/`x86_64`

## Installation & Usage

### Using Pre-built Docker Images

```bash
# Pull DIA-NN Docker image
docker pull ghcr.io/bigbio/diann:latest

# Pull OpenMS Docker image
docker pull ghcr.io/bigbio/openms-tools-thirdparty:latest
```

### Using Pre-built Singularity Images

```bash
# Pull OpenMS Singularity image
singularity pull openms.sif oras://ghcr.io/bigbio/openms-tools-thirdparty-sif:latest
```

### Building the Images Locally

#### DIA-NN Build
```bash
# Build DIA-NN 2.1.0
cd diann-2.1.0/
docker build -t diann:2.1.0 .
```

### Basic Usage

#### DIA-NN Usage
```bash
# View DIA-NN help
docker run -it diann:2.1.0 diann --help

# Process data (example)
docker run -v /path/to/data:/data -it ghcr.io/bigbio/diann:latest diann \
  --f /data/input.raw \
  --lib /data/library.tsv \
  --out /data/results.tsv
```

#### DIANN Usage in quantms pipeline

After you build your container, you chave to add a custom configuration file to resolve the diann container. You can do this by creating a file called `diann_config.yml` in the `quantms` directory. The content of the file should be:

```yaml
process {
    withLabel: diann {
        container = '/path-singularity-file/diann-2.0.0.sif'
    }
}
```

Please check quantms documentation for more information about how to run the pipeline with custom configurations. 

#### OpenMS Usage
```bash
# View OpenMS tools
docker run -it ghcr.io/bigbio/openms-tools-thirdparty:latest ls /usr/local/bin/

# Run an OpenMS tool (example)
docker run -v /path/to/data:/data -it ghcr.io/bigbio/openms-tools-thirdparty:latest \
  PeakPickerHiRes -in /data/input.mzML -out /data/output.mzML
```

### Data Mounting
When processing data, mount your local directories using Docker volumes:
```bash
docker run -v /local/path:/container/path -it ghcr.io/bigbio/diann:latest diann [commands]
```

## CI/CD Workflow

This repository includes a GitHub Actions workflow that builds and syncs all containers:

**QuantMS Containers Build and Sync**: A combined workflow that:
1. First builds and pushes DIA-NN Docker and Singularity containers
2. Then syncs OpenMS containers from the official repository to BigBio

The workflow is triggered by:
- Pushes to the main branch
- Pull requests (for DiaNN builds only)
- Release events (which also tag images as "latest")
- Manual dispatch with configurable options

This sequential approach ensures that all containers are built and pushed in a coordinated manner.

## Performance Tips

1. **Memory Allocation**: Ensure sufficient memory is allocated to Docker
2. **Storage**: Use fast storage (SSD recommended) for data directories
3. **CPU**: These tools benefit from multiple cores; allocate accordingly
4. **Temp Files**: Consider mounting a temp directory for large analyses

## Troubleshooting

Common issues and solutions:

1. **Permission Errors**
   ```bash
   # Fix file ownership issues
   chown -R $(id -u):$(id -g) /path/to/output
   ```

2. **Memory Issues**
   - Increase Docker memory allocation in Docker Desktop settings
   - Use `--memory` flag to specify container memory limit

3. **OpenMS Singularity Pull Issues**
   
   If you encounter an error when pulling OpenMS Singularity images:
   ```
   FATAL: While pulling image from oci registry: error fetching image to cache: failed to get checksum for oras://ghcr.io/bigbio/openms-tools-thirdparty-sif:YYYY.MM.DD: GET https://ghcr.io/v2/bigbio/openms-tools-thirdparty-sif/manifests/YYYY.MM.DD: DENIED: requested access to the resource is denied
   ```
   
   Try the following:
   
   - Verify you're using the correct date tag format (YYYY.MM.DD)
   - Check the workflow logs to confirm the exact version tag that was published
   - If using Nextflow, try increasing the pull timeout:
     ```
     nextflow run bigbio/quantms -r dev -profile test_lfq,singularity -with-singularity --singularity.pullTimeout '2h'
     ```
   - If the issue persists, please open an issue on the GitHub repository

4. **DiaNN Container Issues**
   
   Remember that DiaNN containers must be built locally due to licensing restrictions:
   
   - Follow the build instructions in the "DiaNN Containers" section
   - For quantms pipeline, specify your local DiaNN container path in a custom config file:
     ```yaml
     process {
         withLabel: diann {
             container = '/path-to-your-singularity-file/diann-2.1.0.sif'
         }
     }
     ```

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
@software{quantms_docker,
  author = {Perez-Riverol, Yasset},
  title = {QuantMS Docker Containers},
  year = {2025},
  url = {https://github.com/ypriverol/quantms-docker}
}