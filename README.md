# meta

A place for reusable code, templates, and documentation required for getting a repository in ORY working.

## Documentation

### Updating Templates

This repository contains templates for things like the software license, security policy, contributing guidelines,
code of conduct, and so on.

You can find the repository templates in [templates/repository](./templates/repository). Libraries (e.g. Dockertest)
and servers (e.g. Kratos) share templates from the [common](./templates/repository/common) directory. Additionally,
servers copy files from [server](./templates/repository/server) and libraries from the
[library](./templates/repository/library) directory.

To update the repositories simply make your changes. Once merged to master, they will be published using a GitHub Action.
