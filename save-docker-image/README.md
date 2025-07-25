# Save Docker Image Action

A GitHub Action to save a Docker image to a tar file for later use, caching, or distribution.

## Features

- 🐳 Save any Docker image to a tar file
- 📁 Customizable output path
- 🏷️ Support for specific image tags
- 📊 Returns file size information
- 📦 Automatic artifact upload (optional)
- ⏰ Configurable artifact retention
- ✅ Cross-platform support (Linux, macOS, Windows)
- 🔍 Detailed logging and error handling

## Usage

### Basic Usage

```yaml
- name: Save Docker Image
  uses: apicurio/apicurio-github-actions/save-docker-image@v2
  with:
    image-name: 'nginx'
```

### Advanced Usage

```yaml
- name: Save Docker Image
  uses: apicurio/apicurio-github-actions/save-docker-image@v2
  with:
    image-name: 'my-app'
    tag: 'v1.2.3'
    output-path: './artifacts/my-app-v1.2.3.tar'
```

### Complete Workflow Example

```yaml
name: Build and Save Docker Image

on:
  push:
    branches: [ main ]

jobs:
  build-and-save:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
    
    - name: Build Docker image
      run: |
        docker build -t my-app:latest .
    
    - name: Save Docker image
      id: save-image
      uses: apicurio/apicurio-github-actions/save-docker-image@v2
      with:
        image-name: 'my-app'
        tag: 'latest'
        output-path: './my-app.tar'
    
    - name: Upload artifact
      uses: actions/upload-artifact@v4
      with:
        name: docker-image
        path: ${{ steps.save-image.outputs.saved-path }}
    
    - name: Display file info
      run: |
        echo "Image saved to: ${{ steps.save-image.outputs.saved-path }}"
        echo "File size: ${{ steps.save-image.outputs.file-size }} bytes"
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `image-name` | Name of the Docker image to save | ✅ Yes | - |
| `tag` | Tag of the Docker image to save | ❌ No | `latest` |
| `output-path` | Path where the tar file should be saved | ❌ No | `./docker-image.tar` |
| `upload` | Whether to upload the saved image as an artifact | ❌ No | `true` |
| `artifact-name` | Name for the uploaded artifact | ❌ No | `docker-image` |
| `artifact-retention-days` | Number of days to retain the artifact | ❌ No | `7` |

## Outputs

| Output | Description |
|--------|-------------|
| `saved-path` | Path where the Docker image was saved |
| `file-size` | Size of the saved Docker image file in bytes |

## Use Cases

### 1. Caching Docker Images

Save built images to avoid rebuilding in subsequent workflow runs:

```yaml
- name: Save Docker image for caching
  uses: apicurio/apicurio-github-actions/save-docker-image@v2
  with:
    image-name: 'my-app'
    output-path: './cache/my-app.tar'

- name: Cache Docker image
  uses: actions/cache@v4
  with:
    path: ./cache/my-app.tar
    key: docker-image-${{ hashFiles('Dockerfile') }}
```

### 2. Automatic Artifact Upload

The action automatically uploads the saved Docker image as an artifact (enabled by default):

```yaml
- name: Save and upload Docker image
  uses: apicurio/apicurio-github-actions/save-docker-image@v2
  with:
    image-name: 'my-app'
    artifact-name: 'my-app-image'
    artifact-retention-days: 7
```

To disable automatic artifact upload:

```yaml
- name: Save Docker image (no upload)
  uses: apicurio/apicurio-github-actions/save-docker-image@v2
  with:
    image-name: 'my-app'
    upload: 'false'
```

### 3. Multi-Job Workflows

Share Docker images between different jobs using automatic artifact upload:

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - name: Build and save image
      uses: apicurio/apicurio-github-actions/save-docker-image@v2
      with:
        image-name: 'my-app'
        artifact-name: 'my-app-docker-image'
        # Artifact is automatically uploaded

  test:
    needs: build
    runs-on: ubuntu-latest
    steps:
    - name: Download image artifact
      uses: actions/download-artifact@v4
      with:
        name: 'my-app-docker-image'
    
    - name: Load Docker image
      run: docker load -i docker-image.tar
```

### 4. Release Artifacts

Include Docker images as release artifacts:

```yaml
- name: Save release image
  uses: apicurio/apicurio-github-actions/save-docker-image@v2
  with:
    image-name: 'my-app'
    tag: ${{ github.ref_name }}
    output-path: './release/my-app-${{ github.ref_name }}.tar'
    upload: 'false'  # Don't upload as artifact for releases

- name: Create Release
  uses: softprops/action-gh-release@v1
  with:
    files: ./release/my-app-${{ github.ref_name }}.tar
```

## Requirements

- Docker must be available in the runner environment
- The specified Docker image must exist locally (built or pulled)

## Error Handling

The action will fail if:
- The specified Docker image doesn't exist
- Docker is not available
- There are insufficient permissions to write to the output path
- The disk space is insufficient

## Contributing

This action is part of the [Apicurio GitHub Actions](https://github.com/Apicurio/apicurio-github-actions) repository. Please refer to the main repository for contribution guidelines.

## License

This action is licensed under the Apache License 2.0. See the [LICENSE](../LICENSE) file for details.
