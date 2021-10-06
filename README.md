# 🤩 META 🤩

A place for reusable code, templates, and documentation required for getting a
repository in Ory working. 

## Documentation 📃

### Updating Templates 📟

This repository contains templates for things like the software license,
security policy, contributing guidelines, code of conduct, and so on.

You can find the repository templates in
[templates/repository](./templates/repository). Libraries (e.g. Dockertest 🐳) and
servers (e.g. Kratos) share templates from the
[common](./templates/repository/common) directory. Additionally, servers copy
files from [server](./templates/repository/server) and libraries from the
[library](./templates/repository/library) directory.

To update the repositories simply make your changes. 
GitHub Action will be used to publish them as soon as they are merged to master.

## Github Sync Action 👨‍🏭⚡

The [meta scripts](https://github.com/ory/meta/tree/master/scripts) serve to
synchronize all Ory repositories to a common template, including README,
CONTRIBUTING, COC, SECURITY, LICENCE © and Github Workflows with close to zero
manual interaction.  
Depending on repository type (server, library, action) specific templates can be
copied as well.  
The project names, links to documentation ect. are being substituted for each
project in [sync.sh](https://github.com/ory/meta/blob/master/scripts/sync.sh).  
For more details please refer to the documentation within the
[scripts](https://github.com/ory/meta/tree/master/scripts). For more details on
the workflow please refer to the documentation within
[sync.yml](https://github.com/ory/meta/blob/master/.github/workflows/sync.yml)
