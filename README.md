![Verify Build Workflow](https://github.com/Apicurio/apicurio-github-actions/workflows/Verify%20Build%20Workflow/badge.svg)
![Release Workflow](https://github.com/Apicurio/apicurio-github-actions/workflows/Release%20Workflow/badge.svg)
[![Automated Release Notes by gren](https://img.shields.io/badge/%F0%9F%A4%96-release%20notes-00B2EE.svg)](https://github-tools.github.io/github-release-notes/)

# apicurio-github-actions
A repository to hold custom GitHub Actions used for Apicurio projects.

## Available Actions

### 🐳 [Save Docker Image](./save-docker-image)
Save a Docker image to a tar file for later use, caching, or distribution.

**Usage:**
```yaml
- name: Save Docker Image
  uses: apicurio/apicurio-github-actions/save-docker-image@v1
  with:
    image-name: 'my-app'
    tag: 'latest'
    output-path: './my-app.tar'
```

## Publishing to GitHub Actions Marketplace

To publish these actions to the GitHub Actions Marketplace:

1. Create a new release with a version tag (e.g., `v1.0.0`)
2. Each action directory contains the necessary `action.yml` file
3. The actions will be available as `apicurio/apicurio-github-actions/<action-name>@<version>`

## Contributing

1. Create a new directory for your action
2. Add an `action.yml` file with the action definition
3. Include a comprehensive `README.md` with usage examples
4. Add tests in `.github/workflows/` to validate the action
5. Update this main README.md to list the new action

## Testing

Each action includes automated tests that run on:
- Push to action-specific files
- Pull requests affecting action files
- Manual workflow dispatch

Run tests locally or view results in the Actions tab.
