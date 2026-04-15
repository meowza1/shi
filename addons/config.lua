-- ============================================================
-- addons/config.lua
-- Full save/load/autosave config system for RobloxUILibrary
-- Uses writefile/readfile/isfile + HttpService JSON
-- ============================================================

local Library = _G.RobloxUILibrary or require(script and script.Parent or game.ReplicatedStorage:WaitForChild("RobloxUILibrary"))
-- Allow the addon to reference Library via global or upvalue
if not Library then
    warn("[Config Addon] Could not find Library reference. Make sure _G.RobloxUILibrary is set.")
    return
end

local HttpService = game:GetService("HttpService")

local CONFIG_DIR   = "robloxuilib_configs/"
local AUTOSAVE_KEY = "__autosave__"
local DEBOUNCE_WAIT = 0.5

Library.Config = Library.Config or {}

-- ---- Debounce state ----
Library.Config._DebounceThread = nil
Library.Config.AutoSaveEnabled = false

-- ============================================================
-- INTERNAL: collect all element values
-- ============================================================
local function serializeElements()
    local data = {}
    for id, el in pairs(Library.Elements) do
        local t = el._type
        local entry = {type = t, name = el._name}
        if t == "Toggle" then
            entry.value = el:Get()
        elseif t == "Slider" then
            entry.value = el:Get()
        elseif t == "Dropdown" then
            entry.value = el:Get()
        elseif t == "Textbox" then
            entry.value = el:Get()
        elseif t == "Keybind" then
            local k = el:Get()
            entry.value = k and tostring(k) or "Unknown"
        elseif t == "Colorpicker" then
            local c = el:Get()
            if c then
                entry.value = {r = c.R, g = c.G, b = c.B}
            end
        elseif t == "ModeSelector" then
            entry.value = el:Get()
        end
        data[id] = entry
    end
    return data
end

-- ============================================================
-- INTERNAL: ensure config directory exists
-- ============================================================
local function ensureDir()
    if not isfolder(CONFIG_DIR) then
        makefolder(CONFIG_DIR)
    end
end

-- ============================================================
-- Save a profile by name
-- ============================================================
function Library.Config:Save(profileName)
    profileName = profileName or AUTOSAVE_KEY
    local ok, err = pcall(function()
        ensureDir()
        local payload = {
            version = 1,
            savedAt = os.time(),
            profile = profileName,
            elements = serializeElements(),
            theme = {
                Background    = {Library.Theme.Background.R,    Library.Theme.Background.G,    Library.Theme.Background.B},
                Panel         = {Library.Theme.Panel.R,         Library.Theme.Panel.G,         Library.Theme.Panel.B},
                Accent        = {Library.Theme.Accent.R,        Library.Theme.Accent.G,        Library.Theme.Accent.B},
                Text          = {Library.Theme.Text.R,          Library.Theme.Text.G,          Library.Theme.Text.B},
                TextSecondary = {Library.Theme.TextSecondary.R, Library.Theme.TextSecondary.G, Library.Theme.TextSecondary.B},
                Border        = {Library.Theme.Border.R,        Library.Theme.Border.G,        Library.Theme.Border.B},
            },
        }
        local json = HttpService:JSONEncode(payload)
        local path = CONFIG_DIR .. profileName .. ".json"
        writefile(path, json)
    end)
    if not ok then
        warn("[Config] Save failed for profile '" .. tostring(profileName) .. "': " .. tostring(err))
    end
end

