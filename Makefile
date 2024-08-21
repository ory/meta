format: .bin/ory .bin/shfmt node_modules  # formats the source code
	echo formatting ...
	.bin/ory dev headers copyright --type=open-source
	.bin/shfmt --write .
	npm exec -- prettier --write .

help:  # shows all available Make commands
	cat Makefile | grep '^[^ ]*:' | grep -v '^\.bin/' | grep -v '^node_modules' | grep -v '.SILENT:' | grep -v help | sed 's/:.*#/#/' | column -s "#" -t

licenses: .bin/licenses node_modules  # checks open-source licenses
	.bin/licenses

.bin/licenses: Makefile
	curl https://raw.githubusercontent.com/ory/ci/master/licenses/install | sh

test: .bin/shellcheck .bin/shfmt node_modules  # runs all linters
	echo running tests ...
	find . -name '*.sh' | xargs .bin/shellcheck
	echo Verifying formatting ...
	.bin/shfmt --list .

.bin/ory: Makefile
	echo installing Ory CLI ...
	curl https://raw.githubusercontent.com/ory/meta/master/install.sh | bash -s -- -b .bin ory v0.1.48
	touch .bin/ory

.bin/shellcheck: Makefile
	echo installing Shellcheck ...
	curl -sSL https://github.com/koalaman/shellcheck/releases/download/stable/shellcheck-stable.linux.x86_64.tar.xz | tar xJ
	mkdir -p .bin
	mv shellcheck-stable/shellcheck .bin
	rm -rf shellcheck-stable
	touch .bin/shellcheck   # update the timestamp so that Make doesn't re-install the file over and over again

.bin/shfmt: Makefile
	echo "Installing Shellfmt ..."
	mkdir -p .bin
	if [ "$$(uname -s)" = "Darwin" ] && [ "$$(uname -m)" = "arm64" ]; then \
		echo " - detected macOS ARM64"; \
		curl -sSL https://github.com/mvdan/sh/releases/download/v3.9.0/shfmt_v3.9.0_darwin_arm64 -o .bin/shfmt; \
	elif [ "$$(uname -s)" = "Linux" ] && [ "$$(uname -m)" = "x86_64" ]; then \
		echo " - detected Linux AMD64"; \
		curl -sSL https://github.com/mvdan/sh/releases/download/v3.9.0/shfmt_v3.9.0_linux_amd64 -o .bin/shfmt; \
	else \
		echo " - unsupported architecture: $$(uname -s) $$(uname -m)"; \
		exit 1; \
	fi
	chmod +x .bin/shfmt
	touch .bin/shfmt 

node_modules: package.json package-lock.json
	echo installing Node dependencies ...
	npm ci
	touch node_modules  # update timestamp so that Make doesn't reinstall it over and over


.SILENT:
.DEFAULT_GOAL := help
