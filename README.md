# Development Container - Install Azure CLI Extensions

See [Development Containers](https://github.com/devcontainers/spec) for details.

## To Use

Reference this repository in your devcontainer.json file.

For example, to add the "ml" extension:

```jsonc
  "features": {
    "azure-cli": "latest",
    "wyserai/devcontainer-features/azextension@v0.0.8": {
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

## Release Flow

```sh
git tag v0.0.8
git push origin refs/tags/v0.0.8
```

Push a tag (eg `v0.0.8`) to your repo, which will trigger the [deploy-features action](https://github.com/microsoft/publish-dev-container-features-action) in this repo's [`deploy-features.yml` workflow file](https://github.com/microsoft/dev-container-features-template/blo    b/main/.github/workflows/deploy-features.yml).

Assets will be compressed and added as a release artifact with the name `devcontainer-features.tgz`.

## License

See the [LICENSE](LICENSE.md) file for license rights and limitations (MIT).
