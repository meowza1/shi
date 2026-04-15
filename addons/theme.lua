-- ============================================================
-- addons/theme.lua
-- Live theme engine for RobloxUILibrary
-- Supports full live recoloring, gradients, presets
-- ============================================================

local Library = _G.RobloxUILibrary or require(script and script.Parent or game.ReplicatedStorage:WaitForChild("RobloxUILibrary"))
if not Library then
    warn("[Theme Addon] Could not find Library reference.")
    return
end

-- ============================================================
-- BUILT-IN THEME PRESETS
-- ============================================================
Library.ThemePresets = {
    Dark = {
        Background    = Color3.fromRGB(15,  20,  30),
        Panel         = Color3.fromRGB(20,  25,  35),
        PanelDark     = Color3.fromRGB(12,  16,  24),
        Accent        = Color3.fromRGB(80,  140, 255),
        AccentHover   = Color3.fromRGB(100, 160, 255),
        Text          = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(200, 200, 200),
        TextDim       = Color3.fromRGB(140, 140, 150),
        Border        = Color3.fromRGB(40,  45,  55),
        Toggle        = Color3.fromRGB(80,  140, 255),
        ToggleOff     = Color3.fromRGB(50,  55,  70),
        SliderFill    = Color3.fromRGB(80,  140, 255),
        SliderTrack   = Color3.fromRGB(35,  40,  55),
        ButtonBg      = Color3.fromRGB(30,  35,  50),
        ButtonHover   = Color3.fromRGB(40,  48,  65),
        DropdownBg    = Color3.fromRGB(25,  30,  42),
        InputBg       = Color3.fromRGB(25,  30,  42),
        GraphBg       = Color3.fromRGB(8,   10,  16),
        GraphLine     = Color3.fromRGB(255, 255, 255),
        NotifBg       = Color3.fromRGB(22,  26,  38),
        SidebarBg     = Color3.fromRGB(18,  22,  32),
        TopbarBg      = Color3.fromRGB(18,  22,  32),
    },
    Midnight = {
        Background    = Color3.fromRGB(8,   10,  18),
        Panel         = Color3.fromRGB(14,  16,  28),
        PanelDark     = Color3.fromRGB(6,   8,   14),
        Accent        = Color3.fromRGB(160, 80,  255),
        AccentHover   = Color3.fromRGB(180, 100, 255),
        Text          = Color3.fromRGB(240, 240, 255),
        TextSecondary = Color3.fromRGB(180, 180, 200),
        TextDim       = Color3.fromRGB(110, 110, 140),
        Border        = Color3.fromRGB(35,  35,  55),
        Toggle        = Color3.fromRGB(160, 80,  255),
        ToggleOff     = Color3.fromRGB(40,  40,  65),
        SliderFill    = Color3.fromRGB(160, 80,  255),
        SliderTrack   = Color3.fromRGB(28,  28,  48),
        ButtonBg      = Color3.fromRGB(22,  22,  42),
        ButtonHover   = Color3.fromRGB(35,  30,  60),
        DropdownBg    = Color3.fromRGB(18,  18,  34),
        InputBg       = Color3.fromRGB(18,  18,  34),
        GraphBg       = Color3.fromRGB(4,   4,   10),
        GraphLine     = Color3.fromRGB(200, 160, 255),
        NotifBg       = Color3.fromRGB(16,  16,  30),
        SidebarBg     = Color3.fromRGB(10,  10,  20),
        TopbarBg      = Color3.fromRGB(10,  10,  20),
    },
    Crimson = {
        Background    = Color3.fromRGB(20,  10,  12),
        Panel         = Color3.fromRGB(28,  14,  16),
        PanelDark     = Color3.fromRGB(14,  6,   8),
        Accent        = Color3.fromRGB(220, 60,  80),
        AccentHover   = Color3.fromRGB(240, 80,  100),
        Text          = Color3.fromRGB(255, 240, 240),
        TextSecondary = Color3.fromRGB(210, 190, 190),
        TextDim       = Color3.fromRGB(150, 120, 120),
        Border        = Color3.fromRGB(55,  35,  38),
        Toggle        = Color3.fromRGB(220, 60,  80),
        ToggleOff     = Color3.fromRGB(65,  35,  38),
        SliderFill    = Color3.fromRGB(220, 60,  80),
        SliderTrack   = Color3.fromRGB(45,  22,  26),
        ButtonBg      = Color3.fromRGB(38,  18,  22),
        ButtonHover   = Color3.fromRGB(55,  28,  34),
        DropdownBg    = Color3.fromRGB(30,  14,  18),
        InputBg       = Color3.fromRGB(30,  14,  18),
        GraphBg       = Color3.fromRGB(10,  4,   6),
        GraphLine     = Color3.fromRGB(255, 140, 155),
        NotifBg       = Color3.fromRGB(26,  12,  14),
        SidebarBg     = Color3.fromRGB(18,  8,   10),
        TopbarBg      = Color3.fromRGB(18,  8,   10),
    },
    Emerald = {
        Background    = Color3.fromRGB(10,  20,  16),
        Panel         = Color3.fromRGB(14,  28,  22),
        PanelDark     = Color3.fromRGB(6,   14,  10),
        Accent        = Color3.fromRGB(60,  220, 140),
        AccentHover   = Color3.fromRGB(80,  240, 160),
        Text          = Color3.fromRGB(240, 255, 248),
        TextSecondary = Color3.fromRGB(190, 215, 205),
        TextDim       = Color3.fromRGB(120, 155, 138),
        Border        = Color3.fromRGB(30,  55,  42),
        Toggle        = Color3.fromRGB(60,  220, 140),
        ToggleOff     = Color3.fromRGB(35,  65,  50),
        SliderFill    = Color3.fromRGB(60,  220, 140),
        SliderTrack   = Color3.fromRGB(20,  45,  34),
        ButtonBg      = Color3.fromRGB(18,  38,  28),
        ButtonHover   = Color3.fromRGB(28,  55,  42),
        DropdownBg    = Color3.fromRGB(14,  30,  22),
        InputBg       = Color3.fromRGB(14,  30,  22),
        GraphBg       = Color3.fromRGB(4,   10,  7),
        GraphLine     = Color3.fromRGB(140, 255, 200),
        NotifBg       = Color3.fromRGB(12,  26,  20),
        SidebarBg     = Color3.fromRGB(8,   18,  14),
        TopbarBg      = Color3.fromRGB(8,   18,  14),
    },
}

