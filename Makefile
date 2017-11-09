PLUGIN_NAME = custom-data-type-link

L10N_FILES = l10n/$(PLUGIN_NAME).csv
L10N_GOOGLE_KEY = 1Z3UPJ6XqLBp-P8SUf-ewq4osNJ3iZWKJB83tc6Wrfn0
L10N_GOOGLE_GID = 480475519
L10N2JSON = python easydb-library/tools/l10n2json.py

INSTALL_FILES = \
	$(WEB)/l10n/cultures.json \
	$(WEB)/l10n/de-DE.json \
	$(WEB)/l10n/en-US.json \
	$(WEB)/l10n/es-ES.json \
	$(WEB)/l10n/it-IT.json \
	$(JS) \
	CustomDataTypeLink.config.yml

COFFEE_FILES = src/webfrontend/CustomDataTypeLink.coffee \
	src/webfrontend/CustomDataTypeLinkFacet.coffee \
	src/webfrontend/CustomDataTypeLinkColumnCSVImporterDestinationField.coffee

all: build

include easydb-library/tools/base-plugins.make

build: code $(L10N)

code: $(JS)

clean: clean-base

wipe: wipe-base
