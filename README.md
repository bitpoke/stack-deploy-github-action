# stack-deploy-github-action
Github action used to deploy a WordPress site to Stack.

# Usage

## Example workflow

```yaml
name: deploy

on: [push]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@master
    - name: Publish to Registry
      uses: elgohr/Publish-Docker-Github-Action@master
      id: build
      with:
        name: gcr.io/test-stack/foxes
        username: ${{ secrets.DOCKER_USERNAME }}
        password: ${{ secrets.DOCKER_PASSWORD }}
        registry: gcr.io
    - name: Deploy on Stack
      uses: presslabs/stack-deploy-github-action
      env:
        GOOGLE_CREDENTIALS: ${{ secrets.GOOGLE_CREDENTIALS }}
      with:
        namespace: proj-rl3e02
        wordpress: myawesomesite-2e304
        image: ${{ steps.build.output.tag }}
```

## Arguments

`image` - newly built docker image to deploy
`namespace` - the namespace in which you want to deploy
`wordpress` - wordpress resource name that you want to update
