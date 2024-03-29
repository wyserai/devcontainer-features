# Development Container Features

See [Development Containers](https://github.com/devcontainers/spec) for details.

Adds:

- Install Azure CLI Extensions
- Install Pulumi CLI
- Install Azure Function Tools 4
- Microsoft's TrueType core fonts
- strongSwan IPsec VPN

## Install Azure CLI Extensions

Reference this repository in your devcontainer.json file.

For example, to add the "ml" extension:

```jsonc
  "features": {
    "ghcr.io/devcontainers/features/azure-cli:1": {},
    "https://github.com/wyserai/devcontainer-features/releases/download/v0.3.0/devcontainer-feature-azextension.tgz": {
      "names": [
        "ml"
      ]
    }
  }
```

### Options

| Options Id | Description                  | Type  |
|------------|------------------------------|-------|
| names      | List of Azure CLI extensions | array |


## Install Pulumi CLI

Reference this repository in your devcontainer.json file.

```jsonc
  "features": {
    "ghcr.io/devcontainers/features/azure-cli:1": {},
    "https://github.com/wyserai/devcontainer-features/releases/download/v0.3.0/devcontainer-feature-pulumi.tgz": {}
  }
```

## Install Azure Function Tools 4

Reference this repository in your devcontainer.json file.

```jsonc
  "features": {
    "https://github.com/wyserai/devcontainer-features/releases/download/v0.3.0/devcontainer-feature-azurefunctools.tgz": {}
  }
```

## Install Microsoft's TrueType core fonts

Reference this repository in your devcontainer.json file.

```jsonc
  "features": {
    "https://github.com/wyserai/devcontainer-features/releases/download/v0.4.0/devcontainer-feature-msttcorefonts.tgz": {}
  }
```

## Install strongSwan IPsec VPN

Reference this repository in your devcontainer.json file.

```jsonc
  "features": {
    "https://github.com/wyserai/devcontainer-features/releases/download/v0.4.0/devcontainer-feature-strongswan.tgz": {}
  }
```

## Release Flow

```sh
git tag v0.4.0
git push origin refs/tags/v0.4.0
```

Push a tag (eg `v0.4.0`) to your repo, which will trigger the [deploy-features action](https://github.com/microsoft/publish-dev-container-features-action) in this repo's [`deploy-features.yml` workflow file](https://github.com/microsoft/dev-container-features-template/blob/main/.github/workflows/deploy-features.yml).

Assets will be compressed and added as a release artifact with the name `devcontainer-features.tgz`.

## License

See the [LICENSE](LICENSE.md) file for license rights and limitations (MIT).
