# Development Container Features

See [Development Containers](https://github.com/devcontainers/spec) for details.

Adds:

- Install Azure CLI Extensions
- Install Pulumi CLI
- Install Azure Function Tools 4

## Install Azure CLI Extensions

Reference this repository in your devcontainer.json file.

For example, to add the "ml" extension:

```jsonc
  "features": {
    "ghcr.io/devcontainers/features/azure-cli:1": {},
    "wyserai/devcontainer-features/azextension@v0.1.0": {
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
    "wyserai/devcontainer-features/pulumi@v0.1.0": {}
  }
```

## Install Pulumi CLI

Reference this repository in your devcontainer.json file.

```jsonc
  "features": {
    "ghcr.io/devcontainers/features/azure-cli:1": {},
    "wyserai/devcontainer-features/azurefunctools@v0.1.0": {}
  }
```

## Release Flow

```sh
git tag v0.1.1
git push origin refs/tags/v0.1.1
```

Push a tag (eg `v0.1.1`) to your repo, which will trigger the [deploy-features action](https://github.com/microsoft/publish-dev-container-features-action) in this repo's [`deploy-features.yml` workflow file](https://github.com/microsoft/dev-container-features-template/blob/main/.github/workflows/deploy-features.yml).

Assets will be compressed and added as a release artifact with the name `devcontainer-features.tgz`.

## License

See the [LICENSE](LICENSE.md) file for license rights and limitations (MIT).
