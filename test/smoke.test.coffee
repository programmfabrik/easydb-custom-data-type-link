###
 * easydb-custom-data-type-link
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

describe 'CustomDataTypeLink', () ->

  # create a new instance
  datatype = new CustomDataTypeLink

  it 'should have a custom data type name', () ->
    expect(datatype.getCustomDataTypeName()).toBe 'custom:base.custom-data-type-link.link'

  it 'should define editor fields', () ->
    fields = datatype.__getEditorFields()
    for field in fields
      if field
        expect(field.type).toBeTruthy()

