# DIA-NN Docker Container

A production-ready Docker container for **DIA-NN**, a cutting-edge software tool for data-independent acquisition (DIA) proteomics data processing.

## Overview

[DIA-NN](https://github.com/vdemichev/DiaNN) is a powerful software solution for analyzing DIA proteomics data. This containerized version offers:

- Simplified installation and deployment
- Consistent runtime environment across platforms
- Pre-configured dependencies and optimizations
- Support for both DIA-NN 1.9.2 and 2.0

## ⚠️ Important License Information

Please note the following license restrictions:

- DIA-NN 1.8.1 and earlier: License permits distribution of Docker/Singularity images
- DIA-NN 1.9.2 and 2.0: License **does not permit** distribution of pre-built images

Before using this container, ensure compliance with the version-specific license:
- [DIA-NN 1.9.2 License](diann-1.9.2/DIANN1.9.2-LICENSE.txt)
- [DIA-NN 2.0 License](diann-2.0/DIANN2.0-LICENSE.txt)

## Technical Specifications

### Container Details
- Base Image: `ubuntu:22.04`
- Available Versions: 
  - DIA-NN 1.9.2
  - DIA-NN 2.0
  - DIA-NN 2.0.2
- Architecture Support: `amd64`/`x86_64`

### Included Dependencies
| Category | Components |
|----------|------------|
| Build Tools | `g++`, `build-essential`, `cmake` |
| Compression | `zlib1g-dev`, `libbz2-dev` |
| Libraries | `libboost-all-dev` |
| Utilities | `wget`, `locales`, `unzip` |

## Installation & Usage

### Building the Images

#### Standard Build (x86_64/amd64)
```bash
# Build DIA-NN 1.9.2
cd diann-1.9.2/
docker build -t diann:1.9.2 .

# Build DIA-NN 2.0
cd diann-2.0/
docker build -t diann:2.0 .
```

#### Platform-Specific Build (e.g., AMD Mac)
```bash
# Build DIA-NN 1.9.2
cd diann-1.9.2/
docker buildx build --platform linux/amd64 . --tag diann:1.9.2

# Build DIA-NN 2.0
cd diann-2.0/
docker buildx build --platform linux/amd64 . --tag diann:2.0
```

### Basic Usage

```bash
# View DIA-NN help
docker run -it diann:1.9.2 diann --help
docker run -it diann:2.0 diann --help

# Process data (example)
docker run -v /path/to/data:/data -it diann:2.0 diann \
  --f /data/input.raw \
  --lib /data/library.tsv \
  --out /data/results.tsv
```

### Data Mounting
When processing data, mount your local directories using Docker volumes:
```bash
docker run -v /local/path:/container/path -it diann:2.0 diann [commands]
```

## Performance Tips

1. **Memory Allocation**: Ensure sufficient memory is allocated to Docker
2. **Storage**: Use fast storage (SSD recommended) for data directories
3. **CPU**: DIA-NN benefits from multiple cores; allocate accordingly
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

## Maintainers

- Yasset Perez-Riverol ([@ypriverol](https://github.com/ypriverol)) - [ypriverol@gmail.com](mailto:ypriverol@gmail.com)
- Ryan Smith - [ryan.smith@imperial.ac.uk](mailto:ryan.smith@imperial.ac.uk)

## Contributing

We welcome contributions! Please:

1. Fork the repository
2. Create a feature branch
3. Submit a pull request

## Citation

If you use this container in your research, please cite:

```bibtex
@software{diann_docker,
  author = {Perez-Riverol, Yasset and Smith, Ryan},
  title = {DIA-NN Docker Container},
  year = {2025},
  url = {https://github.com/ypriverol/diann-container}
}
```