PLUGIN_NAME = custom-data-type-link
INSTALL_FILES = \
	$(WEB)/l10n/cultures.json \
	$(WEB)/l10n/de-DE.json \
	$(WEB)/l10n/en-US.json \
	$(WEB)/l10n/es-ES.json \
	$(WEB)/l10n/it-IT.json \
	$(WEB)/custom-data-type-link.js \
	CustomDataTypeLink.config.yml

L10N_FILES = l10n/custom-data-type-link.csv

COFFEE_FILES = \
	src/webfrontend/CustomDataTypeLink.coffee

all: build

include ./base-plugins.make

build: code $(L10N)

code: $(JS)

clean: clean-base

wipe: wipe-base