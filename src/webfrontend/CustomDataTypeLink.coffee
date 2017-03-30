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

	getQueryFieldBadge: (data) =>
		# CUI.error "getQueryFieldBadge", data
		if data["#{@name()}:unset"]
			value = $$("text.column.badge.without")
		else
			value = data[@name()]

		name: @nameLocalized()
		value: value

	getCustomDataTypeNameLocalized: ->
		$$("custom.data.type.link.name")

	isEmpty: (data, top_level_data, opts) ->
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

	supportsFacet: ->
		false # true

	getFacet: (opts) ->
		opts.field = @
		new CustomDataTypeLinkFacet(opts)

	renderSearchInput: (data, opts={}) ->
		console.warn "CustomDataTypeLink.renderSearchInput", data, opts
		search_token = new SearchToken
			column: @
			data: data
			fields: opts.fields
		.getInput().DOM

	getFieldNamesForSuggest: ->
		[
			@fullName()+".tld"
			@fullName()+".text_plain"
			@fullName()+".text"
		]

	renderEditorInput: (data, top_level_data, opts) ->

		# console.error @, data, top_level_data, opts, @name(), @fullName()
		cdata = @initData(data)

		if @supportsInline()
			@__renderEditorInputInline(cdata)
		else
			@__renderEditorInputPopover(cdata)

	supportsInline: ->
		@getCustomMaskSettings().editor_style?.value == "inline"

	supportsTimestamp: ->
		@getCustomSchemaSettings().add_timestamp?.value

	getTitleType: ->
		@getCustomSchemaSettings().title?.type or "text-l10n"

	__renderEditorInputPopover: (cdata) ->

		layout = new HorizontalLayout
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

		cdata_form = new Form
			data: cdata
			onDataChanged: =>
				preview.replace(@__renderButtonByData(cdata))
				@__setEditorFieldStatus(cdata, cdata_form.getFieldsByName("url")[0])
			fields: fields
		.start()


		cdata_form

	__updateDisplayLink: (cdata, layout) ->
		btn = @__renderButtonByData(cdata)
		layout.replace(btn, "left")

	__setEditorFieldStatus: (cdata, element) ->
		# console.debug "setEditorFieldStatus", cdata, @getDataStatus(cdata), element
		switch @getDataStatus(cdata)
			when "invalid"
				element.addClass("cui-input-invalid")
			else
				element.removeClass("cui-input-invalid")

		Events.trigger
			node: element
			type: "editor-changed"

		@

	getSearchFilter: (data, key=@name(), fields) ->
		# console.debug "getSearchFilter for ", getObjectClass(@), @fullName(), data, key, fields
		filter = super(data, key)
		if filter
			return filter

		if not isEmpty(data[key])
			@_getSearchFilter(data, key)

	# use to get the filter if the value is notEmpty
	_getSearchFilter: (data, key) ->
		val = data[key]
		[str, phrase] = Search.getPhrase(val)

		filter =
			type: "match"
			mode: data[key+":mode"]
			fields: @getFieldNamesForSuggest()
			string: str
			phrase: phrase

		console.debug "str:", str, "phrase:", phrase, filter
		filter


	showEditPopover: (cdata, element, layout) ->

		cdata_form = new Form
			data: cdata
			onDataChanged: =>
				@__setEditorFieldStatus(cdata, layout)
			fields: @__getEditorFields()
		.start()

		new Popover
			element: element
			onHide: =>
				@__updateDisplayLink(cdata, layout)
				Events.trigger
					node: layout
					type: "editor-changed"
			pane:
				header_left: new LocaLabel(loca_key: "custom.data.type.link.edit.modal.title")
				content: cdata_form
		.show()

	__getEditorFields: ->
		fields = [
			type: Input
			undo_and_changed_support: false
			form:
				label: $$("custom.data.type.link.modal.form.url.label")
			placeholder: $$("custom.data.type.link.modal.form.url.placeholder")
			name: "url"
		]

		switch @getTitleType()
			when "text-l10n"
				fields.push
					type: MultiInput
					name: "text"
					undo_and_changed_support: false
					form:
						label: $$("custom.data.type.link.modal.form.text.label")
					control: ez5.loca.getLanguageControl()
			when "text"
				fields.push
					type: Input
					name: "text_plain"
					undo_and_changed_support: false
					form:
						label: $$("custom.data.type.link.modal.form.text.label")

		if @supportsTimestamp()
			fields.push
				type: DateTime
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

			if not isEmpty(cdata.url?.trim())
				loc = CUI.parseLocation(cdata.url)
				if loc and loc.hostname.match(/.+\..{2,}$/)
					return "ok"
				else
					return "invalid"

			else
				if not @getLinkText(cdata) and
					isEmpty(cdata.url?.trim()) and
					not cdata.datetime
						return "empty"

			return "invalid"

		# console.debug "checking...", cdata.url, status
		return status

	__renderButtonByData: (cdata) ->

		switch @getDataStatus(cdata)
			when "empty"
				return new EmptyLabel(text: $$("custom.data.type.link.edit.no_link")).DOM
			when "invalid"
				return new EmptyLabel(text: $$("custom.data.type.link.edit.no_valid_link")).DOM

		goto_url = CUI.parseLocation(cdata.url).url

		if cdata.datetime
			tt_text = $$("custom.data.type.link.url.tooltip_with_datetime", url: goto_url, datetime: ez5.format_date_and_time(cdata.datetime))
		else
			tt_text = $$("custom.data.type.link.url.tooltip", url: goto_url)

		tooltip_attrs =
			url: goto_url
			datetime: ez5.format_date_and_time(cdata.datetime)

		new ButtonHref
			appearance: "link"
			href: goto_url
			target: "_blank"
			tooltip:
				markdown: true
				text: tt_text
			text: @getLinkText(cdata) or goto_url
		.DOM

	getLinkText: (cdata) ->
		console.debug "getLinkText", cdata, @getTitleType(), @getCustomSchemaSettings()
		switch @getTitleType()
			when "none"
				txt = ""
			when "text"
				txt = cdata.text_plain
			when "text-l10n"
				txt = ez5.loca.getBestFrontendValue(cdata.text)

		if not isEmpty(txt)
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
				switch @getTitleType()
					when "text-l10n"
						text = cdata.text
					when "text"
						text_plain = cdata.text_plain

				url = cdata.url.trim()

				loc = CUI.parseLocation(url)

				parts = loc.hostname.split(".")

				save_data[@name()] =
					url: url
					hostname: loc.hostname
					tld: parts[parts.length - 1]
					text: text
					text_plain: text_plain
					datetime: cdata.datetime

CustomDataType.register(CustomDataTypeLink)
