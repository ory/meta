# meta

A place for reusable code, templates, and documentation required for getting a
repository in ORY working.

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


## Github Sync action

The scripts in "/scripts" serve to synchronize all ORY repositories to a common template, including README, CONTRIBUTING, COC, LICENCE, Github Workflows with close to zero manual interaction.
Depending on repository type (server, library, action) specific templates can be copied as well. 
The project names, links to documentation ect. are being substituted for each project in "/scripts/sync.sh". 
For more details please refer to the documentation within the scripts.

#### Documentation of sync.yml
```yml
name: Synchronize Repositories

on:                                   
  # action can be manually triggered 
  workflow_dispatch:
  # action is triggered on push to the following paths
  push:
    paths:
      - 'templates/**'
      - 'scripts/sync*'
      - 'package.json'
      - '.github/workflows/sync.yml'
    branches:
      - master

jobs:
  milestone:
    name: Synchronize Repositories
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v2
        
        # installs moreutils on the Action worker node to use the sponge function
      - name: Install sponge
        run: sudo apt-get update -y && sudo apt-get install -y moreutils 
        
        # Ssh-agent action to get a ssh key with privileges to repos outside of /meta in this case the repositories you want to sync.
      - uses: webfactory/ssh-agent@v0.4.1                                 
        with:
          ssh-private-key: ${{ secrets.SSH_PRIVATE_KEY }}

        # Synchronize server script
      - name: Synchronize ORY Kratos
        
        # runs the sync-server bash script in the Action workers CLI with arguments: $1=workdir (the repository you want to sync) $2=branch $3=humanName   
        run: ./scripts/sync-server.sh ory/kratos master Kratos
        
        # sets the required github token as enviromental variable
        env:
          GITHUB_TOKEN: ${{ secrets.GH_TOKEN_AENEASR }}

        # runs the sync-server bash script in the Action workers CLI with arguments: $1=workdir (the repository you want to sync) $2=branch $3=humanName   
      - name: Synchronize ORY Kratos SelfService UI React Native Example
        run: |
          ./scripts/sync-library.sh ory/kratos-selfservice-ui-react-native master "Kratos SelfService UI React Native Example"
        env:
          GITHUB_TOKEN: ${{ secrets.GH_TOKEN_AENEASR }}
```
