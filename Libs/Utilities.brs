rem --
rem -- ReadConfig()
rem --
rem -- Read the configuration file specified in the manifest.
rem --
rem -- @returns An object representing the JSON config file.
function ReadConfig() as object
  appInfo = CreateObject("roAppInfo")
  configPath = appInfo.GetValue("app_config")
  if configPath = invalid or configPath = ""
    configPath = "pkg:/source/config.json"
  end if
  json = ReadAsciiFile(configPath)

  config = ParseJSON(json)
  rem TODO: Cache this
  root = GetCrexRoot()

  rem --
  rem -- Add in any root config elements.
  rem --
  if config.LoadingSpinner = invalid
    config.LoadingSpinner = root + "Images/spinner.png"
  end if

  rem --
  rem -- Add in any missing MenuBar default configuration options.
  rem --
  if config.MenuBar = invalid
    config.MenuBar = {}
  end if
  if config.MenuBar.ButtonLeftImage = invalid
    config.MenuBar.ButtonLeftImage = root + "Images/ButtonLeftEdge.png"
  end if
  if config.MenuBar.ButtonMiddleImage = invalid
    config.MenuBar.ButtonMiddleImage = root + "Images/ButtonMiddle.png"
  end if
  if config.MenuBar.ButtonRightImage = invalid
    config.MenuBar.ButtonRightImage = root + "Images/ButtonRightEdge.png"
  end if

  return config
end function

rem --
rem -- GetCrexRoot()
rem --
rem -- Returns the path to the root Crex folder. Includes the trailing /.
rem --
rem -- @returns The path to the root Crex folder.
rem --
function GetCrexRoot()
  return FindPathToFile("pkg:/", "crex.root.txt")
end function

rem --
rem -- FindPathToFile(path, filename)
rem --
rem -- Finds the path to a given filename by recursively searching
rem -- for it starting at the given path.
rem --
rem -- @param path The path at which to begin searching, e.g. "pkg:/".
rem -- @param filename The filename that is to be matched against.
rem -- @returns A path to the directory containing filename or empty string if not found.
rem --
function FindPathToFile(path as string, filename as string) as string
  list = ListDir(path)
  for each p in list
    if p = filename
      return path
    end if

    r = FindPathToFile(path + p + "/", filename)
    if r <> ""
      return r
    end if
  end for

  return ""
end function

rem --
rem -- LogMessage(msg)
rem --
rem -- If running in development mode, logs a message to the
rem -- BrightScript console.
rem --
rem -- @param msg The string to be logged to the console.
rem --
sub LogMessage(msg as string)
  if CreateObject("roAppInfo").IsDev() = true
    print msg
  end if
end sub

rem --
rem -- AppendResolutionToUrl(url)
rem --
rem -- Takes a URL and appends the common resolution parameter to it.
rem --
rem -- @param url The URL to have the resolution appended.
rem -- @returns A string that represents the new URL to be used.
rem --
function AppendResolutionToUrl(url as string) as string
  if url.InStr("?") = -1
    return url + "?Resolution=" + m.top.getScene().currentDesignResolution.height.ToStr() + "p"
  else
    return url + "&Resolution=" + m.top.getScene().currentDesignResolution.height.ToStr() + "p"
  end if
end function
