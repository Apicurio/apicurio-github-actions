# Publishing Apicurio GitHub Actions to the Marketplace

This guide explains how to publish the custom GitHub Actions in this repository to the GitHub Actions Marketplace.

## 📋 Prerequisites

Before publishing, ensure:

1. **Repository is public** - GitHub Actions Marketplace only accepts public repositories
2. **Actions are tested** - All actions have passing tests in `.github/workflows/`
3. **Documentation is complete** - Each action has a comprehensive `README.md`
4. **Proper versioning** - Follow semantic versioning (e.g., `v1.0.0`)

## 🚀 Publishing Process

### Step 1: Prepare for Release

1. **Test all actions locally or in CI**:
   ```bash
   # Run the test workflow manually
   gh workflow run test-save-docker-image.yml
   ```

2. **Verify action metadata**:
   - Each action has a valid `action.yml` file
   - Branding is configured (icon and color)
   - Description is clear and concise
   - All inputs/outputs are documented

### Step 2: Create a Release

#### Option A: Using GitHub CLI
```bash
# Create and push a new tag
git tag v1.0.0
git push origin v1.0.0

# The release workflow will automatically create the release
```

#### Option B: Using GitHub Web Interface
1. Go to the repository on GitHub
2. Click "Releases" → "Create a new release"
3. Choose or create a new tag (e.g., `v1.0.0`)
4. Fill in the release title and description
5. Click "Publish release"

#### Option C: Using Workflow Dispatch
1. Go to Actions → Release Workflow
2. Click "Run workflow"
3. Enter the tag name (e.g., `v1.0.0`)
4. Click "Run workflow"

### Step 3: Marketplace Publication

Once a release is created with a proper tag:

1. **Automatic Publication**: GitHub will automatically detect the action and make it available in the Marketplace
2. **Marketplace Listing**: The action will appear at:
   ```
   https://github.com/marketplace/actions/save-docker-image
   ```
3. **Usage Reference**: Users can reference it as:
   ```yaml
   uses: apicurio/apicurio-github-actions/save-docker-image@v2
   ```

## 📦 Version Management

### Semantic Versioning
Follow semantic versioning for releases:
- `v1.0.0` - Major release (breaking changes)
- `v1.1.0` - Minor release (new features, backward compatible)
- `v1.0.1` - Patch release (bug fixes)

### Major Version Tags
The release workflow automatically creates/updates major version tags:
- `v1.0.0` creates/updates `v1`
- `v2.0.0` creates/updates `v2`

This allows users to reference stable major versions:
```yaml
uses: apicurio/apicurio-github-actions/save-docker-image@v2  # Always latest v2.x.x
uses: apicurio/apicurio-github-actions/save-docker-image@v2.0.0  # Specific version
```

## 🔍 Action Structure

Each action should follow this structure:

```
action-name/
├── action.yml          # Action definition (required)
├── README.md          # Documentation (required)
└── (optional files)   # Scripts, configs, etc.
```

### action.yml Requirements

```yaml
name: 'Action Name'                    # Required: Display name
description: 'Action description'      # Required: Brief description
author: 'Apicurio'                    # Optional but recommended

branding:                             # Required for Marketplace
  icon: 'icon-name'                   # Feather icon name
  color: 'color-name'                 # Brand color

inputs:                               # Define inputs
  input-name:
    description: 'Input description'
    required: true|false
    default: 'default-value'

outputs:                              # Define outputs
  output-name:
    description: 'Output description'
    value: ${{ steps.step-id.outputs.value }}

runs:                                 # Execution configuration
  using: 'composite'                  # For shell-based actions
  steps:
    - shell: bash
      run: |
        # Action logic here
```

## 🧪 Testing Actions

### Local Testing
Test actions locally using [act](https://github.com/nektos/act):

```bash
# Install act
curl https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash

# Run workflow locally
act -j test-save-docker-image
```

### CI Testing
The repository includes automated tests:
- **test-save-docker-image.yml** - Tests the save-docker-image action
- Tests run on push, PR, and manual dispatch
- Include positive and negative test cases

## 📊 Marketplace Best Practices

### 1. Clear Naming
- Use descriptive action names
- Follow the pattern: `verb-noun` (e.g., `save-docker-image`)

### 2. Comprehensive Documentation
- Include usage examples
- Document all inputs and outputs
- Provide real-world use cases
- Add troubleshooting section

### 3. Proper Branding
- Choose appropriate Feather icons
- Use consistent colors across actions
- Maintain Apicurio branding

### 4. Version Strategy
- Start with `v1.0.0` for first release
- Use pre-release tags for testing (`v1.0.0-beta.1`)
- Maintain backward compatibility in minor versions

## 🔗 Useful Links

- [GitHub Actions Marketplace](https://github.com/marketplace?type=actions)
- [Creating Actions Documentation](https://docs.github.com/en/actions/creating-actions)
- [Marketplace Publishing Guide](https://docs.github.com/en/actions/creating-actions/publishing-actions-in-github-marketplace)
- [Feather Icons](https://feathericons.com/) (for branding)
- [Action Metadata Syntax](https://docs.github.com/en/actions/creating-actions/metadata-syntax-for-github-actions)

## 🆘 Troubleshooting

### Action Not Appearing in Marketplace
1. Ensure repository is public
2. Verify `action.yml` syntax is valid
3. Check that branding section is included
4. Wait up to 24 hours for indexing

### Version Tag Issues
1. Ensure tags follow semantic versioning (`vX.Y.Z`)
2. Check that release workflow has proper permissions
3. Verify git configuration in workflow

### Test Failures
1. Check action syntax and logic
2. Verify all required inputs are provided
3. Test with different input combinations
4. Check Docker availability in test environment

## 📝 Checklist for New Actions

- [ ] Create action directory with descriptive name
- [ ] Write `action.yml` with all required fields
- [ ] Include branding (icon and color)
- [ ] Create comprehensive `README.md`
- [ ] Add automated tests in `.github/workflows/`
- [ ] Test action locally and in CI
- [ ] Update main `README.md` to list new action
- [ ] Create release with semantic version tag
- [ ] Verify action appears in Marketplace
- [ ] Test action usage from external repository
