rem --
rem -- init()
rem --
rem -- Initialize a new Crex Scene component. This handles all the screen
rem -- logic for the application. It is in charge of the stack of views
rem -- as well as the main menu content.
rem --
sub init()
  rem --
  rem -- Set initial control values.
  rem --
  m.gMainMenu = m.top.findNode("gMainMenu")
  m.pBackground = m.top.findNode("pBackground")
  m.mbMenuBar = m.top.findNode("mbMenuBar")
  m.bsLoading = m.top.findNode("bsLoading")
  m.aFadeMenu = m.top.findNode("aFadeMenu")
  m.task = invalid

  rem --
  rem -- Configure any customized settings.
  rem --
  crex = ReadCache(m, "config")
  m.bsLoading.uri = crex.LoadingSpinner
  m.aFadeMenu.duration = crex.AnimationTime

  rem --
  rem -- Configure UI elements for the screen size we are running.
  rem --
  resolution = m.top.getScene().currentDesignResolution
  m.pBackground.width = resolution.width
  m.pBackground.height = resolution.height
  if resolution.resolution = "FHD"
    rem --
    rem -- Configure for 1920x1080.
    rem --
    m.mbMenuBar.translation = [0, 960]
    m.mbMenuBar.width = 1920
    m.mbMenuBar.height = 120
    m.bsLoading.translation = [912, 492]
    m.bsLoading.poster.width = 96
    m.bsLoading.poster.height = 96
  else
    rem --
    rem -- Configure for 1280x720.
    rem --
    m.mbMenuBar.translation = [0, 640]
    m.mbMenuBar.width = 1280
    m.mbMenuBar.height = 80
    m.bsLoading.translation = [592, 312]
    m.bsLoading.poster.width = 96
    m.bsLoading.poster.height = 96
  end if

  rem --
  rem -- Observe the fields we need to monitor for changes.
  rem --
  m.top.observeField("focusedChild", "onFocusedChildChange")
  m.pBackground.observeField("loadStatus", "onBackgroundStatus")
  m.mbMenuBar.observeField("selectedButtonIndex", "onSelectedButtonIndex")

  rem --
  rem -- Show the loading spinner.
  rem --
  m.bsLoading.control = "start"
end sub

rem *******************************************************
rem ** METHODS
rem *******************************************************


rem *******************************************************
rem ** EVENT HANDLERS
rem *******************************************************

rem --
rem -- onDataChange()
rem --
rem -- Called when the data has been changed to a new value. Load the
rem -- content from the new URL specified by the data.
rem --
sub onDataChange()
  m.task = CreateObject("roSGNode", "URLTask")
  m.task.url = ParseJson(m.top.data)
  m.task.observeField("content", "onContentChanged")
  m.task.control = "RUN"
end sub

rem --
rem -- onContentChanged()
rem --
rem -- The URL download task has finished and provided content for
rem -- use to parse. We then populate the UI with the information.
rem --
sub onContentChanged()
  rem --
  rem -- Try to parse the retrieved content as JSON.
  rem --
  m.config = invalid
  if m.task.success = true
    m.config = parseJSON(m.task.content)
  end if

  if m.config <> invalid
    rem --
    rem -- Configure UI elements with the configuration options.
    rem --
    m.pBackground.uri = BestMatchingUrl(m.config.BackgroundImage)

    rem --
    rem -- Build a list of buttons provided in the config.
    rem --
    buttons = []
    for each b in m.config.buttons
      buttons.Push(b.Title)
    end for

    rem --
    rem -- Set the menu bar's buttons to those we found in the config.
    rem --
    m.mbMenuBar.buttons = buttons
  else
    LogMessage("Failed to load menu content.")
  end if
end sub

rem --
rem -- onFocusedChildChange()
rem --
rem -- The focus has changed to or from us. If it was set to us then make
rem -- sure the item list control has the actual focus.
rem --
sub onFocusedChildChange()
  if m.top.IsInFocusChain() and not m.mbMenuBar.HasFocus()
    m.mbMenuBar.SetFocus(true)
  end if
end sub

rem --
rem -- onBackgroundStatus()
rem --
rem -- Called once the background image has finished loading. At this
rem -- point we can show the menu bar and hide the loading spinner.
rem --
sub onBackgroundStatus()
  rem --
  rem -- Verify that the image either loaded or failed. We don't want
  rem -- to activate during the loading state.
  rem --
  if m.pBackground.loadStatus = "ready" or m.pBackground.loadStatus = "failed"
    rem --
    rem -- Prepare the main menu controls for fading in.
    rem --
    m.gMainMenu.opacity = 0
    m.gMainMenu.visible = true
    m.mbMenuBar.setFocus(true)

    rem --
    rem -- Start fading in the menu and fading out the spinner.
    rem --
    m.aFadeMenu.control = "start"
  end if
end sub

rem --
rem -- onFadeMenuState()
rem --
rem -- The menu fade animation has completed. Make sure the spinner
rem -- is stopped and no longer visible at all.
rem --
sub onFadeMenuState()
  if m.aFadeMenu.state = "stopped"
    m.bsLoading.control = "stop"
    m.bsLoading.visible = false
  end if
end sub

rem --
rem -- onSelectedButtonIndex()
rem --
rem -- A menu button has been selected. Show the selected item on
rem -- the screen.
rem --
sub onSelectedButtonIndex()
  item = m.config.Buttons[m.mbMenuBar.selectedButtonIndex]

  m.top.crexScene.callFunc("ShowItem", item.Action)
end sub