-- ============================================================
-- APPLY PRESET
-- ============================================================
function Library:ApplyPreset(presetName)
    local preset = Library.ThemePresets[presetName]
    if not preset then
        warn("[Theme] Unknown preset: " .. tostring(presetName))
        return
    end
    Library:SetTheme(preset)
end

-- ============================================================
-- DEEP LIVE RECOLOR (enhanced version for addon)
-- Walks entire GUI tree and recolors every matching element
-- ============================================================
function Library:LiveRecolor(newTheme)
    -- Merge
    for k, v in pairs(newTheme) do
        Library.Theme[k] = v
    end

    if not Library.GUI then return end

    -- Walk the GUI tree
    local function walk(inst)
        local name = inst.Name

        if inst:IsA("Frame") or inst:IsA("ScrollingFrame") then
            if name == "MainWindowFrame" then
                Library.Utils.QuickTween(inst, 0.25, {BackgroundColor3 = Library.Theme.Background})

            elseif name == "ContentArea" or name:sub(1, 10) == "TabContent" then
                Library.Utils.QuickTween(inst, 0.25, {BackgroundColor3 = Library.Theme.Panel})

            elseif name == "SidebarTabContainer" or name == "TopBar" or name == "TopBarFix" then
                Library.Utils.QuickTween(inst, 0.25, {BackgroundColor3 = Library.Theme.TopbarBg})

            elseif name:sub(1, 13) == "SectionHeader" then
                Library.Utils.QuickTween(inst, 0.25, {BackgroundColor3 = Library.Theme.PanelDark})

            elseif name == "SliderFill" then
                Library.Utils.QuickTween(inst, 0.25, {BackgroundColor3 = Library.Theme.SliderFill})

            elseif name == "SliderTrack" then
                Library.Utils.QuickTween(inst, 0.25, {BackgroundColor3 = Library.Theme.SliderTrack})

            elseif name == "ActiveTabBar" then
                Library.Utils.QuickTween(inst, 0.25, {BackgroundColor3 = Library.Theme.Accent})

            elseif name == "MiniToggleTrack" then
                -- Keep its current on/off state color
                if inst.BackgroundColor3 ~= Library.Theme.ToggleOff then
                    Library.Utils.QuickTween(inst, 0.25, {BackgroundColor3 = Library.Theme.Toggle})
                end

            elseif name == "CheckBg" then
                if inst.BackgroundColor3 ~= Library.Theme.ToggleOff then
                    Library.Utils.QuickTween(inst, 0.25, {BackgroundColor3 = Library.Theme.CheckFill})
                end

            elseif name == "DropdownBox" or name == "TBFrame" then
                Library.Utils.QuickTween(inst, 0.25, {BackgroundColor3 = Library.Theme.InputBg})

            elseif name == "GraphCanvas" then
                Library.Utils.QuickTween(inst, 0.25, {BackgroundColor3 = Library.Theme.GraphBg})

            elseif name == "NotificationFrame" then
                Library.Utils.QuickTween(inst, 0.25, {BackgroundColor3 = Library.Theme.NotifBg})

            elseif name:sub(1, 6) == "Btn_" or name == "DismissBtn" then
                Library.Utils.QuickTween(inst, 0.25, {BackgroundColor3 = Library.Theme.ButtonBg})

            elseif name == "SearchFrame" then
                Library.Utils.QuickTween(inst, 0.25, {BackgroundColor3 = Library.Theme.InputBg})
            end

        elseif inst:IsA("UIStroke") then
            Library.Utils.QuickTween(inst, 0.25, {Color = Library.Theme.Border})

        elseif inst:IsA("TextLabel") then
            local current = inst.TextColor3
            -- Only recolor if it was using a theme color (roughly)
            local r, g, b = current.R, current.G, current.B
            if r > 0.9 and g > 0.9 and b > 0.9 then
                Library.Utils.QuickTween(inst, 0.2, {TextColor3 = Library.Theme.Text})
            elseif r > 0.75 and g > 0.75 then
                Library.Utils.QuickTween(inst, 0.2, {TextColor3 = Library.Theme.TextSecondary})
            elseif r > 0.5 and g > 0.5 then
                Library.Utils.QuickTween(inst, 0.2, {TextColor3 = Library.Theme.TextDim})
            end

        elseif inst:IsA("TextBox") then
            Library.Utils.QuickTween(inst, 0.2, {TextColor3 = Library.Theme.Text})
            inst.PlaceholderColor3 = Library.Theme.TextDim

        elseif inst:IsA("TextButton") then
            local name2 = inst.Name
            if name2:sub(1, 6) == "Btn_" or name2 == "DismissBtn" then
                Library.Utils.QuickTween(inst, 0.2, {TextColor3 = Library.Theme.Text})
            end
        end

        -- Graph curve lines
        if name == "CurveSeg" and inst:IsA("Frame") then
            Library.Utils.QuickTween(inst, 0.2, {BackgroundColor3 = Library.Theme.GraphLine})
        end

        for _, child in ipairs(inst:GetChildren()) do
            walk(child)
        end
    end

    walk(Library.GUI)
