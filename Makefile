# Dotfiles are managed with GNU Stow: every top-level directory is a package
# that mirrors $HOME (e.g. hypr/.config/hypr/* -> ~/.config/hypr/*).

TARGET   ?= $(HOME)
PACKAGES ?= $(patsubst %/,%,$(wildcard */))
STOW     := stow --dir=$(CURDIR) --target=$(TARGET)

DEPS := stow hyprland hyprlock hyprpaper hyprpolkitagent hyprlauncher \
        quickshell pipewire pipewire-jack wireplumber python

.DEFAULT_GOAL := help
.PHONY: help install uninstall check deps reload

help: ## Show this help
	@grep -E '^[a-z-]+:.*## ' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*## "} {printf "  \033[1m%-10s\033[0m %s\n", $$1, $$2}'
	@echo
	@echo "  Packages: $(PACKAGES)"
	@echo "  Single package: make install PACKAGES=hypr"

install: ## Link packages into $HOME (restow, picks up newly added files)
	$(STOW) -v --restow $(PACKAGES)

uninstall: ## Remove the package symlinks from $HOME
	$(STOW) -v --delete $(PACKAGES)

check: ## Dry run: show what install would change and any conflicts
	$(STOW) -n -v --restow $(PACKAGES)

deps: ## Install required packages with pacman
	sudo pacman -S --needed $(DEPS)

reload: ## Reload Hyprland and restart hyprpaper
	hyprctl reload
	-pkill -x hyprpaper
	setsid -f hyprpaper >/dev/null 2>&1
