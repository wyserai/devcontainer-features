# Development Container - Install Azure CLI Extensions

## Release Flow

```sh
git tag v0.1
git push origin refs/tags/v0.1
```

Push a tag (eg `v0.0.1`) to your repo, which will trigger the [deploy-features action](https://github.com/microsoft/publish-dev-container-features-action) in this repo's [`deploy-features.yml` workflow file](https://github.com/microsoft/dev-container-features-template/blob/main/.github/workflows/deploy-features.yml).

Assets will be compressed and added as a release artifact with the name `devcontainer-features.tgz`.

## To Use

```jsonc
  "features": {
    "azure-cli": "latest",
    "wyserai/devcontainer-features/azextension@v0.1": {
      "names": [
        "ml"
      ]
    }
  }
```
