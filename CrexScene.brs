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
  m.gViews = m.top.findNode("gViews")
  m.aFadeView = m.top.findNode("aFadeView")
  m.config = invalid

  rem --
  rem -- Load the config file and cache it.
  rem --
  crex = ReadCrexConfig()
  WriteCache(m, "config", crex)

  rem --
  rem -- Set configured values
  rem --
  m.aFadeView.duration = crex.AnimationTime

  rem --
  rem -- Observe the fields we need to monitor for changes.
  rem --
  m.aFadeView.observeField("state", "onFadeViewState")

  LogMessage("Launching with Root URL: " + crex.ApplicationRootUrl)

  rem --
  rem -- Default template and root url.
  rem --
  ShowItem({Template: crex.ApplicationRootTemplate, Data: crex.ApplicationRootUrl})
end sub

rem *******************************************************
rem ** METHODS
rem *******************************************************

rem --
rem -- PushView(view)
rem --
rem -- Push a new view onto the stack and set it as the primary
rem -- view with focus.
rem --
rem -- @param view The view to be pushed onto the view stack.
rem --
sub PushView(view as Object)
  rem --
  rem -- Set the view to scale around its center and make it invisible
  rem -- for the fade-in.
  rem --
  resolution = m.top.getScene().currentDesignResolution
  view.scaleRotateCenter = [resolution.width / 2, resolution.height / 2]
  view.opacity = 0

  rem --
  rem -- Set the id of the view so that our animations can target it.
  rem --
  view.id = "viewAnimationTarget"
  m.gViews.appendChild(view)

  rem --
  rem -- Remove all old animations.
  rem --
  while m.aFadeView.getChildCount() > 0
    m.aFadeView.removeChildIndex(0)
  end while

  rem --
  rem -- Configure the animation that handles fading in.
  rem --
  field = m.aFadeView.createChild("FloatFieldInterpolator")
  field.key = [0.0, 1.0]
  field.keyValue = [0.0, 1.0]
  field.fieldToInterp = "viewAnimationTarget.opacity"

  rem --
  rem -- Configure the animation that handles the subtle zoom effect.
  rem --
  field = m.aFadeView.createChild("Vector2DFieldInterpolator")
  field.key = [0.0, 0.5, 1.0]
  field.keyValue = [[0.95, 0.95], [1.0, 1.0], [1.0, 1.0]]
  field.fieldToInterp = "viewAnimationTarget.scale"

  rem --
  rem -- Notify the view to do final initialization.
  rem --
  view.callFunc("willShowView")

  rem --
  rem -- Indicate that we are fading in, then start the animation.
  rem --
  m.viewFadingIn = true
  m.aFadeView.control = "start"
end sub

rem --
rem -- PopActiveView()
rem --
rem -- Removes the top-most view from the stack and returns control
rem -- to the view behind it, or to the main menu if no views remain.
rem --
sub PopActiveView()
  rem --
  rem -- Tag the top-most view so our animations can target it.
  rem --
  m.gViews.getChild(m.gViews.getChildCount() - 1).id = "viewAnimationTarget"

  rem --
  rem -- Remove all existing animations.
  rem --
  while m.aFadeView.getChildCount() > 0
    m.aFadeView.removeChildIndex(0)
  end while

  rem --
  rem -- Configure the animation for fading the view out.
  rem --
  field = m.aFadeView.createChild("FloatFieldInterpolator")
  field.key = [0.0, 1.0]
  field.keyValue = [1.0, 0.0]
  field.fieldToInterp = "viewAnimationTarget.opacity"

  rem --
  rem -- Configure the animation for zooming the view out a bit.
  rem --
  field = m.aFadeView.createChild("Vector2DFieldInterpolator")
  field.key = [0.0, 0.0, 1.0]
  field.keyValue = [[1.0, 1.0], [1.0, 1.0], [0.95, 0.95]]
  field.fieldToInterp = "viewAnimationTarget.scale"

  rem --
  rem -- Set the flag indicating we are fading out and start the
  rem -- animations.
  rem --
  m.viewFadingIn = false
  m.aFadeView.control = "start"
end sub

rem --
rem -- ShowItem(item)
rem --
rem -- Shows an item on screen by parsing the object data and
rem -- creating the appropriate view to handle the item data.
rem --
rem -- @param item The item to be shown.
rem --
sub ShowItem(item as Object)
  rem --
  rem -- Each item should have a Template and Url property.
  rem --
  LogMessage(FormatJson(item))
  if item.Template <> invalid and item.Data <> invalid
    LogMessage("Navigation to " + item.Template)

    view = CreateObject("roSGNode", item.Template + "View")
    view.crexScene = m.top
    view.data = FormatJson(item.Data)
    PushView(view)
  end if
end sub

rem *******************************************************
rem ** EVENT HANDLERS
rem *******************************************************

rem --
rem -- onFadeViewState()
rem --
rem -- A fade animation for showing or hiding a view has completed. Do
rem -- final processing.
rem --
sub onFadeViewState()
  if m.aFadeView.state = "stopped"
    if m.viewFadingIn = true
      rem --
      rem -- If we were fading in, make sure the new view has focus
      rem -- and clear the animation identifier.
      rem --
      m.gViews.getChild(m.gViews.getChildCount() - 1).setFocus(true)
      m.gViews.getChild(m.gViews.getChildCount() - 1).id = ""
    else
      rem --
      rem -- If we were fading out, remove the old view.
      rem --
      m.gViews.removeChildIndex(m.gViews.getChildCount() - 1)

      rem --
      rem -- Set the focus to either the previous view on the stack
      rem -- or the main menu bar if no views remain.
      rem --
      m.gViews.getChild(m.gViews.getChildCount() - 1).setFocus(true)
    end if
  end if
end sub

rem --
rem -- onKeyEvent(key, press)
rem --
rem -- A key has been pressed or released on the remote. Do any
rem -- required processing to handle the event.
rem --
rem -- @param key The description of the key that was pressed or released.
rem -- @param press True if the key was pressed, false if it was released.
rem -- @returns True if the key was handled, false otherwise.
rem --
function onKeyEvent(key as string, press as boolean) as boolean
  rem --
  rem -- Consume all key events if we are currently transitioning
  rem -- between views.
  rem --
  if m.aFadeView.state = "running"
    return true
  end if

  if press
    if key = "back"
      rem --
      rem -- If the back button was pressed and we have views on
      rem -- the stack, then pop the active view. Otherwise allow
      rem -- the back button to exit out of the app.
      rem --
      if m.gViews.getChildCount() > 1
        PopActiveView()

        return true
      else
        return false
      end if
    end if
  end if

  return false
end function
