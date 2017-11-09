class LinkColumnCSVImporterDestinationField extends ObjecttypeCSVImporterDestinationField
	initOpts: ->
		super()
		@mergeOpt "field",
			check: CustomDataTypeLink

	supportsHierarchy: ->
		false

	getFormat: ->
		"json"