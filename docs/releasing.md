# Releasing Software

```shell script
bash <(curl -s https://raw.githubusercontent.com/ory/meta/master/scripts/release.sh) v1.2.3
```

## Defining Release Config

For the scripts to work, the project must be located in a directory structure that
reflects the GitHub organisation and repository name, for example: `path/to/ory/hydra`.

### Goreleaser

### `.goreleaser.yml`

These configuration options should be included in every `.goreleaser.yml` config.
Make sure you set env vars and `go mod download` and run e.g. packr2 and other tools first:

```yaml
env:
  - GO111MODULE=on

before:
  hooks:
    - go mod download
    # - go install github.com/gobuffalo/packr/v2/packr2
    # - packr2
```

Tag `-alpha.1` and other pre-release tags as pre-release on GitHub:

```yaml
release:
  prerelease: auto
```

Name snapshot releases `-next`:

```yaml
snapshot:
  name_template: "{{ .Tag }}-next"
```

If you create a new goreleaser config, you may also want to create the following
empty GitHub repositories:

Build and publish on Docker. You need to create a repository on Docker Hub first!

```yaml
# Build dockerfiles
dockers:
  -
    dockerfile: Dockerfile
    binaries:
      - $PROJECT_NAME
    image_templates:
      - "oryd/$PROJECT_NAME:v{{ .Major }}"
      - "oryd/$PROJECT_NAME:v{{ .Major }}.{{ .Minor }}"
      - "oryd/$PROJECT_NAME:v{{ .Major }}.{{ .Minor }}.{{ .Patch }}"
      - "oryd/$PROJECT_NAME:latest"
```

If you add [Scoop](https://scoop.sh) (Homebrew for Windows)
you must also create a GitHub repository under the `ory` org named
`scoop-$PROJECT_NAME` (e.g. `scoop-hydra`).

```yaml
scoop:
  bucket:
    owner: ory
    name: scoop-$PROJECT_NAME
  homepage:  https://www.ory.sh
  commit_author:
    name: aeneasr
    email: aeneas@ory.sh
```

If you add [Homebrew](https://brew.sh)
you must also create a GitHub repository under the `ory` org named
`homebrew-$PROJECT_NAME` (e.g. `homebrew-hydra`).

```yaml
brews:
  -
    github:
      owner: ory
      name: homebrew-$PROJECT_NAME
    ids:
      - <<REPLACE-WITH-ARCHIVE-ID>>
    homepage:  https://www.ory.sh
    commit_author:
      name: aeneasr
      email: aeneas@ory.sh

```

### Update install script

When you have finalized changes to the `.goreleaser.yml`, run:

```shell
$ GO111MODULES=off go get -u github.com/goreleaser/godownloader
$ godownloader --repo=$(basename $(dirname $(pwd)))/$(basename $(pwd)) > ./install.sh
```

**Attention:** The config file for goreleaser must be on GitHub already!

### CircleCI

Define CI Environment Variables:

* [ ] Make sure you set `GITHUB_TOKEN` in the project's CI config.
* [ ] Make sure you set `MAILCHIMP_API_KEY` in the project's CI config.
* [ ] Make sure you set `DOCKER_USER` in the project's CI config.
* [ ] Make sure you set `DOCKER_TOKEN` in the project's CI config.

In the project's CircleCI config (`.circleci/config.yml`), use the following
workflow (please use an appropriate `$VERSION`):

```yaml
orbs:
  goreleaser: ory/goreleaser@0.1.7
  slack: circleci/slack@3.4.2

workflows:
  my-workflow:
    jobs:

      -
        goreleaser/test:
          filters:
            tags:
              only: /.*/
      -
        goreleaser/release:
          requires:
            - goreleaser/test
          filters:
            branches:
              ignore: /.*/
            tags:
              only: /.*/

      -
        goreleaser/newsletter-draft:
          chimp-list: f605a41b53
          chimp-segment: 6478605
          requires:
            - goreleaser/release
          filters:
            tags:
              only: /.*/
      -
        slack/approval-notification:
          message: Pending approval
          channel: release-automation
          requires:
            - goreleaser/newsletter-draft
          filters:
            tags:
              only: /.*/
      -
        newsletter-approval:
          type: approval
          requires:
            - goreleaser/newsletter-draft
          filters:
            tags:
              only: /.*/
      -
        goreleaser/newsletter-send:
          chimp-list: f605a41b53
          requires:
            - newsletter-approval
          filters:
            tags:
              only: /.*/
```
