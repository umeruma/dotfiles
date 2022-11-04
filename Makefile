DOTPATH    := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
CANDIDATES := $(wildcard .??*)
EXCLUSIONS := .DS_Store .git .gitmodules
DOTFILES   := $(filter-out $(EXCLUSIONS), $(CANDIDATES))
UNAME_S    := $(shell uname -s)

.DEFAULT_GOAL := help

all:

list: ## Show dot files in this repo
	@$(foreach val, $(DOTFILES), /bin/ls -dF $(val);)

deploy: ## Create symlink to home directory
	@echo '==> Start to deploy dotfiles to home directory.'
	@echo ''
	@$(foreach val, $(DOTFILES), ln -sfnv $(abspath $(val)) $(HOME)/$(val);)

test: ## Test dotfiles and init scripts
	@#DOTPATH=$(DOTPATH) bash $(DOTPATH)/etc/test/test.sh
	@echo "test is inactive temporarily"

update: ## Fetch changes for this repo
	git pull origin master
	git submodule init
	git submodule update
	git submodule foreach git pull origin master

install: clean deploy ## !!! Run clean, deploy, and install apps
	bash ./init/setup.sh
ifeq ($(UNAME_S),Linux)
	# @echo "Linux!"
	brew bundle --file=./linux/Brewfile
	sudo apt-get install hugo
endif
ifeq ($(UNAME_S),Darwin)
	# @echo "macOS!"
	launchctl setenv KITTY_CONFIG_DIRECTORY ~/.kitty/
	brew bundle --file=./macos/Brewfile
endif

install-extra: ## Install Extra apps
ifeq ($(UNAME_S),Linux)
	# @echo "Linux!"
endif
ifeq ($(UNAME_S),Darwin)
	# @echo "macOS!"
	brew bundle --file=./macos/Brewfile.Extra
endif

clean: ## Remove the dot files and this repo
	@echo 'Remove dot files in your home directory...'
	@-$(foreach val, $(DOTFILES), rm -vrf $(HOME)/$(val);)

defaults: ## Update defaults setting
ifeq ($(UNAME_S),Darwin)
	bash ./macos/defaults.sh
endif

help: ## Self-documented Makefile
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| sort \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
