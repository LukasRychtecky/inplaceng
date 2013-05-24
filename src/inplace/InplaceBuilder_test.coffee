suite 'cc.inplace.InplaceBuilder', ->
  InplaceBuilder = cc.inplace.InplaceBuilder

  builder = null
  dom = null
  view = null
  viewParent = null
  field = null
  fieldParent = null

  mockEl = (tag, parent = null) ->
    el = document.createElement(tag)
    el.parentElement = parent
    el.events = {}
    el.addEventListener = (type, proxy, capture) ->
      el.events[type] = proxy
    el

  mockField = (parent, form) ->
    f = mockEl('input', parent)
    f.form = form
    f

  injectAddListener = (el) ->
    el.events = {}
    el.addEventListener = (type, proxy, capture) ->
      el.events[type] = proxy

  setup ->
    viewParent = mockEl('div')
    view = mockEl('h1', viewParent)

    fieldParent = mockEl('div')
    field = mockField(fieldParent, mockEl('form'))

    dom = new goog.dom.DomHelper(document)
    builder = new InplaceBuilder(dom)

  suite '#build', ->

    test 'Should build an icon', ->
      builder.build(field, view)
      icon = viewParent.firstChild
      assert.equal(icon.tagName, 'I')
      assert.equal(icon.className, 'icon-pencil')
      assert.equal(icon.title, 'Edit')

    test 'Should build cancel button', ->
      builder.build(field, view)
      button = fieldParent.lastChild
      assert.equal(button.tagName, 'BUTTON')
      icon = button.firstChild
      assert.equal(icon.tagName, 'I')
      assert.equal(icon.className, 'icon-remove')

    test 'Should build save button', ->
      builder.build(field, view)
      button = fieldParent.firstChild
      assert.equal(button.tagName, 'BUTTON')
      icon = button.firstChild
      assert.equal(icon.tagName, 'I')
      assert.equal(icon.className, 'icon-ok')

    test 'Should not build save button, alreasy exists', ->
      saveButton = mockEl('button', fieldParent)
      fieldParent.appendChild(saveButton)
      fieldParent.querySelector = (selector) ->
        if selector is '.inplace-save' then saveButton else null
      saveButton.className = 'inplace-save'

      builder.build(field, view)
      assert.equal(fieldParent.childNodes.length, 2)

    test 'Should take styles from editable element', ->
      styles =
        heigth: '1em'
        font: 'Arial 1em'
        color: '#000'
        background: 'none'
      goog.style.setStyle(view, key, val) for key, val of styles
      builder.build(field, view)
      assert.equal(goog.style.getStyle(field, key), val) for key, val of styles

  suite '#hangListeners', ->

    setup ->
      builder.build(field, view)

      for el in [viewParent.firstChild, fieldParent.firstChild, fieldParent.lastChild]
        injectAddListener(el)

    test 'Should hang click listener on an icon', (done) ->
      beh =
        showEditor: ->
          done()

      builder.hangListeners(beh)
      icon = viewParent.firstChild
      icon.events['click']()

    test 'Should save editing on enter', (done) ->
      beh =
        saveEditing: ->
          done()

      builder.hangListeners(beh)
      field.events['keyup'](keyCode: goog.events.KeyCodes.ENTER)

    test 'Should cancel editing on escape', (done) ->
      beh =
        cancelEditing: ->
          done()

      builder.hangListeners(beh)
      field.events['keyup'](keyCode: goog.events.KeyCodes.ESC)

    test 'Should skip others keys', ->
      beh =
        cancelEditing: ->
          assert.fail('Should not be called!')
        saveEditing: ->
          assert.fail('Should not be called!')

      builder.hangListeners(beh)
      field.events['keyup'](keyCode: goog.events.KeyCodes.SPACE)

    test 'Should save editing by clicking on save button', (done) ->
      beh =
        saveEditing: ->

      builder.hangListeners(beh)
      e =
        preventDefault: ->
          done()

      assert.isFalse(fieldParent.firstChild.events['click'](e))

    test 'Should cancel editing by clicking in cancel button', (done) ->
      beh =
        cancelEditing: ->

      builder.hangListeners(beh)
      e =
        preventDefault: ->
          done()

      assert.isFalse(fieldParent.lastChild.events['click'](e))
