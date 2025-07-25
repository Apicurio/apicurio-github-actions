# Load Docker Image Action

A GitHub Action to download and load a Docker image from an artifact created by the `save-docker-image` action.

## Features

- 📥 Download Docker image artifacts automatically
- 🐳 Load Docker images into the local Docker daemon
- 🔍 Verify loaded image names and tags
- 📊 Report file size and image information
- ✅ Cross-platform support (Linux, macOS, Windows)
- 🔧 Flexible input options for different workflows
- 📋 Detailed logging and verification

## Usage

### Basic Usage

```yaml
- name: Load Docker Image
  uses: apicurio/apicurio-github-actions/load-docker-image@v1
  with:
    artifact-name: 'docker-image'
```

### Advanced Usage

```yaml
- name: Load Docker Image
  uses: apicurio/apicurio-github-actions/load-docker-image@v1
  with:
    artifact-name: 'my-app-image'
    image-name: 'my-app'
    tag: 'v1.2.3'
```

### Complete Workflow Example

```yaml
name: Build, Save, and Load Docker Image

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
      uses: apicurio/apicurio-github-actions/save-docker-image@v1
      with:
        image-name: 'my-app'
        tag: 'latest'
        artifact-name: 'my-app-docker-image'

  test:
    needs: build-and-save
    runs-on: ubuntu-latest
    
    steps:
    - name: Load Docker image
      id: load-image
      uses: apicurio/apicurio-github-actions/load-docker-image@v1
      with:
        artifact-name: 'my-app-docker-image'
        image-name: 'my-app'
        tag: 'latest'
    
    - name: Verify loaded image
      run: |
        echo "Loaded image: ${{ steps.load-image.outputs.loaded-image }}"
        echo "Image ID: ${{ steps.load-image.outputs.image-id }}"
        echo "File size: ${{ steps.load-image.outputs.file-size }} bytes"
        
        # Run the loaded image
        docker run --rm ${{ steps.load-image.outputs.loaded-image }} echo "Hello from loaded image!"
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `artifact-name` | Name of the artifact containing the Docker image | ❌ No | `docker-image` |
| `image-path` | Path where the Docker image tar file will be downloaded to | ❌ No | `./docker-image.tar` |
| `image-name` | Expected name of the Docker image (for verification) | ❌ No | - |
| `tag` | Expected tag of the Docker image (for verification) | ❌ No | `latest` |

## Outputs

| Output | Description |
|--------|-------------|
| `loaded-image` | Name and tag of the loaded Docker image |
| `image-id` | ID of the loaded Docker image |
| `file-size` | Size of the Docker image file in bytes |

## Use Cases

### 1. Multi-Job Workflows

Load Docker images saved in previous jobs:

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - name: Build and save image
      uses: apicurio/apicurio-github-actions/save-docker-image@v1
      with:
        image-name: 'my-app'
        artifact-name: 'my-app-docker-image'

  test:
    needs: build
    runs-on: ubuntu-latest
    steps:
    - name: Load Docker image
      uses: apicurio/apicurio-github-actions/load-docker-image@v1
      with:
        artifact-name: 'my-app-docker-image'
    
    - name: Run tests
      run: docker run --rm my-app:latest npm test

  deploy:
    needs: [build, test]
    runs-on: ubuntu-latest
    steps:
    - name: Load Docker image
      uses: apicurio/apicurio-github-actions/load-docker-image@v1
      with:
        artifact-name: 'my-app-docker-image'
    
    - name: Deploy image
      run: |
        docker tag my-app:latest registry.example.com/my-app:latest
        docker push registry.example.com/my-app:latest
```

### 2. Image Verification

Verify that the loaded image matches expectations:

```yaml
- name: Load and verify Docker image
  id: load-image
  uses: apicurio/apicurio-github-actions/load-docker-image@v1
  with:
    artifact-name: 'production-image'
    image-name: 'my-app'
    tag: 'v1.0.0'

- name: Validate loaded image
  run: |
    if [[ "${{ steps.load-image.outputs.loaded-image }}" == "my-app:v1.0.0" ]]; then
      echo "✅ Image loaded successfully with correct name and tag"
    else
      echo "❌ Image name/tag mismatch"
      exit 1
    fi
```

### 3. Cross-Platform Workflows

Load images across different operating systems:

```yaml
strategy:
  matrix:
    os: [ubuntu-latest, windows-latest, macos-latest]

runs-on: ${{ matrix.os }}

steps:
- name: Load Docker image
  uses: apicurio/apicurio-github-actions/load-docker-image@v1
  with:
    artifact-name: 'cross-platform-image'
```

### 4. Conditional Loading

Load images only when needed:

```yaml
- name: Check if image exists
  id: check-image
  run: |
    if docker images --format "{{.Repository}}:{{.Tag}}" | grep -q "my-app:latest"; then
      echo "exists=true" >> $GITHUB_OUTPUT
    else
      echo "exists=false" >> $GITHUB_OUTPUT
    fi

- name: Load Docker image if not exists
  if: steps.check-image.outputs.exists == 'false'
  uses: apicurio/apicurio-github-actions/load-docker-image@v1
  with:
    artifact-name: 'my-app-docker-image'
```

### 5. Multiple Image Loading

Load multiple Docker images in a single job:

```yaml
- name: Load application image
  uses: apicurio/apicurio-github-actions/load-docker-image@v1
  with:
    artifact-name: 'app-image'
    image-name: 'my-app'

- name: Load database image
  uses: apicurio/apicurio-github-actions/load-docker-image@v1
  with:
    artifact-name: 'db-image'
    image-name: 'my-db'

- name: Start services
  run: |
    docker run -d --name app my-app:latest
    docker run -d --name db my-db:latest
```

## Requirements

- Docker must be available in the runner environment
- The specified artifact must exist and contain a valid Docker image tar file
- Sufficient disk space to load the Docker image

## Error Handling

The action will fail if:
- The specified artifact doesn't exist or can't be downloaded
- The Docker image tar file is not found at the specified path
- The tar file is corrupted or not a valid Docker image
- Docker is not available in the runner environment
- There are insufficient permissions or disk space

## Troubleshooting

### Common Issues

1. **Artifact not found**: Ensure the artifact name matches exactly with the one created by `save-docker-image`
2. **File not found**: Check that the `image-path` is correct and the file exists
3. **Docker not available**: Ensure Docker is installed and running in the runner environment
4. **Permission denied**: Check file permissions and runner capabilities

### Debug Information

The action provides detailed logging including:
- File size information
- Docker load output
- Image verification results
- Current Docker images list

## Integration with save-docker-image

This action is designed to work seamlessly with the `save-docker-image` action:

```yaml
# Job 1: Save image
- name: Save Docker image
  uses: apicurio/apicurio-github-actions/save-docker-image@v1
  with:
    image-name: 'my-app'
    tag: 'v1.0.0'
    artifact-name: 'my-app-image'

# Job 2: Load image (in different job/workflow)
- name: Load Docker image
  uses: apicurio/apicurio-github-actions/load-docker-image@v1
  with:
    artifact-name: 'my-app-image'  # Same as save action
    image-name: 'my-app'           # Same as save action
    tag: 'v1.0.0'                 # Same as save action
```

## Contributing

This action is part of the [Apicurio GitHub Actions](https://github.com/Apicurio/apicurio-github-actions) repository. Please refer to the main repository for contribution guidelines.

## License

This action is licensed under the Apache License 2.0. See the [LICENSE](../LICENSE) file for details.
