rem --
rem -- init()
rem --
rem -- Initialize a new ImageView view. This displays a full-screen image
rem -- to the user.
rem --
sub init()
  rem --
  rem -- Set initial control values.
  rem --
  m.rImage = m.top.findNode("rImage")
  m.pBackgroundImage = m.top.findNode("pBackgroundImage")
  m.bsLoading = m.top.findNode("bsLoading")
  m.aFadeBackground = m.top.findNode("aFadeBackground")

  rem --
  rem -- Configure customized options.
  rem --
  crex = ReadCache(m, "config")
  m.bsLoading.uri = crex.LoadingSpinner
  m.aFadeBackground.duration = crex.AnimationTime

  rem --
  rem -- Set the width and height of the background and image controls
  rem -- to be the width and height of the screen.
  rem --
  resolution = m.top.getScene().currentDesignResolution
  m.rImage.width = resolution.width
  m.rImage.height = resolution.height
  m.pBackgroundImage.width = resolution.width
  m.pBackgroundImage.height = resolution.height
  m.bsLoading.poster.width = 96
  m.bsLoading.poster.height = 96

  rem --
  rem -- Configure resolution-specific settings for the view.
  rem --
  if resolution.resolution = "FHD"
    rem --
    rem -- Configure for 1920x1080.
    rem --
    m.bsLoading.translation = [912, 492]
  else
    rem --
    rem -- Configure for 1280x720.
    rem --
    m.bsLoading.translation = [592, 312]
  end if

  rem --
  rem -- Observe the fields we need to monitor for changes.
  rem --
  m.pBackgroundImage.observeField("loadStatus", "onBackgroundStatus")
  m.aFadeBackground.observeField("state", "onFadeBackgroundState")
end sub

rem *******************************************************
rem ** EVENT HANDLERS
rem *******************************************************

rem --
rem -- onDataChange()
rem --
rem -- Called when the data has been changed to a new value. Update the
rem -- image to use this new data value.
rem --
sub onDataChange()
  m.pBackgroundImage.uri = BestMatchingUrl(ParseJson(m.top.data))
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
  if m.pBackgroundImage.loadStatus = "ready" or m.pBackgroundImage.loadStatus = "failed"
    rem --
    rem -- Fade the background image in.
    rem --
    m.pBackgroundImage.opacity = 0
    m.pBackgroundImage.visible = true
    m.aFadeBackground.control = "start"
  end if
end sub

rem --
rem -- onFadeBackgroundState()
rem --
rem -- The background fade animation has completed. Make sure the spinner
rem -- is stopped and no longer visible at all.
rem --
sub onFadeBackgroundState()
  if m.aFadeBackground.state = "stopped"
    m.bsLoading.control = "stop"
    m.bsLoading.visible = false
  end if
end sub
