goog.provide 'cc.inplace.InplaceEditor'

class cc.inplace.InplaceEditor

  ###*
    @constructor
    @param {cc.inplace.InplaceBuilder} builder
    @param {cc.inplace.InplaceBehaviour} behaviour
  ###
  constructor: (@builder, @behaviour) ->

  ###*
    @param {Element} field
    @param {Element} viewEl
  ###
  apply: (field, viewEl) ->
    @builder.build(field, viewEl)
    @builder.hangListeners(@behaviour)
