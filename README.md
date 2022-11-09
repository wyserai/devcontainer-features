# Development Container - Install Azure CLI Extensions

See [Development Containers](https://github.com/devcontainers/spec) for details.

## To Use

Reference this repository in your devcontainer.json file.

For example, to add the "ml" extension:

```jsonc
  "features": {
    "azure-cli": "latest",
    "wyserai/devcontainer-features/azextension@v0.4": {
      "names": [
        "ml"
      ]
    }
  }
```

## Release Flow

```sh
git tag v0.4
git push origin refs/tags/v0.4
```
Push a tag (eg `v0.4`) to your repo, which will trigger the [deploy-features action](https://github.com/microsoft/publish-dev-container-features-action) in this repo's [`deploy-features.yml` workflow file](https://github.com/microsoft/dev-container-features-template/blo    b/main/.github/workflows/deploy-features.yml).

Assets will be compressed and added as a release artifact with the name `devcontainer-features.tgz`.

## License

See the [LICENSE](LICENSE.md) file for license rights and limitations (MIT).
