suite 'cc.inplace.InplaceEditor', ->
  InplaceEditor = cc.inplace.InplaceEditor

  mockEl = (tag) ->
    document.createElement(tag)

  test 'Shoud create inplace editor', (done) ->
    built = false

    builder =
      build: ->
        built = true
      hangListeners: ->
        done() if built

    editor = new InplaceEditor(builder, {})
    editor.apply(mockEl('input'), mockEl('h1'))