end

-- Alias: override base SetTheme to use the enhanced live version
local _originalSetTheme = Library.SetTheme
Library.SetTheme = function(self, newTheme)
    Library:LiveRecolor(newTheme)
end

-- ============================================================
-- THEME EDITOR WINDOW (opens an in-library UI for live editing)
-- ============================================================
function Library:OpenThemeEditor()
    if not Library.GUI then return end
    if Library._ThemeEditorOpen then return end
    Library._ThemeEditorOpen = true

    -- Floating theme editor frame
    local editorW, editorH = 320, 480
    local editor = Library.Utils.NewFrame(Library.GUI, "ThemeEditorWindow",
        Library.Theme.Panel,
        UDim2.new(0, editorW, 0, editorH),
        UDim2.new(0.5, -editorW/2, 0.5, -editorH/2), 600)
    Library.Utils.MakeCorner(editor, 12)
    Library.Utils.MakeStroke(editor, Library.Theme.Border, 1, 0.2)

    -- Shadow
    local sh = Library.Utils.NewFrame(Library.GUI, "TEWShadow",
        Color3.new(0,0,0), UDim2.new(0, editorW+8, 0, editorH+8),
        UDim2.new(0.5, -editorW/2-4, 0.5, -editorH/2-4), 599)
    sh.BackgroundTransparency = 0.55
    Library.Utils.MakeCorner(sh, 14)

    -- Title bar
    local titleBar = Library.Utils.NewFrame(editor, "TEWTitleBar",
        Library.Theme.PanelDark,
        UDim2.new(1, 0, 0, 36), UDim2.new(0,0,0,0), 602)
    Library.Utils.MakeCorner(titleBar, 12)

    local title = Library.Utils.NewLabel(titleBar, "🎨  Theme Editor", 13,
        Library.Theme.Text, Enum.Font.GothamBold, 603)
    title.Size = UDim2.new(1, -40, 1, 0)
    title.Position = UDim2.new(0, 12, 0, 0)
    title.TextXAlignment = Enum.TextXAlignment.Left

    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Library.Theme.TextSecondary
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 18
    closeBtn.BackgroundTransparency = 1
    closeBtn.Size = UDim2.new(0, 28, 0, 28)
    closeBtn.Position = UDim2.new(1, -32, 0, 4)
    closeBtn.ZIndex = 603
    closeBtn.Parent = titleBar
    closeBtn.MouseButton1Click:Connect(function()
        editor:Destroy()
        sh:Destroy()
        Library._ThemeEditorOpen = false
    end)

    Library.Dragging.Enable(editor, titleBar)

    -- Scroll area for color rows
    local scroll = Instance.new("ScrollingFrame")
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.Size = UDim2.new(1, 0, 1, -80)
    scroll.Position = UDim2.new(0, 0, 0, 40)
    scroll.ZIndex = 601
    scroll.CanvasSize = UDim2.new(0,0,0,0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.ScrollBarThickness = 3
    scroll.ScrollBarImageColor3 = Library.Theme.Accent
    scroll.Parent = editor

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.Padding = UDim.new(0, 4)
    layout.Parent = scroll

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft   = UDim.new(0, 10)
    pad.PaddingRight  = UDim.new(0, 10)
    pad.PaddingTop    = UDim.new(0, 6)
    pad.Parent = scroll

    -- Color keys to expose in the editor
    local editableColors = {
        {"Background",    "Background"},
        {"Panel",         "Panel"},
        {"Accent",        "Accent Color"},
        {"Text",          "Text"},
        {"TextSecondary", "Secondary Text"},
        {"Border",        "Border"},
        {"SliderFill",    "Slider Fill"},
        {"ButtonBg",      "Button BG"},
        {"GraphBg",       "Graph BG"},
        {"NotifBg",       "Notification BG"},
        {"SidebarBg",     "Sidebar BG"},
    }

    for _, pair in ipairs(editableColors) do
        local key, label = pair[1], pair[2]
        local currentColor = Library.Theme[key] or Color3.new(1,1,1)

        local row = Library.Utils.NewFrame(scroll, "ColorRow_"..key,
            Color3.fromRGBA(0,0,0,0),
            UDim2.new(1, 0, 0, 30), nil, 602)
        row.BackgroundTransparency = 1

        local lbl = Library.Utils.NewLabel(row, label, 12,
            Library.Theme.TextSecondary, Enum.Font.Gotham, 603)
        lbl.Size = UDim2.new(1, -52, 1, 0)
        lbl.TextXAlignment = Enum.TextXAlignment.Left

        local swatch = Library.Utils.NewFrame(row, "TEWSwatch",
            currentColor,
            UDim2.new(0, 44, 0, 22), UDim2.new(1, -46, 0.5, -11), 603)
        Library.Utils.MakeCorner(swatch, 6)
        Library.Utils.MakeStroke(swatch, Library.Theme.Border, 1, 0.2)

        -- Click to open colorpicker for this key
        local cpOpen = false
        local cpInst = nil

        local clickBtn = Instance.new("TextButton")
        clickBtn.Text = ""
        clickBtn.BackgroundTransparency = 1
        clickBtn.Size = UDim2.new(1,0,1,0)
        clickBtn.ZIndex = 605
        clickBtn.Parent = swatch
        clickBtn.MouseButton1Click:Connect(function()
            if cpOpen and cpInst then
                cpInst.Frame:Destroy()
                cpOpen = false
                cpInst = nil
            else
                cpOpen = true
                cpInst = Library._BuildColorPicker({
                    Default = currentColor,
                    Callback = function(c)
                        currentColor = c
                        swatch.BackgroundColor3 = c
                        local patch = {}
                        patch[key] = c
                        Library:LiveRecolor(patch)
                    end
                }, swatch)
            end
        end)
    end

    -- Preset row at bottom
    local presetBar = Library.Utils.NewFrame(editor, "PresetBar",
        Library.Theme.PanelDark,
        UDim2.new(1, 0, 0, 36), UDim2.new(0, 0, 1, -36), 602)
    Library.Utils.MakeCorner(presetBar, 12)

    local presetLayout = Instance.new("UIListLayout")
    presetLayout.FillDirection = Enum.FillDirection.Horizontal
    presetLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    presetLayout.Padding = UDim.new(0, 6)
    presetLayout.Parent = presetBar

    local ppad = Instance.new("UIPadding")
    ppad.PaddingTop = UDim.new(0, 5)
    ppad.Parent = presetBar

    for presetName, _ in pairs(Library.ThemePresets) do
        local pb = Instance.new("TextButton")
        pb.Text = presetName
        pb.Font = Enum.Font.GothamBold
        pb.TextSize = 10
        pb.TextColor3 = Library.Theme.Text
        pb.BackgroundColor3 = Library.Theme.ButtonBg
        pb.BorderSizePixel = 0
        pb.Size = UDim2.new(0, 66, 0, 24)
        pb.ZIndex = 603
        Library.Utils.MakeCorner(pb, 6)
        pb.Parent = presetBar
        pb.MouseButton1Click:Connect(function()
            Library:ApplyPreset(presetName)
        end)
        pb.MouseEnter:Connect(function()
            Library.Utils.QuickTween(pb, 0.1, {BackgroundColor3 = Library.Theme.ButtonHover})
        end)
        pb.MouseLeave:Connect(function()
            Library.Utils.QuickTween(pb, 0.1, {BackgroundColor3 = Library.Theme.ButtonBg})
        end)
    end

    return editor
end
