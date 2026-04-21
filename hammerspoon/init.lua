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
local IMAGE_PASTE_MODS = {"ctrl", "shift"}
local IMAGE_PASTE_KEY = "v"
local IMAGE_PASTE_MAX_EDGE = 1600
local IMAGE_PASTE_SCALE = 0.5
local IMAGE_PASTE_MIN_EDGE = 1
local IMAGE_PASTE_PASTE_DELAY = 0.15
local IMAGE_PASTE_RESTORE_DELAY = 1.0
local IMAGE_PASTE_DEBUG_ALERTS = true
local IMAGE_PASTE_SEND_MODS = {"ctrl"}

local log = hs.logger.new("init", "info")

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

local function showPasteDebug(message)
  log.i(message)

  if IMAGE_PASTE_DEBUG_ALERTS then
    hs.alert.show(message, 1.2)
  end
end

local function pasteDownsizedClipboardImage()
  local pasteboard = hs.pasteboard
  local originalContents = pasteboard.readAllData()
  local image = pasteboard.readImage()
  local contentTypes = pasteboard.contentTypes() or {}

  showPasteDebug("Image paste shortcut triggered")
  log.i("Pasteboard content types: " .. hs.inspect(contentTypes))

  if not image then
    showPasteDebug("No image on clipboard; sending normal paste")
    hs.timer.doAfter(IMAGE_PASTE_PASTE_DELAY, function()
      hs.eventtap.keyStroke(IMAGE_PASTE_SEND_MODS, "v")
    end)
    return
  end

  local imageSize = image:size()
  local longestEdge = math.max(imageSize.w, imageSize.h)
  showPasteDebug(string.format(
    "Clipboard image detected: %.0fx%.0f",
    imageSize.w,
    imageSize.h
  ))

  local scale = IMAGE_PASTE_SCALE
  if longestEdge * scale > IMAGE_PASTE_MAX_EDGE then
    scale = IMAGE_PASTE_MAX_EDGE / longestEdge
  end

  local targetSize = {
    w = math.max(IMAGE_PASTE_MIN_EDGE, math.floor(imageSize.w * scale + 0.5)),
    h = math.max(IMAGE_PASTE_MIN_EDGE, math.floor(imageSize.h * scale + 0.5)),
  }
  local downsizedImage = image:bitmapRepresentation(targetSize)

  if not downsizedImage or not pasteboard.writeObjects(downsizedImage) then
    showPasteDebug("Image resize paste failed")
    return
  end

  showPasteDebug(string.format(
    "Pasting downsized image: %dx%d",
    targetSize.w,
    targetSize.h
  ))
  hs.timer.doAfter(IMAGE_PASTE_PASTE_DELAY, function()
    hs.eventtap.keyStroke(IMAGE_PASTE_SEND_MODS, "v")

    if originalContents then
      hs.timer.doAfter(IMAGE_PASTE_RESTORE_DELAY, function()
        if pasteboard.writeAllData(originalContents) then
          log.i("Original clipboard restored")
        else
          log.e("Failed to restore original clipboard")
        end
      end)
    end
  end)
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

-- ctrl+shift+v: paste a downsized clipboard image, or normal paste for non-images
hs.hotkey.bind(IMAGE_PASTE_MODS, IMAGE_PASTE_KEY, pasteDownsizedClipboardImage)
