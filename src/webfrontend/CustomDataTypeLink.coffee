###
 * easydb-custom-data-type-link
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class CustomDataTypeLink extends CustomDataType
	getCustomDataTypeName: ->
		# "custom:solution.custom-types-test.types.link"
		"custom:base.custom-data-type-link.link"

	# returns a map for search tokens, containing name and value strings.
	getQueryFieldBadge: (data) =>
		# console.error "getQueryFieldBadge", data
		if data["#{@name()}:unset"]
			value = $$("text.column.badge.without")
		else
			value = data[@name()]

		name: @nameLocalized()
		value: value

	getCustomDataTypeNameLocalized: ->
		$$("custom.data.type.link.name")

	isEmpty: (data, top_level_data, opts={}) ->

		if opts.mode == "expert"
			# check plain input in search
			return CUI.util.isEmpty(data[@name()]?.trim())

		if data[@name()]?.url
			false
		else
			true

	getCustomDataOptionsInDatamodelInfo: (custom_settings) ->
		tags = []
		pre = "custom.data.type.link.setting.schema.rendered_options."

		if custom_settings.title?.type
			tags.push(pre+"title."+custom_settings.title.type)

		if custom_settings.add_timestamp?.value
			tags.push(pre+"with_date")
		else
			tags.push(pre+"without_date")

		($$(tag) for tag in tags)


	initData: (data) ->
		if not data[@name()]
			cdata = {}
			data[@name()] = cdata
		else
			cdata = data[@name()]

		if not cdata.url
			cdata.url = ""

		cdata

	renderFieldAsGroup: (data, top_level_data, opts) ->
		if opts.fieldRenderType == 'editor' and @supportsInline()
			return true
		else
			return false

	supportsFacet: ->
		true

	getFacet: (opts) ->
		opts.field = @
		new CustomDataTypeLinkFacet(opts)

	# provide a sort function to sort your data
	getSortFunction: ->
		(a, b) =>
			CUI.util.compareIndex(a[@name()]?.hostname or 'zzz', b[@name()]?.hostname or 'zzz')

	# returns markup to display in expert search
	renderSearchInput: (data, opts={}) ->
		# console.warn "CustomDataTypeLink.renderSearchInput", data, opts
		search_token = new SearchToken
			column: @
			data: data
			fields: opts.fields
		.getInput().DOM

	getFieldNamesForSearch: ->
		@getFieldNames()

	getFieldNamesForSuggest: ->
		@getFieldNames()

	getFieldNames: ->

		field_names = [
			@fullName()+".tld"
			@fullName()+".url"
			@fullName()+".text_plain"
		]

		for lang in ez5.session.getPref("search_languages")
			field_names.push(@fullName()+".text."+lang)

		field_names

	renderEditorInput: (data, top_level_data, opts) ->

		# console.error @, data, top_level_data, opts, @name(), @fullName()
		cdata = @initData(data)

		if @supportsInline()
			@__renderEditorInputInline(cdata)
		else
			@__renderEditorInputPopover(cdata)

	supportsInline: ->
		@getCustomMaskSettings().editor_style?.value != "popover"

	supportsTimestamp: ->
		@getCustomSchemaSettings().add_timestamp?.value

	getTitleType: ->
		@getCustomSchemaSettings().title?.type or "text-l10n"

	__renderEditorInputPopover: (cdata) ->

		layout = new CUI.HorizontalLayout
			left: {}
			right:
				content:
					loca_key: "custom.data.type.link.edit.button"
					onClick: (ev, btn) =>
						@showEditPopover(cdata, btn, layout)

		@__updateDisplayLink(cdata, layout)
		layout


	__renderEditorInputInline: (cdata) ->

		fields = @__getEditorFields()

		btn = @__renderButtonByData(cdata)
		preview = new DataFieldProxy(
			form:
				label: $$("custom.data.type.link.preview.label")
			element: btn
		)

		fields.push(preview)

		form = new CUI.Form
			data: cdata
			maximize_horizontal: true
			onDataChanged: =>
				preview.replace(@__renderButtonByData(cdata))
				@__triggerFormChanged(form)
			fields: fields
		.start()


		form

	__updateDisplayLink: (cdata, layout) ->
		btn = @__renderButtonByData(cdata)
		layout.replace(btn, "left")

	__triggerFormChanged: (form) ->
		CUI.Events.trigger
			node: form
			type: "editor-changed"

	# returns a search filter suitable to the search array part
	# of the request, the data to be search is in data[key] plus
	# possible additions, which should be stored in key+":<additional>"

	getSearchFilter: (data, key=@name()) ->

		if data[key+":unset"]
			filter =
				type: "in"
				fields: [ @fullName()+".url" ]
				in: [ null ]
			filter._unnest = true
			filter._unset_filter = true
			return filter

		filter = super(data, key)
		if filter
			return filter

		if CUI.util.isEmpty(data[key])
			return

		val = data[key]
		[str, phrase] = Search.getPhrase(val)

		switch data[key+":type"]
			when "token", "fulltext", undefined
				filter =
					type: "match"
					# mode can be fulltext, token or wildcard
					mode: data[key+":mode"]
					fields: @getFieldNamesForSearch()
					string: str
					phrase: phrase

			when "field"
				filter =
					type: "in"
					fields: @getFieldNamesForSearch()
					in: [ str ]

		# console.error "search filter", data, key, data[key+":type"], filter

		filter



	showEditPopover: (cdata, element, layout) ->

		form = new CUI.Form
			data: cdata
			fields: @__getEditorFields()
			onDataChanged: =>
				@__triggerFormChanged(form)
		.start()

		new CUI.Popover
			element: element
			onHide: =>
				@__updateDisplayLink(cdata, layout)
				CUI.Events.trigger
					node: layout
					type: "editor-changed"
			pane:
				header_left: new LocaLabel(loca_key: "custom.data.type.link.edit.modal.title")
				content: form
		.show()

	__getEditorFields: ->
		fields = [
			type: CUI.Input
			undo_and_changed_support: false
			form:
				label: $$("custom.data.type.link.modal.form.url.label")
			placeholder: $$("custom.data.type.link.modal.form.url.placeholder")
			name: "url"
			checkInput: (url) => @__isValidUrl(url)
		]

		switch @getTitleType()
			when "text-l10n"
				fields.push
					type: CUI.MultiInput
					name: "text"
					undo_and_changed_support: false
					form:
						label: $$("custom.data.type.link.modal.form.text.label")
					control: ez5.loca.getLanguageControl()
			when "text"
				fields.push
					type: CUI.Input
					name: "text_plain"
					undo_and_changed_support: false
					form:
						label: $$("custom.data.type.link.modal.form.text.label")

		if @supportsTimestamp()
			fields.push
				type: CUI.DateTime
				name: "datetime"
				undo_and_changed_support: false
				form:
					label: $$("custom.data.type.link.modal.form.datetime.label")

		fields

	renderDetailOutput: (data, top_level_data, opts) ->
		cdata = @initData(data)
		@__renderButtonByData(cdata)

	# returns "empty", "ok", "invalid"
	getDataStatus: (cdata) ->
		status = do =>
			if not CUI.isPlainObject(cdata)
				return "empty"

			if not CUI.util.isEmpty(cdata.url?.trim())
				if @__isValidUrl(cdata.url)
					return "ok"
				else
					return "invalid"

			else
				if not @getLinkText(cdata) and
					CUI.util.isEmpty(cdata.url?.trim()) and
					not cdata.datetime
						return "empty"

			return "invalid"

		# console.debug "checking...", cdata.url, status
		return status

	__isValidUrl: (url) ->
		location = CUI.parseLocation(url)
		return !!location and location.hostname.match(/.+\..{2,}$/)


	__renderButtonByData: (cdata) ->

		switch @getDataStatus(cdata)
			when "empty"
				return new CUI.EmptyLabel(text: $$("custom.data.type.link.edit.no_link")).DOM
			when "invalid"
				return new CUI.EmptyLabel(text: $$("custom.data.type.link.edit.no_valid_link")).DOM

		goto_url = CUI.parseLocation(cdata.url).url

		if cdata.datetime
			tt_text = $$("custom.data.type.link.url.tooltip_with_datetime", url: goto_url, datetime: ez5.format_date_and_time(cdata.datetime))
		else
			tt_text = $$("custom.data.type.link.url.tooltip", url: goto_url)

		tooltip_attrs =
			url: goto_url
			datetime: ez5.format_date_and_time(cdata.datetime)

		new CUI.ButtonHref
			appearance: "link"
			href: goto_url
			target: "_blank"
			tooltip:
				markdown: true
				text: tt_text
			text: @getLinkText(cdata) or goto_url
		.DOM

	getLinkText: (cdata) ->
		# console.debug "getLinkText", cdata, @getTitleType(), @getCustomSchemaSettings()
		switch @getTitleType()
			when "none"
				txt = ""
			when "text"
				txt = cdata.text_plain
			when "text-l10n"
				txt = ez5.loca.getBestFrontendValue(cdata.text)

		if not CUI.util.isEmpty(txt)
			txt.trim()
		else
			txt

	getCheckInfo: (mode) ->
		info = [ $$("custom.data.type.link.valid_url") ]
		info

	getSaveData: (data, save_data, opts) ->
		# console.debug data, save_data, opts

		if opts.demo_data
			return {
				url: "www.example.com"
				text: "Example"
				datetime:
					value: ""
			}

		cdata = data[@name()] or data._template?[@name()]

		switch @getDataStatus(cdata)
			when "invalid"
				throw new InvalidSaveDataException()
			when "empty"
				save_data[@name()] = null
			when "ok"
				save_data[@name()] = @__buildData(cdata)


	__buildData: (cdata) ->
		switch @getTitleType()
			when "text-l10n"
				text = cdata.text
			when "text"
				text_plain = cdata.text_plain

		url = cdata.url.trim()

		location = CUI.parseLocation(url)

		hostnameParts = location.hostname.split(".")

		return (
			url: url
			hostname: location.hostname
			tld: hostnameParts[hostnameParts.length - 1]
			text: text
			text_plain: text_plain
			datetime: cdata.datetime
			_fulltext:
				l10ntext: text
				text: text_plain
				string: url
		)

	hasRenderForSort: ->
		return true

	sortExtraOpts: ->
		return [
			text: $$("custom.data.type.link.modal.form.url.label")
			value: "url"
		]

	getCSVDestinationFields: (csvImporter) ->
		opts =
			csvImporter: csvImporter
			field: @

		[ new CustomDataTypeLinkColumnCSVImporterDestinationField(opts) ]


CustomDataType.register(CustomDataTypeLink)
