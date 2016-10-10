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

