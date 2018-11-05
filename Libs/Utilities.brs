rem --
rem -- ReadCrexConfig()
rem --
rem -- Read the configuration file specified in the manifest.
rem --
rem -- @returns An object representing the JSON config file.
function ReadCrexConfig() as object
  appInfo = CreateObject("roAppInfo")
  configPath = appInfo.GetValue("app_config")
  if configPath = invalid or configPath = ""
    configPath = "pkg:/source/config.json"
  end if
  json = ReadAsciiFile(configPath)

  config = ParseJSON(json)
  config.CrexRoot = GetCrexRoot()

  rem --
  rem -- Add in any root config elements.
  rem --
  if config.LoadingSpinner = invalid
    config.LoadingSpinner = config.CrexRoot + "Images/spinner.png"
  end if
  if config.ApplicationRootTemplate = invalid
    config.ApplicationRootTemplate = "Menu"
  end if
  if config.AnimationTime = invalid
    config.AnimationTime = 0.25
  end if

  rem --
  rem -- Add in any missing Video Player configuration options.
  rem --
  if config.VideoPlayer = invalid
    config.VideoPlayer = {}
  end if
  if config.VideoPlayer.FilledBarBlendColor = invalid
    config.VideoPlayer.FilledBarBlendColor = "0x808080FF"
  end if

  rem --
  rem -- Add in any missing MenuBar default configuration options.
  rem --
  if config.MenuBar = invalid
    config.MenuBar = {}
  end if
  if config.MenuBar.BackgroundColor = invalid
    config.MenuBar.BackgroundColor = "0x121212B2"
  end if
  if config.MenuBar.FocusedTextColor = invalid
    config.MenuBar.FocusedTextColor = "0xDDDDDDFF"
  end if
  if config.MenuBar.UnfocusedTextColor = invalid
    config.MenuBar.UnfocusedTextColor = "0x808080FF"
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
rem -- WriteCache(m, key, value)
rem --
rem -- Writes a value to the application cache. Only small amounts of
rem -- data should be stored in cache.
rem --
rem -- @param m The m object associated with the component.
rem -- @param key The key name for the cache value.
rem -- @param value The value to be written into the cache.
rem --
sub WriteCache(m as object, key as string, value as dynamic)
  if m.global.hasField("_crexCache") = false
    m.global.addFields({_crexCache: CreateObject("roSGNode", "ContentNode")})
  end if

  if m.global._crexCache.hasField("_" + key) = false
    fields = {}
    fields["_" + key] = value
    m.global._crexCache.addFields(fields)
  end if

  m.global._crexCache.setField("_" + key, value)
end sub

rem --
rem -- ReadCache(m, key)
rem --
rem -- Reads a value from the cache and returns it.
rem --
rem -- @param m The m object associated with the component.
rem -- @param key The key name for the cached value.
rem -- @returns The previously stored value or invalid if none.
rem --
function ReadCache(m as object, key as string) as dynamic
  if m.global.hasField("_crexCache")
    if m.global._crexCache.hasField("_" + key)
      return m.global._crexCache.getField("_" + key)
    end if
  end if

  return invalid
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

rem --
rem -- BestMatchingUrl(urlset)
rem --
function BestMatchingUrl(urlset as object) as string
  height = m.top.getScene().currentDesignResolution.height
  if height >= 2160
    images = [urlset.UHD, urlset.FHD, urlset.HD]
  else if height >= 1080
    images = [urlset.FHD, urlset.HD, urlset.UHD]
  else
    images = [urlset.HD, urlset.FHD, urlset.UHD]
  end if

  for i=0 to images.count() step 1
    if type(images[i]) = "String"
      return images[i]
    end if
  end for
end function

rem *******************************************************
rem * Registry Functions
rem *******************************************************

rem --
rem -- RegistryRead(key, section)
rem --
rem -- Read a value from the registry.
rem --
rem -- @param section The section of the registry to read from.
rem -- @param key The registry key to be read.
rem -- @returns The value in the registry or invalid if not found.
rem --
function RegistryRead(section as string, key as string) as dynamic
  sec = CreateObject("roRegistrySection", section)
  if sec.Exists(key)
    return sec.Read(key)
  end if

  return invalid
end function

rem --
rem -- RegistryWrite(section, key, value)
rem --
rem -- Write a value to the registry.
rem --
rem -- @param section The section of the registry to write to.
rem -- @param key The key name that will contain the value to write.
rem -- @param value The value to be written to the registery.
rem --
sub RegistryWrite(section as string, key as string, value as string)
  sec = CreateObject("roRegistrySection", section)
  sec.Write(key, value)
  sec.Flush()
end sub

rem --
rem -- RegistryDelete(section, key)
rem --
rem -- Delete a value from the registry.
rem --
rem -- @param section The section of the registry to delete a value from.
rem -- @param key The name of the key whose value will be deleted.
rem --
sub RegistryDelete(section as string, key as string)
  sec = CreateObject("roRegistrySection", section)
  sec.Delete(key)
  sec.Flush()
end sub
