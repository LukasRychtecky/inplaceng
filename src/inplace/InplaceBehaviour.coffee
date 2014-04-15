goog.provide 'cc.inplace.InplaceBehaviour'

goog.require 'goog.events'
goog.require 'goog.style'
goog.require 'goog.object'
goog.require 'goog.userAgent'

class cc.inplace.InplaceBehaviour

  ###*
    @constructor
    @param {Window} win
    @param {Object=} options
  ###
  constructor: (win, options = {}) ->
    goog.object.extend(options, 'preventRedirectText': 'Changes will not be saved. Do you want to continue?')
    @opts = options
    that = @
    goog.events.listen win, goog.events.EventType.BEFOREUNLOAD, ->
      if that.editing then options['preventRedirectText'] else undefined

  ###*
    @type {boolean}
  ###
  editing: false

  ###*
    @param {Element} edit
    @param {Element} view
    @param {Element} field
  ###
  showEditor: (edit, view, field) ->
    goog.style.setElementShown(view, false)
    goog.style.setElementShown(edit, true)
    field.focus() unless goog.userAgent.IE # IE fails on focusing the input
    @editing = true

  ###*
    @param {Element} edit
    @param {Element} view
    @param {Element|null|undefined=} field
  ###
  hideEditor: (edit, view, field = null) ->
    goog.style.setElementShown(edit, false)
    goog.style.setElementShown(view, true)
    field.blur() if field?
    @editing = false

  ###*
    @param {Element} edit
    @param {Element} view
    @param {*} origValue
    @param {*} curValue
    @param {Element|null|undefined=} field
  ###
  saveEditing: (edit, view, origValue, curValue, field = null) ->
    if origValue isnt curValue
      if @opts.onSave
        @opts.onSave edit, view, origValue, curValue, field, =>
          @hideEditor(edit, view, field)
#       send form
    else
      @hideEditor(edit, view, field)

  ###*
    @param {Element} edit
    @param {Element} view
  ###
  cancelEditing: (edit, view) ->
    @hideEditor(edit, view)
