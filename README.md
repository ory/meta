# meta

A place for reusable code, templates, and documentation required for getting a
repository in Ory working.

## Documentation

### Updating Templates

This repository contains templates for things like the software license,
security policy, contributing guidelines, code of conduct, and so on.

You can find the repository templates in
[templates/repository](./templates/repository). Libraries (e.g. Dockertest) and
servers (e.g. Kratos) share templates from the
[common](./templates/repository/common) directory. Additionally, servers copy
files from [server](./templates/repository/server) and libraries from the
[library](./templates/repository/library) directory.

To update the repositories simply make your changes. Once merged to master, they
will be published using a GitHub Action.

### Updating pinned actions

The workflow templates in
[common](./templates/repository/common/.github/workflows) pin every action to a
full commit SHA, with the release or branch in a trailing comment. Dependabot
and Renovate do not update these pins, so update them by hand:

1. Find the commit for the new release with
   `git ls-remote https://github.com/<owner>/<repo> 'refs/tags/<tag>^{}'`. For an
   action pinned to a branch, such as `ory/ci` at `# master`, use the branch
   head.
2. Review the changes between the old and the new commit.
3. Replace the SHA and the comment. For the license workflow, change the
   template and `.github/workflows/licenses.yml` together.
4. Run `scripts/check-workflows.sh`.

## Github Sync action

The [meta scripts](https://github.com/ory/meta/tree/master/scripts) synchronize
all Ory repositories to a common template including README, CONTRIBUTING, COC,
SECURITY, LICENCE and Github Workflows with close to zero manual interaction.

Depending on repository type (server, library, action) specific templates can be
copied as well.

The project names, links to documentation ect. are being substituted for each
project in [sync.sh](https://github.com/ory/meta/blob/master/scripts/sync.sh).
For more details please refer to the documentation within the
[scripts](https://github.com/ory/meta/tree/master/scripts).

To run the sync script locally, open a Bash terminal and copy the respective
commands from [sync.sh](https://github.com/ory/meta/blob/master/scripts/sync.sh)
into the terminal. For example, to see the changes made by all sync jobs:

```
source scripts/sync.sh
workspace=$(create_workspace)
GITHUB_SHA=12345
replicate_all "$workspace" keep
```

Then `cd $workspace` to see all repositories with the uncommitted changes made
by the sync script. To test committing, replace the last line with this one:

```
replicate_all "$workspace" commit
```

To test syncing problems with a single repo:

```
source scripts/sync.sh
workspace=$(create_workspace)
GITHUB_SHA=12345
replicate ory/hydra server "Hydra" "$workspace" "keep"
```
