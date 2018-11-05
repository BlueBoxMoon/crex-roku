rem --
rem -- init()
rem --
rem -- Initialize a new MenuButton instance. This object handles the visual
rem -- display of a single button in the MenuBar.
rem --
sub init()
  rem --
  rem -- Set initial control values.
  rem --
  m.lblText = m.top.findNode("lblText")

  rem --
  rem -- Configure the button images.
  rem --
  config = ReadCache(m, "config")
  m.focusedTextColor = config.MenuBar.FocusedTextColor
  m.unfocusedTextColor = config.MenuBar.UnfocusedTextColor

  rem --
  rem -- Observe the fields we need to monitor for changes.
  rem --
  m.top.observeField("focusedChild", "onFocusedChildChange")
end sub

rem *******************************************************
rem ** EVENT HANDLERS
rem *******************************************************

rem --
rem -- onSizeChange()
rem --
rem -- Called when our size has changed. Re-layout all the
rem -- elements of the button to fit the size.
rem --
sub onSizeChange()
  rem --
  rem -- Set the basic attributes of the button.
  rem --
  m.lblText.text = m.top.text
  m.lblText.height = m.top.height
  m.lblText.translation = [0, 0]

  rem --
  rem -- Determine the width of the button.
  rem --
  m.lblText.width = 0
  width = m.lblText.boundingRect().width
  m.lblText.width = width

  rem --
  rem -- Finally, update our boundingWidth so that the MenuBar knows how
  rem -- much space this button is taking up.
  rem --
  m.top.boundingWidth = width

  rem --
  rem -- Make sure all the colors and such are set.
  rem --
  onFocusedChildChange()
end sub

rem --
rem -- onFocusedChildChange()
rem --
rem -- Called when we receive or lose focus. Update the UI elements to
rem -- match.
rem --
sub onFocusedChildChange()
  if m.top.HasFocus()
    m.lblText.color = m.FocusedTextColor
  else
    m.lblText.color = m.UnfocusedTextColor
  end if
end sub
