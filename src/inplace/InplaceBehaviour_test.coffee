suite 'cc.inplace.InplaceBehaviour', ->
  InplaceBehaviour = cc.inplace.InplaceBehaviour
  BEFORE_UNLOAD = goog.events.EventType.BEFOREUNLOAD

  beh = null
  win = null
  edit = null
  view = null
  field = null

  mockWindow = ->
    win =
      addEventListener: (type, proxy, capture) ->
        win.events[type] = proxy
      events: {}
    win

  mockEl = (done = null) ->
    el =
      style: {}
      focus: ->
        done() if done?
    el

  setup ->
    win = mockWindow()
    edit = mockEl()
    view = mockEl()
    field = mockEl()
    beh = new InplaceBehaviour(win)

  test 'Should prevent window reload and show a message', ->
    beh.showEditor(edit, view, field)
    beforeUnload = win.events[BEFORE_UNLOAD]()
    assert.isString(beforeUnload)
    assert.notEqual(beforeUnload.length, 0)

  test 'Should not prevent window reload', ->
    beh.showEditor(edit, view, field)
    beh.hideEditor(edit, view)
    beforeUnload = win.events[BEFORE_UNLOAD]()
    assert.isNull(beforeUnload)

  test 'Should show an editor and hide a view part', (done) ->
    beh.showEditor(edit, view, mockEl(done))
    assert.isTrue(goog.style.isElementShown(edit))
    assert.isFalse(goog.style.isElementShown(view))

  test 'Should hide an editor and show a view part', ->
    beh.showEditor(edit, view, field)
    beh.hideEditor(edit, view)
    assert.isTrue(goog.style.isElementShown(view))
    assert.isFalse(goog.style.isElementShown(edit))

  test 'Field value has not been changed should not save the value', ->
    value = ''
    beh = new InplaceBehaviour win, onSave: ->
      throw new Error('Should not be called!')

    beh.saveEditing(edit, view, value, value)
    assert.isTrue(goog.style.isElementShown(view))
    assert.isFalse(goog.style.isElementShown(edit))

  test 'Should save field value because the value has been changed', (done) ->
    beh = new InplaceBehaviour win, onSave: ->
      done()

    beh.saveEditing(edit, view, '', 'a')

  test 'Calcel editing should hide an editor and show a view part', ->
    beh.cancelEditing(edit, view)
    assert.isTrue(goog.style.isElementShown(view))
    assert.isFalse(goog.style.isElementShown(edit))
