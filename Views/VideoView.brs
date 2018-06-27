rem --
rem -- init()
rem --
rem -- Initialize a new Video view. This is used to watch a full-screen
rem -- video on the device.
rem --
sub init()
  rem --
  rem -- Set initial control values.
  rem --
  m.rBackground = m.top.findNode("rBackground")
  m.gResume = m.top.findNode("gResume")
  m.llResume = m.top.findNode("llResume")
  m.vVideo = m.top.findNode("vVideo")

  rem --
  rem -- Set configuration options.
  rem --
  config = ReadCache(m, "config")
  m.vVideo.trickPlayBar.filledBarBlendColor = config.VideoPlayer.FilledBarBlendColor
  m.vVideo.bufferingBar.filledBarBlendColor = config.VideoPlayer.FilledBarBlendColor
  m.vVideo.retrievingBar.filledBarBlendColor = config.VideoPlayer.FilledBarBlendColor

  rem --
  rem -- Configure common resolution options for the view.
  rem --
  resolution = m.top.getScene().currentDesignResolution
  m.rBackground.width = resolution.width
  m.rBackground.height = resolution.height
  m.vVideo.width = resolution.width
  m.vVideo.height = resolution.height

  if resolution.resolution = "FHD"
    m.llResume.itemSize = [480, 48]
    m.llResume.translation = [720, 492]
  else
    m.llResume.itemSize = [320, 36]
    m.llResume.translation = [480, 325]
  end if

  rem --
  rem -- Observe the fields we need to monitor for changes.
  rem --
  m.top.observeField("focusedChild", "onFocusedChildChange")
  m.llResume.observeField("itemSelected", "onItemSelectedChange")
end sub

rem --
rem -- PlayVideo()
rem --
rem -- Plays the video configured by it's URI.
rem --
sub PlayVideo(startPosition = 0 as integer)
  rem --
  rem -- Configure the new video content object.
  rem --
  m.vVideo.control = "stop"
  videoContent = createObject("roSGNode", "ContentNode")
  videoContent.url = m.top.uri
  videoContent.streamformat = m.format

  rem --
  rem -- Begin playing the video.
  rem --
  m.gResume.visible = false
  m.vVideo.visible = true
  m.vVideo.content = videoContent
  m.vVideo.seek = startPosition
  m.vVideo.control = "play"
end sub

rem *******************************************************
rem ** EVENT HANDLERS
rem *******************************************************

rem --
rem -- onUriChange()
rem --
rem -- The URI for the video we are supposed to play has changed. Update
rem -- the video object to play the new URI.
rem --
sub onUriChange()
  rem --
  rem -- Determine if this is an HLS or MP4 style video link.
  rem --
  if m.top.uri.Instr("m3u8") <> -1 or m.top.uri.Instr("M3u8") <> -1 or m.top.uri.Instr("m3U8") <> -1 or m.top.uri.Instr("M3U8")
    m.format = "hls"
  else
    m.format = "mp4"
  end if

  lastVideoState = ReadCache(m, "lastVideoState")
  if lastVideoState <> invalid
    lastVideoUri = lastVideoState.Split("|")[0]
    lastVideoPosition = lastVideoState.Split("|")[1].ToInt()
    if lastVideoUri = m.top.uri and lastVideoPosition > 0
      m.gResume.visible = true
      m.vVideo.visible = false
      return
    end if
  end if

  PlayVideo()
end sub

rem --
rem -- onFocusedChildChange()
rem --
rem -- Called when we gain or lose focus. If we are gaining focus then
rem -- ensure that the correct child object has the true focus.
rem --
sub onFocusedChildChange()
  if m.top.IsInFocusChain()
    if m.vVideo.visible = true and not m.vVideo.HasFocus()
      m.vVideo.SetFocus(true)
    else if m.gResume.visible = true and not m.llResume.HasFocus()
      m.llResume.SetFocus(true)
    end if
  end if
end sub

rem --
rem -- onItemSelectedChange()
rem --
rem -- An item has been selected from the list. Figure out what the user
rem -- wanted to do.
rem --
sub onItemSelectedChange()
  if m.llResume.itemSelected = 0
    lastVideoState = ReadCache(m, "lastVideoState")
    lastVideoPosition = lastVideoState.Split("|")[1].ToInt()
    PlayVideo(lastVideoPosition)
  else
    PlayVideo()
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
  if press = true and key = "back"
    if m.vVideo.duration > 60
      lastVideoState = m.top.uri + "|" + Int(m.vVideo.position).ToStr()
      WriteCache(m, "lastVideoState", lastVideoState)
    end if

    m.vVideo.control = "stop"
  end if

  return false
end function
