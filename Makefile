format: .bin/shfmt node_modules  # formats the source code
	echo formatting ...
	.bin/shfmt --write .
	node_modules/.bin/prettier --write .

help:  # shows all available Make commands
	cat Makefile | grep '^[^ ]*:' | grep -v '^\.bin/' | grep -v '^node_modules' | grep -v '.SILENT:' | grep -v help | sed 's/:.*#/#/' | column -s "#" -t

test: .bin/shellcheck .bin/shfmt node_modules  # runs all linters
	echo running tests ...
	find . -name '*.sh' | xargs .bin/shellcheck
	echo Verifying formatting ...
	.bin/shfmt --list .
	node_modules/.bin/prettier --check .

.bin/shellcheck: Makefile
	echo installing Shellcheck ...
	curl -sSL https://github.com/koalaman/shellcheck/releases/download/stable/shellcheck-stable.linux.x86_64.tar.xz | tar xJ
	mkdir -p .bin
	mv shellcheck-stable/shellcheck .bin
	rm -rf shellcheck-stable
	touch .bin/shellcheck   # update the timestamp so that Make doesn't re-install the file over and over again

.bin/shfmt: Makefile
	echo installing Shellfmt ...
	mkdir -p .bin
	curl -sSL https://github.com/mvdan/sh/releases/download/v3.5.1/shfmt_v3.5.1_linux_amd64 -o .bin/shfmt
	chmod +x .bin/shfmt

node_modules: Makefile
	echo installing Prettier ...
	npm ci
	touch node_modules  # update timestamp so that Make doesn't reinstall it over and over


.SILENT:
.DEFAULT_GOAL := help
