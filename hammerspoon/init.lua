-- Window resize hotkeys for Hammerspoon.
-- Hold cmd+ctrl and press:
--   h / l  to shrink / grow width
--   j / k  to shrink / grow height
--   - / =  to shrink / grow uniformly

local resizeMods = {"cmd", "ctrl"}
local moveMods = {"cmd", "ctrl", "shift"}

local EDGE_STEP = 200
local UNIFORM_STEP = 280
local MIN_W = 260
local MIN_H = 180

local function withFocusedWindow(apply)
  return function()
    local win = hs.window.focusedWindow()
    if not win then return end

    local f = win:frame()
    apply(f)

    win:setFrameInScreenBounds(f, 0)
  end
end

local function bind(modifiers, key, fn)
  -- press once, or hold to repeat
  hs.hotkey.bind(modifiers, key, fn, nil, fn)
end

local function resizeCentered(f, dw, dh)
  local cx = f.x + (f.w / 2)
  local cy = f.y + (f.h / 2)

  local newW = math.max(MIN_W, f.w + dw)
  local newH = math.max(MIN_H, f.h + dh)

  f.w = newW
  f.h = newH
  f.x = cx - (newW / 2)
  f.y = cy - (newH / 2)
end

local function translate(f, dx, dy)
  f.x = f.x + dx
  f.y = f.y + dy
end

-- h: shrink width, keep centered
bind(resizeMods, "h", withFocusedWindow(function(f)
  resizeCentered(f, -EDGE_STEP, 0)
end))

-- l: grow width, keep centered
bind(resizeMods, "l", withFocusedWindow(function(f)
  resizeCentered(f, EDGE_STEP, 0)
end))

-- j: shrink height, keep centered
bind(resizeMods, "j", withFocusedWindow(function(f)
  resizeCentered(f, 0, -EDGE_STEP)
end))

-- k: grow height, keep centered
bind(resizeMods, "k", withFocusedWindow(function(f)
  resizeCentered(f, 0, EDGE_STEP)
end))

-- "-": shrink uniformly, keep centered
bind(resizeMods, "-", withFocusedWindow(function(f)
  resizeCentered(f, -UNIFORM_STEP, -UNIFORM_STEP)
end))

-- "=": grow uniformly, keep centered
bind(resizeMods, "=", withFocusedWindow(function(f)
  resizeCentered(f, UNIFORM_STEP, UNIFORM_STEP)
end))

-- movement: move window rather than resize
-- h: move left
bind(moveMods, "h", withFocusedWindow(function(f)
  translate(f, -EDGE_STEP, 0)
end))

-- l: move right
bind(moveMods, "l", withFocusedWindow(function(f)
  translate(f, EDGE_STEP, 0)
end))

-- j: move down
bind(moveMods, "j", withFocusedWindow(function(f)
  translate(f, 0, EDGE_STEP)
end))

-- k: move up
bind(moveMods, "k", withFocusedWindow(function(f)
  translate(f, 0, -EDGE_STEP)
end))
