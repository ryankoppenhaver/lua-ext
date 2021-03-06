--- A module for determining information about the execution platform
-- @module platform

-- Our global environment.
local P = {}

-- Import section:
-- We declare everything this package needs from "outside" here.
local _type = type
local package = package
local string = string
local io = io
local os = os
local version = _VERSION

-- Note that we define this ahead of the below, since we need to know the
-- version of Lua to figure out whether we need to use setfenv.
local _lua_version = string.sub(version, 5)

-- No more external access after this point.
if _lua_version == '5.2' then
    _ENV = P
else
    setfenv(1, P)
end


-- Use undocumented package.config to get directory and path separator, if
-- available; otherwise fall back to defaults.
local dirsep, pathsep
if package and package.config then 
  dirsep, pathsep = string.match(package.config, "^([^\n]+)\n([^\n]+)\n")
else
  dirsep = '/'
  pathsep = ';'
end


--- Platform-specific constants
const = {
    dirsep = dirsep,        -- The directory separator
    pathsep = pathsep,      -- The path separator
    extsep = '.',           -- The extension separator
}



-------------------------------------------------------------------------------
-- A constant indicating whether the current execution platform is Windows.
is_windows = const.dirsep == '\\'

is_minecraft = false
if _type(os.version) == "function" then
  if string.sub(os.version(),1,7) == "CraftOS" or 
     string.sub(os.version(),1,8) == "TurtleOS" then
    is_minecraft = true
  end
end


-------------------------------------------------------------------------------
-- Returns the current execution platform.
-- Values can include "windows", "darwin", "linux", or whatever the lower-case
-- version of `uname` returns.  "unknown" is returned if the output from
-- `uname` is empty (e.g. in case of an error).
-- @return A string indicating the current execution platform
function platform()
    if is_windows then
        return 'windows'
    end

    if is_minecraft then
      return 'minecraft'
    end

    -- Return the lower-cased output from `uname`.  The redirection means that
    -- if the command doesn't exist, we don't get a strange error.
    local uname = io.popen('uname 2>/dev/null'):read()
    if #uname > 0 then
        return uname:lower()
    end

    return 'unknown'
end



local _win_mapping = {
    ['AMD64'] = 'x64',
    ['IA64'] = 'ia64',
    ['x86'] = 'x86',
}

local _other_mapping = {
    ['i686'] = 'x86',
    ['i386'] = 'x86',
    ['x86_64'] = 'x64',
}


-------------------------------------------------------------------------------
-- Returns the current processor architecture.
-- The string returned will be one of 'x86', 'x64', 'ia64', 'unknown', or
-- whatever `uname -p` returns.
-- @return A string indicating the processor architecture
function architecture()
    local arch

    if is_windows then
        -- Try WOW64 first.
        arch = os.getenv('PROCESSOR_ARCHITEW6432')
        if arch == nil then
            arch = os.getenv('PROCESSOR_ARCHITECTURE')
        end

        return _win_mapping[arch] or 'unknown'
    end

    if is_minecraft then
      if string.sub(os.version(),1,8) == "TurtleOS" then
        return "turtle"
      else
        return "computer"
      end
    end

    -- For now, we just try getting the information from uname.
    arch = io.popen('uname -a 2>/dev/null'):read()
    if arch ~= nil then
        if arch:find('x86_64') then
            return 'x64'
        elseif arch:find('i386') then
            return 'x86'
        end
    end

    -- Default to uname -p, mapped to common names if possible.
    arch = io.popen('uname -p 2>/dev/null'):read()
    if arch ~= nil then
        return _other_mapping[arch] or arch
    end

    return 'unknown'
end


-------------------------------------------------------------------------------
-- The current version of Lua, as a string (e.g. "5.1", "5.2", etc.)
lua_version = _lua_version


return P
