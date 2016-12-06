###
 * easydb-custom-data-type-link
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###

class Session

class Menu

class Pane

class DataField

class Select extends DataField

class Input extends DataField

class MultiInput extends DataField

class Output extends DataField

class FormButton extends DataField

class Icon

class CUI
  @XHR: () ->

  @parseLocation: () ->
    true

  @debug: () ->

class CustomDataType
  @register: (datatype) -> 

  getCustomSchemaSettings: () ->
    {}

  getCustomMaskSettings: () ->
    {}

$$ = () ->

console = {
  log: () ->
  debug: () ->
}

ez5 = {
  loca: { 
    getLanguageControl: () ->
      {}
  }
}
