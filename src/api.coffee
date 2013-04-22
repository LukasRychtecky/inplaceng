goog.provide 'cc.start'

goog.require 'cc.inplace.InplaceBuilder'
goog.require 'cc.inplace.InplaceBehaviour'
goog.require 'cc.inplace.InplaceEditor'
goog.require 'goog.dom.DomHelper'

###*
  @param {Document} dom
  @param {Window} win
###
cc.start = (dom, win) ->

  ###*
    @param {string} fieldSelector
    @param {string} viewSelector
  ###
  attachInplace: (fieldSelector, viewSelector, opts) ->
    builder = new cc.inplace.InplaceBuilder(new goog.dom.DomHelper(dom))
    behaviour = new cc.inplace.InplaceBehaviour(win, opts)
    editor = new cc.inplace.InplaceEditor(builder, behaviour)
    editor.apply(dom.querySelector(fieldSelector), dom.querySelector(viewSelector))

goog.provide 'cc.api'

cc.api = cc.start document, window

goog.exportSymbol 'cc.api.attachInplace', cc.api.attachInplace
