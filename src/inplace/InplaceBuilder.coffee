goog.provide 'cc.inplace.InplaceBuilder'

goog.require 'goog.dom.DomHelper'
goog.require 'goog.style'
goog.require 'goog.events'
goog.require 'goog.events.KeyCodes'
goog.require 'goog.dom.forms'

class cc.inplace.InplaceBuilder

  ###*
    @constructor
    @param {goog.dom.DomHelper} dom
    @param {Object.<string, *>=} options
  ###
  constructor: (@dom, options = {'title': 'Edit'}) ->
    for key, val of options
      goog.object.setIfUndefined(options, key, val)
    @options = options

  ###*
    @type {goog.dom.DomHelper}
  ###
  dom: null

  ###*
    @type {boolean}
  ###
  editing: false

  ###*
    @type {Element}
  ###
  container: null

  ###*
    @type {Element}
  ###
  icon: null

  ###*
    @type {Element}
  ###
  saveButton: null

  ###*
    @type {Element}
  ###
  cancelButton: null

  ###*
    @type {Element}
  ###
  view: null

  ###*
    @type {Element}
  ###
  edit: null

  ###*
    @type {HTMLFormElement}
  ###
  form: null

  ###*
    @type {Element}
  ###
  field: null

  ###*
    @type {Object.<string, *>}
  ###
  @options

  ###*
    @param {Element} field
    @param {Element} viewEl
  ###
  build: (field, viewEl) ->
    @view = viewEl.parentElement
    @edit = field.parentElement
    @field = field
    @form = @field.form

    @icon = @buildIcon('icon-pencil')
    @view.appendChild(@icon)
    @icon.title = @options.title

    @saveButton = @edit.querySelector('.inplace-save')
    unless @saveButton
      @saveButton = @buildButton('icon-ok')
      @edit.appendChild(@saveButton)

    @cancelButton = @buildButton('icon-remove')
    @edit.appendChild(@cancelButton)

    @applyStyles(viewEl)

  ###*
    @param {cc.inplace.InplaceBehaviour} behaviour
  ###
  hangListeners: (behaviour) ->
    origVal = null
    field = @field
    edit = @edit
    view = @view

    rollBackFieldValue = ->
      goog.dom.forms.setValue(field, origVal)
      origVal = null

    goog.events.listen @icon, goog.events.EventType.CLICK, ->
      origVal = goog.dom.forms.getValue(field)
      behaviour.showEditor(edit, view, field)

    goog.events.listen field, goog.events.EventType.KEYUP, (e) ->
      switch e.keyCode
        when goog.events.KeyCodes.ENTER then behaviour.saveEditing(edit, view, origVal, goog.dom.forms.getValue(field), field)
        when goog.events.KeyCodes.ESC then behaviour.cancelEditing(edit, view)
        else

    goog.events.listen @saveButton, goog.events.EventType.CLICK, (e) ->
      e.preventDefault()
      behaviour.saveEditing(edit, view, origVal, goog.dom.forms.getValue(field))
      false

    goog.events.listen @cancelButton, goog.events.EventType.CLICK, (e) ->
      e.preventDefault()
      rollBackFieldValue()
      behaviour.cancelEditing(edit, view)
      false

  ###*
    @protected
    @param {string} iconClass
    @param {string=} btnClass
    @return {Element}
  ###
  buildButton: (iconClass, btnClass = '') ->
    btn = @dom.createDom('button', 'class': btnClass)
    btn.appendChild(@buildIcon(iconClass))
    btn

  ###*
    @protected
    @param {string} iconClass
    @return {Element}
  ###
  buildIcon: (iconClass) ->
    @dom.createDom('i', iconClass)

  ###*
    @protected
    @param {Element} viewEl
  ###
  applyStyles: (viewEl) ->
    for key in ['fontStyle', 'fontVariant', 'fontWeight', 'fontSize', 'lineHeight', 'fontFamily', 'color', 'background', 'margin']
      goog.style.setStyle(@field, key, goog.style.getComputedStyle(viewEl, key))

