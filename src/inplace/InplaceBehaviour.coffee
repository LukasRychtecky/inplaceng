goog.provide 'cc.inplace.InplaceBehaviour'

goog.require 'goog.events'
goog.require 'goog.style'
goog.require 'goog.object'

class cc.inplace.InplaceBehaviour

  ###*
    @constructor
    @param {Window} win
    @param {Object=} options
  ###
  constructor: (win, options = {}) ->
    goog.object.extend(options, preventRedirectText: 'Changes will not be saved. Do you want to continue?')
    @opts = options
    that = @
    goog.events.listen win, goog.events.EventType.BEFOREUNLOAD, ->
      if that.editing then options.preventRedirectText else ''

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
    field.focus()
    @editing = true

  ###*
    @param {Element} edit
    @param {Element} view
  ###
  hideEditor: (edit, view) ->
    goog.style.setElementShown(edit, false)
    goog.style.setElementShown(view, true)
    @editing = false

  ###*
    @param {Element} edit
    @param {Element} view
  ###
  saveEditing: (edit, view, origValue, curValue) ->
    if origValue isnt curValue
      if @opts.onSave
        that = @
        @opts.onSave edit, view, origValue, curValue, ->
          that.hideEditor(edit,view)
#       send form
    else
      @hideEditor(edit, view)

  ###*
    @param {Element} edit
    @param {Element} view
  ###
  cancelEditing: (edit, view) ->
    @hideEditor(edit, view)