-- ============================================================
-- Load a profile by name and apply values
-- ============================================================
function Library.Config:Load(profileName)
    profileName = profileName or AUTOSAVE_KEY
    local ok, err = pcall(function()
        local path = CONFIG_DIR .. profileName .. ".json"
        if not isfile(path) then
            warn("[Config] Profile not found: " .. profileName)
            return
        end
        local raw = readfile(path)
        local payload = HttpService:JSONDecode(raw)
        if not payload or not payload.elements then return end

        -- Restore elements
        for id, entry in pairs(payload.elements) do
            local el = Library.Elements[id]
            if el then
                local t = entry.type
                if t == "Toggle" and entry.value ~= nil then
                    el:Set(entry.value)
                elseif t == "Slider" and entry.value ~= nil then
                    el:Set(entry.value)
                elseif t == "Dropdown" and entry.value ~= nil then
                    el:Set(entry.value)
                elseif t == "Textbox" and entry.value ~= nil then
                    el:Set(entry.value)
                elseif t == "Keybind" and entry.value ~= nil then
                    -- Reconstruct KeyCode from string
                    local kc = Enum.KeyCode[entry.value]
                    if kc then el:Set(kc) end
                elseif t == "Colorpicker" and entry.value ~= nil then
                    local cv = entry.value
                    if cv and cv.r ~= nil then
                        el:Set(Color3.new(cv.r, cv.g, cv.b))
                    end
                elseif t == "ModeSelector" and entry.value ~= nil then
                    el:Set(entry.value)
                end
            end
        end

        -- Restore theme if present
        if payload.theme then
            local restored = {}
            for k, arr in pairs(payload.theme) do
                if type(arr) == "table" and #arr == 3 then
                    restored[k] = Color3.new(arr[1], arr[2], arr[3])
                end
            end
            if next(restored) then
                Library:SetTheme(restored)
            end
        end
    end)
    if not ok then
        warn("[Config] Load failed for profile '" .. tostring(profileName) .. "': " .. tostring(err))
    end
end

-- ============================================================
-- Delete a profile
-- ============================================================
function Library.Config:Delete(profileName)
    if not profileName then return end
    local ok, err = pcall(function()
        local path = CONFIG_DIR .. profileName .. ".json"
        if isfile(path) then
            delfile(path)
        end
    end)
    if not ok then
        warn("[Config] Delete failed for '" .. tostring(profileName) .. "': " .. tostring(err))
    end
end

-- ============================================================
-- List all saved profiles
-- ============================================================
function Library.Config:List()
    local profiles = {}
    local ok, err = pcall(function()
        if not isfolder(CONFIG_DIR) then return end
        local files = listfiles(CONFIG_DIR)
        for _, f in ipairs(files) do
            -- Extract just the profile name (strip directory and .json)
            local name = f:gsub(CONFIG_DIR, ""):gsub("%.json$", "")
            if name ~= AUTOSAVE_KEY and name ~= "" then
                table.insert(profiles, name)
            end
        end
    end)
    if not ok then
        warn("[Config] List failed: " .. tostring(err))
    end
    return profiles
end

-- ============================================================
-- Internal debounce for auto-save
-- ============================================================
function Library.Config:_Debounce()
    if Library.Config._DebounceThread then
        task.cancel(Library.Config._DebounceThread)
    end
    Library.Config._DebounceThread = task.delay(DEBOUNCE_WAIT, function()
        Library.Config:Save(AUTOSAVE_KEY)
        Library.Config._DebounceThread = nil
    end)
end

-- ============================================================
-- Enable continuous auto-save (fires every change + every 30s)
-- ============================================================
function Library.Config:AutoSave()
    Library.Config.AutoSaveEnabled = true

    -- Periodic backup every 30 seconds
    task.spawn(function()
        while Library.Config.AutoSaveEnabled do
            task.wait(30)
            if Library.Config.AutoSaveEnabled then
                Library.Config:Save(AUTOSAVE_KEY)
            end
        end
    end)

    -- Load autosave on startup if it exists
    local path = CONFIG_DIR .. AUTOSAVE_KEY .. ".json"
    pcall(function()
        if isfile(path) then
            -- Small delay to ensure all elements have been registered
            task.delay(0.2, function()
                Library.Config:Load(AUTOSAVE_KEY)
            end)
        end
    end)
end

-- ============================================================
-- Export a profile as a human-readable string (for sharing)
-- ============================================================
function Library.Config:Export(profileName)
    profileName = profileName or AUTOSAVE_KEY
    local path = CONFIG_DIR .. profileName .. ".json"
    local ok, result = pcall(function()
        if isfile(path) then
            return readfile(path)
        end
    end)
    if ok and result then return result end
    return nil
end

-- ============================================================
-- Import a profile from a JSON string
-- ============================================================
function Library.Config:Import(profileName, jsonString)
    if not profileName or not jsonString then return end
    local ok, err = pcall(function()
        -- Validate JSON
        HttpService:JSONDecode(jsonString)
        ensureDir()
        writefile(CONFIG_DIR .. profileName .. ".json", jsonString)
    end)
    if not ok then
        warn("[Config] Import failed: " .. tostring(err))
    end
end
