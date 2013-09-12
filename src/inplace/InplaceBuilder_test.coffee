suite 'cc.inplace.InplaceBuilder', ->
  InplaceBuilder = cc.inplace.InplaceBuilder

  builder = null
  dom = null
  view = null
  viewParent = null
  field = null
  fieldParent = null
  styles = null

  mockEl = (tag, parent = null) ->
    el = document.createElement(tag)
    el.parentElement = parent
    el.events = {}
    el.addEventListener = (type, proxy, capture) ->
      el.events[type] = proxy
    el

  mockField = (parent, form) ->
    f = mockEl('input', parent)
    f.type = 'text'
    f.form = form
    f

  mockEvent = (onPreventDefault = null) ->
    e =
      preventDefault: ->
        onPreventDefault() if onPreventDefault?
    e

  injectAddListener = (el) ->
    el.events = {}
    el.addEventListener = (type, proxy, capture) ->
      el.events[type] = proxy

  clickedBtn = (btn, e = null) ->
    unless e?
      e = mockEvent()
    fieldParent[btn].events['click'](e)

  saveClick = (e = null) ->
    clickedBtn('firstChild', e)

  cancelClick = (e = null) ->
    clickedBtn('lastChild', e)

  changeInputValue = (val) ->
    field.value = val

  getIcon = ->
    viewParent.firstChild

  iconClick = (e = null) ->
    unless e?
      e = mockEvent()
    getIcon().events['click'](e)

  setup ->
    styles =
      height: '0px'
      fontFamily: 'Arial'
      fontSize: '1em'
      fontStyle: 'normal'
      fontVariant: 'normal'
      fontWeight: 'normal'
      lineHeight: 'normal'
      color: '#000'
      background: 'none'
      margin: '2em'

    viewParent = mockEl('div')
    view = mockEl('h1', viewParent)

    fieldParent = mockEl('div')
    field = mockField(fieldParent, mockEl('form'))

    dom = new goog.dom.DomHelper(document)
    builder = new InplaceBuilder(dom)

  suite '#build', ->

    test 'Should build an icon', ->
      builder.build(field, view)
      icon = getIcon()
      assert.equal(icon.tagName, 'I')
      assert.equal(icon.className, 'icon-pencil')
      assert.equal(icon.title, 'Edit')

    test 'Should build an icon with a custom title', ->
      title = 'Edit text'
      builder = new InplaceBuilder(dom, 'title': title)
      builder.build(field, view)
      icon = getIcon()
      assert.equal(icon.tagName, 'I')
      assert.equal(icon.className, 'icon-pencil')
      assert.equal(icon.title, title)

    test 'Should build cancel button', ->
      builder.build(field, view)
      button = fieldParent.lastChild
      assert.equal(button.tagName, 'BUTTON')
      assert.equal(button.className, '')
      icon = button.firstChild
      assert.equal(icon.tagName, 'I')
      assert.equal(icon.className, 'icon-remove')

    test 'Should build save button', ->
      builder.build(field, view)
      button = fieldParent.firstChild
      assert.equal(button.tagName, 'BUTTON')
      assert.equal(button.className, '')
      icon = button.firstChild
      assert.equal(icon.tagName, 'I')
      assert.equal(icon.className, 'icon-ok')

    test 'Should not build save button, already exists', ->
      saveButton = mockEl('button', fieldParent)
      fieldParent.appendChild(saveButton)
      fieldParent.querySelector = (selector) ->
        if selector is '.inplace-save' then saveButton else null
      saveButton.className = 'inplace-save'

      builder.build(field, view)
      assert.equal(fieldParent.childNodes.length, 2)

    test 'Should take styles from editable element', ->
      document.defaultView.getComputedStyle = ->
        styles

      goog.style.setStyle(view, key, val) for key, val of styles
      builder.build(field, view)
      goog.object.remove(styles, 'height')
      assert.equal(goog.style.getStyle(field, key), val) for key, val of styles
      assert.notEqual(goog.style.getStyle(field, 'height'), '0px')

  suite '#hangListeners', ->

    setup ->
      document.defaultView.getComputedStyle = ->
        styles

      builder.build(field, view)

      for el in [getIcon(), fieldParent.firstChild, fieldParent.lastChild]
        injectAddListener(el)

    test 'Should open editor', (done) ->
      beh =
        showEditor: ->
          done()

      builder.hangListeners(beh)
      iconClick()

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

      assert.isFalse(saveClick(mockEvent(done)))

    test 'Should cancel editing by clicking in cancel button', (done) ->
      beh =
        cancelEditing: ->

      builder.hangListeners(beh)

      assert.isFalse(cancelClick(mockEvent(done)))

    test 'Should rollback changed an input value on cancel editing', ->
      beh =
        showEditor: ->
        cancelEditing: ->
        saveEditing: ->

      builder.hangListeners(beh)
      newValue = 'Foo'

      iconClick()
      changeInputValue(newValue)
      cancelClick()
      iconClick()
      assert.notEqual(goog.dom.forms.getValue(field), newValue)
