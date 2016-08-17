class CustomDataTypeLink extends CustomDataType
	getCustomDataTypeName: ->
		# "custom:solution.custom-types-test.types.link"
		"custom:base.custom-data-type-link.link"

	getCustomDataTypeNameLocalized: ->
		$$("custom.data.type.link.name")

	isEmpty: (data, top_level_data, opts) ->
		if data[@name()]?.url
			false
		else
			true

	isVisible: (mode) ->
		if mode == "expert"
			false
		else
			super(mode)

	renderCustomDataOptionsInDatamodel: (custom_settings) ->
		if custom_settings.add_timestamp?.value
			new Label(text: $$("custom.data.type.link.setting.schema.rendered_options.with_date"))
		else
			new Label(text: $$("custom.data.type.link.setting.schema.rendered_options.without_date"))

	renderEditorInput: (data, top_level_data, opts) ->
		# console.error @, data, top_level_data, opts, @name(), @fullName()
		if not data[@name()]
			cdata = {}
			data[@name()] = cdata
		else
			cdata = data[@name()]

		if not cdata.url
			cdata.url = ""

		if @supportsInline()
			@__renderEditorInputInline(cdata)
		else
			@__renderEditorInputPopover(cdata)

	supportsInline: ->
		@getCustomMaskSettings().editor_style?.value == "inline"

	supportsTimestamp: ->
		@getCustomSchemaSettings().add_timestamp?.value

	__renderEditorInputPopover: (cdata) ->

		@__layout = new HorizontalLayout
			left: {}
			right:
				content:
					loca_key: "custom.data.type.link.edit.button"
					onClick: (ev, btn) =>
						@showEditPopover(btn, cdata)

		@__updateDisplayLink(cdata)
		@__layout


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

	__updateDisplayLink: (cdata) ->
		btn = @__renderButtonByData(cdata)
		@__layout.replace(btn, "left")

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

	showEditPopover: (btn, cdata) ->

		cdata_form = new Form
			data: cdata
			onDataChanged: =>
				@__updateDisplayLink(cdata)
				@__setEditorFieldStatus(cdata, cdata_form.getFieldsByName("url")[0])
			fields: @__getEditorFields()
		.start()

		new Popover
			element: btn
			pane:
				header_left: new LocaLabel(loca_key: "custom.data.type.link.edit.modal.title")
				content: cdata_form
		.show()

	__getEditorFields: ->
		[
			type: Input
			undo_and_changed_support: false
			form:
				label: $$("custom.data.type.link.modal.form.url.label")
			placeholder: $$("custom.data.type.link.modal.form.url.placeholder")
			name: "url"
		,
			name: "text"
			type: MultiInput
			undo_and_changed_support: false
			form:
				label: $$("custom.data.type.link.modal.form.text.label")
			control: ez5.loca.getLanguageControl()
		,
			if @supportsTimestamp()
				name: "datetime"
				type: DateTime
				undo_and_changed_support: false
				form:
					label: $$("custom.data.type.link.modal.form.datetime.label")
		]

	renderDetailOutput: (data, top_level_data, opts) ->
		@__renderButtonByData(data[@name()])

	# returns "empty", "ok", "invalid"
	getDataStatus: (cdata) ->
		status = do ->
			if not isEmpty(cdata.url.trim())
				loc = CUI.parseLocation(cdata.url)
				if loc and loc.hostname.match(/.+\..{2,}$/)
					return "ok"
				else
					return "invalid"

			else
				if isEmpty(ez5.loca.getBestFrontendValue(cdata.text)?.trim()) and
					isEmpty(cdata.url.trim()) and
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
			text: ez5.loca.getBestFrontendValue(cdata.text) or goto_url
		.DOM

	getCheckInfo: (mode) ->
		info = [ $$("custom.data.type.link.valid_url") ]
		info

	getSaveData: (data, save_data, opts) ->
		console.debug data, save_data, opts

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
				save_data[@name()] =
					url: cdata.url.trim()
					text: cdata.text
					datetime: cdata.datetime

CustomDataType.register(CustomDataTypeLink)
