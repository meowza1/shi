-- ============================================================
-- RobloxUILibrary | Main LocalScript
-- Elite production-grade exploit UI framework
-- Matches screenshot: dark panel, sidebar tabs, all elements
-- ============================================================

local Library = {}
Library.Theme = {
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
    StatusGreen   = Color3.fromRGB(80,  255, 120),
    NotifBg       = Color3.fromRGB(22,  26,  38),
    Shadow        = Color3.fromRGB(0,   0,   0),
    CheckFill     = Color3.fromRGB(80,  140, 255),
    SidebarBg     = Color3.fromRGB(18,  22,  32),
    TopbarBg      = Color3.fromRGB(18,  22,  32),
}
Library.Config   = {}
Library.Utils    = {}
Library.Animations = {}
Library.Input    = {}
Library.Dragging = {}
Library.Addons   = {}
Library.Elements = {}  -- {id -> element table}
Library.GUI      = nil
Library._Windows = {}
Library._Notifications = {}
Library._NotifStack = {}
Library._TooltipFrame = nil
Library._ActiveColorPickers = {}
Library._ElementCounter = 0

-- ============================================================
-- SERVICES
-- ============================================================
local TweenService        = game:GetService("TweenService")
local UserInputService    = game:GetService("UserInputService")
local RunService          = game:GetService("RunService")
local HttpService         = game:GetService("HttpService")
local Players             = game:GetService("Players")
local ContextActionService= game:GetService("ContextActionService")
local CoreGui             = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- ============================================================
-- UTILS
-- ============================================================
function Library.Utils.Tween(inst, info, props)
    local t = TweenService:Create(inst, info, props)
    t:Play()
    return t
end

function Library.Utils.QuickTween(inst, t, props, style, dir)
    style = style or Enum.EasingStyle.Quad
    dir   = dir   or Enum.EasingDirection.Out
    return Library.Utils.Tween(inst, TweenInfo.new(t, style, dir), props)
end

function Library.Utils.MakeCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 12)
    c.Parent = parent
    return c
end

function Library.Utils.MakeStroke(parent, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or Library.Theme.Border
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0.3
    s.Parent = parent
    return s
end

function Library.Utils.MakeShadow(parent, size)
    -- Offset shadow frame behind parent
    local sh = Instance.new("Frame")
    sh.Name = "Shadow"
    sh.BackgroundColor3 = Library.Theme.Shadow
    sh.BackgroundTransparency = 0.55
    sh.BorderSizePixel = 0
    sh.Size = UDim2.new(1, 4, 1, 4)
    sh.Position = UDim2.new(0, 4, 0, 4)
    sh.ZIndex = (parent.ZIndex or 1) - 1
    Library.Utils.MakeCorner(sh, 14)
    sh.Parent = parent.Parent
    -- Re-parent parent on top
    parent.ZIndex = sh.ZIndex + 1
    return sh
end

function Library.Utils.NewLabel(parent, text, size, color, font, zindex)
    local l = Instance.new("TextLabel")
    l.Text = text or ""
    l.TextSize = size or 14
    l.TextColor3 = color or Library.Theme.Text
    l.Font = font or Enum.Font.GothamBold
    l.BackgroundTransparency = 1
    l.ZIndex = zindex or 5
    l.Parent = parent
    return l
end

function Library.Utils.NewFrame(parent, name, bg, size, pos, zindex)
    local f = Instance.new("Frame")
    f.Name = name or "Frame"
    f.BackgroundColor3 = bg or Library.Theme.Panel
    f.BorderSizePixel = 0
    f.Size = size or UDim2.new(1, 0, 0, 30)
    f.Position = pos or UDim2.new(0, 0, 0, 0)
    f.ZIndex = zindex or 5
    f.Parent = parent
    return f
end

function Library.Utils.Unique(prefix)
    Library._ElementCounter = Library._ElementCounter + 1
    return (prefix or "El") .. tostring(Library._ElementCounter)
end

function Library.Utils.RGBtoHex(r, g, b)
    return string.format("#%02x%02x%02x", math.clamp(r,0,255), math.clamp(g,0,255), math.clamp(b,0,255))
end

function Library.Utils.HexToRGB(hex)
    hex = hex:gsub("#","")
    if #hex ~= 6 then return 255,255,255 end
    local r = tonumber(hex:sub(1,2),16) or 255
    local g = tonumber(hex:sub(3,4),16) or 255
    local b = tonumber(hex:sub(5,6),16) or 255
    return r,g,b
end

function Library.Utils.HSVtoRGB(h, s, v)
    -- h: 0-1, s: 0-1, v: 0-1
    if s == 0 then return v,v,v end
    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)
    i = i % 6
    if i == 0 then return v,t,p
    elseif i == 1 then return q,v,p
    elseif i == 2 then return p,v,t
    elseif i == 3 then return p,q,v
    elseif i == 4 then return t,p,v
    else return v,p,q end
end

function Library.Utils.RGBtoHSV(r, g, b)
    r,g,b = r/255, g/255, b/255
    local max = math.max(r,g,b)
    local min = math.min(r,g,b)
    local d = max - min
    local h,s,v = 0, (max == 0 and 0 or d/max), max
    if d ~= 0 then
        if max == r then h = (g-b)/d % 6
        elseif max == g then h = (b-r)/d + 2
        else h = (r-g)/d + 4 end
        h = h / 6
    end
    return h, s, v
end

-- ============================================================
-- DRAGGING SYSTEM
-- ============================================================
function Library.Dragging.Enable(frame, handle, minSize, maxSize, onMove)
    handle = handle or frame
    local dragging, dragInput, dragStart, startPos = false, nil, nil, nil

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or
           input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            local newPos = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
            -- Clamp to screen
            local sg = Library.GUI
            if sg then
                local sw = sg.AbsoluteSize.X
                local sh2 = sg.AbsoluteSize.Y
                local fw = frame.AbsoluteSize.X
                local fh = frame.AbsoluteSize.Y
                local ox = math.clamp(newPos.X.Offset, 0, sw - fw)
                local oy = math.clamp(newPos.Y.Offset, 0, sh2 - fh)
                newPos = UDim2.new(0, ox, 0, oy)
            end
            frame.Position = newPos
            if onMove then onMove(newPos) end
        end
    end)
end

-- ============================================================
-- TOOLTIP SYSTEM
-- ============================================================
function Library._InitTooltip()
    if Library._TooltipFrame then return end
    local tt = Instance.new("Frame")
    tt.Name = "TooltipFrame"
    tt.BackgroundColor3 = Color3.fromRGB(18, 22, 32)
    tt.BorderSizePixel = 0
    tt.Size = UDim2.new(0, 160, 0, 36)
    tt.ZIndex = 999
    tt.BackgroundTransparency = 1
    tt.Visible = false
    Library.Utils.MakeCorner(tt, 8)
    Library.Utils.MakeStroke(tt, Library.Theme.Border, 1, 0.2)
    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 10)
    pad.PaddingRight = UDim.new(0, 10)
    pad.PaddingTop = UDim.new(0, 6)
    pad.PaddingBottom = UDim.new(0, 6)
    pad.Parent = tt
    local label = Instance.new("TextLabel")
    label.Name = "TooltipLabel"
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Library.Theme.Text
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextWrapped = true
    label.ZIndex = 1000
    label.Parent = tt
    tt.Parent = Library.GUI
    Library._TooltipFrame = tt
end

function Library._ShowTooltip(text, element)
    if not text or text == "" then return end
    Library._InitTooltip()
    local tt = Library._TooltipFrame
    local lbl = tt:FindFirstChild("TooltipLabel")
    if lbl then lbl.Text = text end
    -- Size to fit text
    local tw = math.min(math.max(#text * 6.5, 80), 220)
    tt.Size = UDim2.new(0, tw, 0, 36)
    tt.BackgroundTransparency = 1
    tt.Visible = true
    -- Position near mouse
    local mp = UserInputService:GetMouseLocation()
    local sgSize = Library.GUI.AbsoluteSize
    local x = math.min(mp.X + 12, sgSize.X - tw - 10)
    local y = mp.Y + 18
    if y + 40 > sgSize.Y then y = mp.Y - 44 end
    tt.Position = UDim2.new(0, x, 0, y)
    Library.Utils.QuickTween(tt, 0.15, {BackgroundTransparency = 0.05})
    if lbl then Library.Utils.QuickTween(lbl, 0.15, {TextTransparency = 0}) end
end

function Library._HideTooltip()
    if not Library._TooltipFrame then return end
    local tt = Library._TooltipFrame
    local lbl = tt:FindFirstChild("TooltipLabel")
    Library.Utils.QuickTween(tt, 0.1, {BackgroundTransparency = 1})
    if lbl then Library.Utils.QuickTween(lbl, 0.1, {TextTransparency = 1}):Completed:Connect(function()
        tt.Visible = false
    end) end
end

function Library._BindTooltip(element, text)
    if not text or text == "" then return end
    element.MouseEnter:Connect(function() Library._ShowTooltip(text, element) end)
    element.MouseLeave:Connect(function() Library._HideTooltip() end)
end

-- ============================================================
-- NOTIFICATION SYSTEM
-- ============================================================
local NOTIF_WIDTH  = 260
local NOTIF_GAP    = 8
local NOTIF_X_PAD  = 12
local NOTIF_Y_PAD  = 12

function Library._GetNotifY()
    local y = NOTIF_Y_PAD
    for _, n in ipairs(Library._NotifStack) do
        if n and n.Frame and n.Frame.Parent then
            y = y + n.Frame.AbsoluteSize.Y + NOTIF_GAP
        end
    end
    return y
end

function Library._RemoveNotif(notif)
    -- Remove from stack
    for i, n in ipairs(Library._NotifStack) do
        if n == notif then table.remove(Library._NotifStack, i) break end
    end
    -- Slide out + fade
    Library.Utils.QuickTween(notif.Frame, 0.2, {
        Position = UDim2.new(0, Library.GUI.AbsoluteSize.X + 20, 0, notif.Frame.Position.Y.Offset),
        BackgroundTransparency = 1
    }):Completed:Connect(function()
        notif.Frame:Destroy()
    end)
    -- Re-stack remaining
    task.delay(0.05, function()
        local y = NOTIF_Y_PAD
        for _, n in ipairs(Library._NotifStack) do
            if n and n.Frame and n.Frame.Parent then
                Library.Utils.QuickTween(n.Frame, 0.2, {
                    Position = UDim2.new(1, -(NOTIF_WIDTH + NOTIF_X_PAD), 0, y)
                })
                y = y + n.Frame.AbsoluteSize.Y + NOTIF_GAP
            end
        end
    end)
end

function Library:Notify(opts)
    opts = opts or {}
    local title    = opts.Title or "Notification"
    local desc     = opts.Description or ""
    local ntype    = opts.Type or "Normal"   -- Normal / Infinite / YesNo
    local duration = opts.Duration or 4
    local callback = opts.Callback

    if not Library.GUI then return end

    -- Outer frame
    local nf = Instance.new("Frame")
    nf.Name = "NotificationFrame"
    nf.BackgroundColor3 = Library.Theme.NotifBg
    nf.BorderSizePixel = 0
    nf.ZIndex = 900
    nf.BackgroundTransparency = 1

    local baseHeight = 72
    if ntype == "YesNo" then baseHeight = 100 end
    if ntype == "Infinite" then baseHeight = 84 end
    if #desc > 50 then baseHeight = baseHeight + 18 end

    nf.Size = UDim2.new(0, NOTIF_WIDTH, 0, baseHeight)
    Library.Utils.MakeCorner(nf, 10)
    Library.Utils.MakeStroke(nf, Library.Theme.Border, 1, 0.25)

    -- Shadow
    local sh = Instance.new("Frame")
    sh.Name = "NShadow"
    sh.BackgroundColor3 = Color3.new(0,0,0)
    sh.BackgroundTransparency = 0.6
    sh.BorderSizePixel = 0
    sh.Size = UDim2.new(1, 4, 1, 4)
    sh.Position = UDim2.new(0, 4, 0, 4)
    sh.ZIndex = 899
    Library.Utils.MakeCorner(sh, 11)
    sh.Parent = Library.GUI

    -- Start off-screen right
    local sgW = Library.GUI.AbsoluteSize.X
    local startY = Library._GetNotifY()
    nf.Position = UDim2.new(0, sgW + 20, 0, startY)
    nf.Parent = Library.GUI

    local notifObj = {Frame = nf, Shadow = sh}
    table.insert(Library._NotifStack, notifObj)

    -- Padding
    local pad = Instance.new("UIPadding")
    pad.PaddingLeft   = UDim.new(0, 12)
    pad.PaddingRight  = UDim.new(0, 12)
    pad.PaddingTop    = UDim.new(0, 10)
    pad.PaddingBottom = UDim.new(0, 10)
    pad.Parent = nf

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.Padding = UDim.new(0, 4)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = nf

    -- Title
    local titleLbl = Instance.new("TextLabel")
    titleLbl.Name = "NTitle"
    titleLbl.Text = title
    titleLbl.TextColor3 = Library.Theme.Text
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 13
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.BackgroundTransparency = 1
    titleLbl.Size = UDim2.new(1, 0, 0, 18)
    titleLbl.ZIndex = 902
    titleLbl.LayoutOrder = 1
    titleLbl.Parent = nf

    -- Description
    if desc ~= "" then
        local descLbl = Instance.new("TextLabel")
        descLbl.Name = "NDesc"
        descLbl.Text = desc
        descLbl.TextColor3 = Library.Theme.TextSecondary
        descLbl.Font = Enum.Font.Gotham
        descLbl.TextSize = 11
        descLbl.TextXAlignment = Enum.TextXAlignment.Left
        descLbl.TextWrapped = true
        descLbl.BackgroundTransparency = 1
        descLbl.Size = UDim2.new(1, 0, 0, 30)
        descLbl.ZIndex = 902
        descLbl.LayoutOrder = 2
        descLbl.Parent = nf
    end

    -- Dismiss button for Infinite
    if ntype == "Infinite" then
        local dismissBtn = Instance.new("TextButton")
        dismissBtn.Name = "DismissBtn"
        dismissBtn.Text = "Dismiss"
        dismissBtn.TextColor3 = Library.Theme.Text
        dismissBtn.Font = Enum.Font.GothamBold
        dismissBtn.TextSize = 12
        dismissBtn.BackgroundColor3 = Library.Theme.ButtonBg
        dismissBtn.BorderSizePixel = 0
        dismissBtn.Size = UDim2.new(0, 80, 0, 24)
        dismissBtn.ZIndex = 903
        dismissBtn.LayoutOrder = 3
        Library.Utils.MakeCorner(dismissBtn, 6)
        Library.Utils.MakeStroke(dismissBtn, Library.Theme.Border, 1, 0.3)
        dismissBtn.Parent = nf
        dismissBtn.MouseButton1Click:Connect(function()
            Library._RemoveNotif(notifObj)
        end)
    end

    -- Yes/No buttons
    if ntype == "YesNo" then
        local btnRow = Instance.new("Frame")
        btnRow.Name = "YesNoRow"
        btnRow.BackgroundTransparency = 1
        btnRow.Size = UDim2.new(1, 0, 0, 28)
        btnRow.ZIndex = 902
        btnRow.LayoutOrder = 3
        btnRow.Parent = nf

        local rowLayout = Instance.new("UIListLayout")
        rowLayout.FillDirection = Enum.FillDirection.Horizontal
        rowLayout.Padding = UDim.new(0, 8)
        rowLayout.Parent = btnRow

        local yesBtn = Instance.new("TextButton")
        yesBtn.Name = "YesBtn"
        yesBtn.Text = "Yes"
        yesBtn.TextColor3 = Color3.fromRGB(255,255,255)
        yesBtn.Font = Enum.Font.GothamBold
        yesBtn.TextSize = 12
        yesBtn.BackgroundColor3 = Color3.fromRGB(60, 200, 90)
        yesBtn.BorderSizePixel = 0
        yesBtn.Size = UDim2.new(0, 80, 1, 0)
        yesBtn.ZIndex = 903
        Library.Utils.MakeCorner(yesBtn, 6)
        yesBtn.Parent = btnRow

        local noBtn = Instance.new("TextButton")
        noBtn.Name = "NoBtn"
        noBtn.Text = "No"
        noBtn.TextColor3 = Color3.fromRGB(255,255,255)
        noBtn.Font = Enum.Font.GothamBold
        noBtn.TextSize = 12
        noBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
        noBtn.BorderSizePixel = 0
        noBtn.Size = UDim2.new(0, 80, 1, 0)
        noBtn.ZIndex = 903
        Library.Utils.MakeCorner(noBtn, 6)
        noBtn.Parent = btnRow

        yesBtn.MouseButton1Click:Connect(function()
            if callback then callback(true) end
            Library._RemoveNotif(notifObj)
        end)
        noBtn.MouseButton1Click:Connect(function()
            if callback then callback(false) end
            Library._RemoveNotif(notifObj)
        end)
    end

    -- Slide in
    Library.Utils.QuickTween(nf, 0.22, {
        Position = UDim2.new(1, -(NOTIF_WIDTH + NOTIF_X_PAD), 0, startY),
        BackgroundTransparency = 0
    })
    Library.Utils.QuickTween(sh, 0.22, {
        Position = UDim2.new(1, -(NOTIF_WIDTH + NOTIF_X_PAD) + 4, 0, startY + 4),
        BackgroundTransparency = 0.6
    })

    -- Auto-dismiss for Normal
    if ntype == "Normal" and duration > 0 then
        task.delay(duration, function()
            if nf.Parent then
                Library._RemoveNotif(notifObj)
            end
        end)
    end

    return notifObj
end

-- ============================================================
-- SCREENGUI INIT
-- ============================================================
function Library._InitGUI()
    -- Clean up existing
    pcall(function()
        local existing = CoreGui:FindFirstChild("RobloxUILibrary")
        if existing then existing:Destroy() end
    end)

    local gui = Instance.new("ScreenGui")
    gui.Name = "RobloxUILibrary"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.DisplayOrder = 999

    -- Try CoreGui first, fallback to PlayerGui
    local ok = pcall(function() gui.Parent = CoreGui end)
    if not ok then
        gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    Library.GUI = gui
    return gui
end

-- ============================================================
-- COLORPICKER ELEMENT (Floating Window)
-- ============================================================
function Library._BuildColorPicker(opts, parentElement)
    opts = opts or {}
    local currentColor = opts.Default or Color3.fromRGB(146, 255, 155)
    local callback     = opts.Callback or function() end
    local rainbowMode  = false
    local syncEnabled  = opts.SyncDefault or false
    local rainbowConn  = nil

    -- Convert current color to HSV
    local r0,g0,b0 = currentColor.R*255, currentColor.G*255, currentColor.B*255
    local h0,s0,v0 = Library.Utils.RGBtoHSV(r0,g0,b0)
    local hue, sat, val = h0, s0, v0

    -- Floating window
    local cpWin = Instance.new("Frame")
    cpWin.Name = "ColorPickerWindow"
    cpWin.BackgroundColor3 = Library.Theme.Panel
    cpWin.BorderSizePixel = 0
    cpWin.Size = UDim2.new(0, 258, 0, 320)
    cpWin.ZIndex = 800
    cpWin.Active = true
    Library.Utils.MakeCorner(cpWin, 12)
    Library.Utils.MakeStroke(cpWin, Library.Theme.Border, 1, 0.2)

    local sh = Instance.new("Frame")
    sh.BackgroundColor3 = Color3.new(0,0,0)
    sh.BackgroundTransparency = 0.55
    sh.BorderSizePixel = 0
    sh.Size = UDim2.new(1, 4, 1, 4)
    sh.Position = UDim2.new(0, 4, 0, 4)
    sh.ZIndex = 799
    Library.Utils.MakeCorner(sh, 13)
    sh.Parent = Library.GUI

    cpWin.Parent = Library.GUI

    -- Position near parent
    if parentElement then
        local abs = parentElement.AbsolutePosition
        cpWin.Position = UDim2.new(0, abs.X - 270, 0, abs.Y)
    else
        cpWin.Position = UDim2.new(0, 20, 0, 60)
    end

    -- Drag
    Library.Dragging.Enable(cpWin, cpWin, nil, nil, nil)

    -- Title bar
    local titleBar = Library.Utils.NewFrame(cpWin, "CPTitleBar", Library.Theme.PanelDark,
        UDim2.new(1, 0, 0, 32), UDim2.new(0,0,0,0), 802)
    Library.Utils.MakeCorner(titleBar, 12)
    local titleLbl = Library.Utils.NewLabel(titleBar, "Colorpicker", 13, Library.Theme.Text,
        Enum.Font.GothamBold, 803)
    titleLbl.Size = UDim2.new(1, -40, 1, 0)
    titleLbl.Position = UDim2.new(0, 12, 0, 0)
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left

    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CPClose"
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Library.Theme.TextSecondary
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 18
    closeBtn.BackgroundTransparency = 1
    closeBtn.Size = UDim2.new(0, 28, 0, 28)
    closeBtn.Position = UDim2.new(1, -32, 0, 2)
    closeBtn.ZIndex = 803
    closeBtn.Parent = titleBar
    closeBtn.MouseButton1Click:Connect(function()
        if rainbowConn then rainbowConn:Disconnect() end
        cpWin:Destroy()
        sh:Destroy()
    end)

    -- Gradient square (SV picker)
    local sqSize = 170
    local sqFrame = Instance.new("Frame")
    sqFrame.Name = "ColorPickerGradientSquare"
    sqFrame.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
    sqFrame.BorderSizePixel = 0
    sqFrame.Size = UDim2.new(0, sqSize, 0, sqSize)
    sqFrame.Position = UDim2.new(0, 10, 0, 38)
    sqFrame.ZIndex = 802
    Library.Utils.MakeCorner(sqFrame, 6)
    sqFrame.Parent = cpWin

    -- White overlay (S: right to left)
    local whiteGrad = Instance.new("UIGradient")
    whiteGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
        ColorSequenceKeypoint.new(1, Color3.new(1,1,1))
    })
    whiteGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 1)
    })
    whiteGrad.Rotation = 0
    whiteGrad.Parent = sqFrame

    -- Black overlay (V: top to bottom)
    local blackOverlay = Instance.new("Frame")
    blackOverlay.Name = "BlackOverlay"
    blackOverlay.BackgroundColor3 = Color3.new(0,0,0)
    blackOverlay.BorderSizePixel = 0
    blackOverlay.Size = UDim2.new(1,0,1,0)
    blackOverlay.ZIndex = 803
    Library.Utils.MakeCorner(blackOverlay, 6)
    blackOverlay.Parent = sqFrame
    local blackGrad = Instance.new("UIGradient")
    blackGrad.Rotation = 90
    blackGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.new(0,0,0)),
        ColorSequenceKeypoint.new(1, Color3.new(0,0,0))
    })
    blackGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(1, 0)
    })
    blackGrad.Parent = blackOverlay

    -- SV Picker dot
    local svDot = Instance.new("Frame")
    svDot.Name = "SVDot"
    svDot.BackgroundColor3 = Color3.new(1,1,1)
    svDot.BorderSizePixel = 2
    svDot.Size = UDim2.new(0, 10, 0, 10)
    svDot.ZIndex = 806
    Library.Utils.MakeCorner(svDot, 6)
    svDot.Position = UDim2.new(s0, -5, 1 - v0, -5)
    svDot.Parent = sqFrame

    -- Hue bar (vertical, right side)
    local hueBar = Instance.new("Frame")
    hueBar.Name = "HueBar"
    hueBar.BackgroundColor3 = Color3.new(1,0,0)
    hueBar.BorderSizePixel = 0
    hueBar.Size = UDim2.new(0, 18, 0, sqSize)
    hueBar.Position = UDim2.new(0, sqSize + 18, 0, 38)
    hueBar.ZIndex = 802
    Library.Utils.MakeCorner(hueBar, 4)
    hueBar.Parent = cpWin

    local hueGrad = Instance.new("UIGradient")
    hueGrad.Rotation = 270
    hueGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0,    Color3.fromHSV(0,   1, 1)),
        ColorSequenceKeypoint.new(0.17, Color3.fromHSV(0.17,1, 1)),
        ColorSequenceKeypoint.new(0.33, Color3.fromHSV(0.33,1, 1)),
        ColorSequenceKeypoint.new(0.5,  Color3.fromHSV(0.5, 1, 1)),
        ColorSequenceKeypoint.new(0.67, Color3.fromHSV(0.67,1, 1)),
        ColorSequenceKeypoint.new(0.83, Color3.fromHSV(0.83,1, 1)),
        ColorSequenceKeypoint.new(1,    Color3.fromHSV(1,   1, 1)),
    })
    hueGrad.Parent = hueBar

    -- Hue dot
    local hueDot = Instance.new("Frame")
    hueDot.Name = "HueDot"
    hueDot.BackgroundColor3 = Color3.new(1,1,1)
    hueDot.BorderSizePixel = 1
    hueDot.Size = UDim2.new(1, 4, 0, 4)
    hueDot.Position = UDim2.new(0, -2, h0, -2)
    hueDot.ZIndex = 806
    hueDot.Parent = hueBar

    -- Alpha/Rainbow horizontal bar
    local rainbowBarFrame = Instance.new("Frame")
    rainbowBarFrame.Name = "RainbowBarFrame"
    rainbowBarFrame.BackgroundColor3 = Color3.new(0,0,0)
    rainbowBarFrame.BorderSizePixel = 0
    rainbowBarFrame.Size = UDim2.new(0, sqSize, 0, 14)
    rainbowBarFrame.Position = UDim2.new(0, 10, 0, 38 + sqSize + 8)
    rainbowBarFrame.ZIndex = 802
    Library.Utils.MakeCorner(rainbowBarFrame, 4)
    rainbowBarFrame.Parent = cpWin

    local rbGrad = Instance.new("UIGradient")
    rbGrad.Rotation = 0
    rbGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0,    Color3.fromHSV(0,   1, 1)),
        ColorSequenceKeypoint.new(0.17, Color3.fromHSV(0.17,1, 1)),
        ColorSequenceKeypoint.new(0.33, Color3.fromHSV(0.33,1, 1)),
        ColorSequenceKeypoint.new(0.5,  Color3.fromHSV(0.5, 1, 1)),
        ColorSequenceKeypoint.new(0.67, Color3.fromHSV(0.67,1, 1)),
        ColorSequenceKeypoint.new(0.83, Color3.fromHSV(0.83,1, 1)),
        ColorSequenceKeypoint.new(1,    Color3.fromHSV(1,   1, 1)),
    })
    rbGrad.Parent = rainbowBarFrame

    -- Sync colorpickers toggle row
    local yOff = 38 + sqSize + 28
    local syncRow = Library.Utils.NewFrame(cpWin, "SyncRow", Color3.fromRGBA(0,0,0,0),
        UDim2.new(1, -20, 0, 22), UDim2.new(0, 10, 0, yOff), 802)
    syncRow.BackgroundTransparency = 1
    local syncLabel = Library.Utils.NewLabel(syncRow, "Sync colorpickers", 12,
        Library.Theme.TextSecondary, Enum.Font.Gotham, 803)
    syncLabel.Size = UDim2.new(1, -40, 1, 0)
    syncLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- Mini toggle for sync
    local syncToggle = Library._MakeMiniToggle(syncRow, syncEnabled, UDim2.new(1, -28, 0, 2), function(state)
        syncEnabled = state
    end)

    yOff = yOff + 26

    -- Rainbow toggle row
    local rbRow = Library.Utils.NewFrame(cpWin, "RainbowRow", Color3.fromRGBA(0,0,0,0),
        UDim2.new(1, -20, 0, 22), UDim2.new(0, 10, 0, yOff), 802)
    rbRow.BackgroundTransparency = 1
    local rbLabel = Library.Utils.NewLabel(rbRow, "Rainbow", 12,
        Library.Theme.TextSecondary, Enum.Font.Gotham, 803)
    rbLabel.Size = UDim2.new(1, -40, 1, 0)
    rbLabel.TextXAlignment = Enum.TextXAlignment.Left

    local rbToggle = Library._MakeMiniToggle(rbRow, false, UDim2.new(1, -28, 0, 2), function(state)
        rainbowMode = state
        if state then
            local t = 0
            rainbowConn = RunService.Heartbeat:Connect(function(dt)
                t = (t + dt * 0.3) % 1
                hue = t
                local rr,gg,bb = Library.Utils.HSVtoRGB(hue, sat, val)
                currentColor = Color3.fromRGB(rr*255, gg*255, bb*255)
                sqFrame.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
                hueDot.Position = UDim2.new(0, -2, hue, -2)
                if parentElement then
                    Library._UpdateColorSwatch(parentElement, currentColor)
                end
                callback(currentColor)
            end)
        else
            if rainbowConn then rainbowConn:Disconnect() rainbowConn = nil end
        end
    end)

    yOff = yOff + 30

    -- HEX + RGB display row
    local hexRow = Library.Utils.NewFrame(cpWin, "HexRGBRow", Color3.fromRGBA(0,0,0,0),
        UDim2.new(1, -20, 0, 28), UDim2.new(0, 10, 0, yOff), 802)
    hexRow.BackgroundTransparency = 1

    local hexBox = Instance.new("TextBox")
    hexBox.Name = "HexInput"
    hexBox.Text = Library.Utils.RGBtoHex(r0, g0, b0)
    hexBox.BackgroundColor3 = Library.Theme.InputBg
    hexBox.BorderSizePixel = 0
    hexBox.Size = UDim2.new(0, 80, 1, 0)
    hexBox.Font = Enum.Font.GothamBold
    hexBox.TextSize = 12
    hexBox.TextColor3 = Library.Theme.Text
    hexBox.PlaceholderText = "#ffffff"
    hexBox.ZIndex = 803
    Library.Utils.MakeCorner(hexBox, 6)
    Library.Utils.MakeStroke(hexBox, Library.Theme.Border, 1, 0.3)
    hexBox.Parent = hexRow

    local rgbLabel = Instance.new("TextLabel")
    rgbLabel.Name = "RGBLabel"
    rgbLabel.Text = math.floor(r0*255)..","..math.floor(g0*255)..","..math.floor(b0*255)
    rgbLabel.BackgroundTransparency = 1
    rgbLabel.Position = UDim2.new(0, 90, 0, 0)
    rgbLabel.Size = UDim2.new(1, -92, 1, 0)
    rgbLabel.Font = Enum.Font.Gotham
    rgbLabel.TextSize = 11
    rgbLabel.TextColor3 = Library.Theme.TextSecondary
    rgbLabel.ZIndex = 803
    rgbLabel.TextXAlignment = Enum.TextXAlignment.Left
    rgbLabel.Parent = hexRow

    -- Helper: refresh displays
    local function refreshDisplays()
        local rr,gg,bb = Library.Utils.HSVtoRGB(hue, sat, val)
        currentColor = Color3.fromRGB(rr*255, gg*255, bb*255)
        hexBox.Text = Library.Utils.RGBtoHex(math.floor(rr*255), math.floor(gg*255), math.floor(bb*255))
        rgbLabel.Text = math.floor(rr*255)..","..math.floor(gg*255)..","..math.floor(bb*255)
        sqFrame.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
        svDot.Position = UDim2.new(sat, -5, 1-val, -5)
        hueDot.Position = UDim2.new(0, -2, hue, -2)
        if parentElement then Library._UpdateColorSwatch(parentElement, currentColor) end
        callback(currentColor)
    end

    -- SV drag
    local svDragging = false
    blackOverlay.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then svDragging = true end
    end)
    sqFrame.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then svDragging = true end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then svDragging = false end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if svDragging and (inp.UserInputType == Enum.UserInputType.MouseMovement) then
            local sqAbs = sqFrame.AbsolutePosition
            local sqSz  = sqFrame.AbsoluteSize
            local mx = math.clamp((inp.Position.X - sqAbs.X) / sqSz.X, 0, 1)
            local my = math.clamp((inp.Position.Y - sqAbs.Y) / sqSz.Y, 0, 1)
            sat = mx
            val = 1 - my
            refreshDisplays()
        end
    end)

    -- Hue drag
    local hueDragging = false
    hueBar.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then hueDragging = true end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then hueDragging = false end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if hueDragging and (inp.UserInputType == Enum.UserInputType.MouseMovement) then
            local hAbs = hueBar.AbsolutePosition
            local hSz  = hueBar.AbsoluteSize
            hue = math.clamp((inp.Position.Y - hAbs.Y) / hSz.Y, 0, 1)
            refreshDisplays()
        end
    end)

    -- Hex input
    hexBox.FocusLost:Connect(function()
        local txt = hexBox.Text
        local rr,gg,bb = Library.Utils.HexToRGB(txt)
        hue, sat, val = Library.Utils.RGBtoHSV(rr, gg, bb)
        refreshDisplays()
    end)

    -- Initial refresh
    refreshDisplays()

    return {
        Frame = cpWin,
        GetColor = function() return currentColor end,
        SetColor = function(c)
            local rr,gg,bb = c.R*255, c.G*255, c.B*255
            hue, sat, val = Library.Utils.RGBtoHSV(rr, gg, bb)
            refreshDisplays()
        end,
    }
end

function Library._MakeMiniToggle(parent, default, pos, onChange)
    local state = default or false
    local track = Instance.new("Frame")
    track.Name = "MiniToggleTrack"
    track.BackgroundColor3 = state and Library.Theme.Toggle or Library.Theme.ToggleOff
    track.BorderSizePixel = 0
    track.Size = UDim2.new(0, 28, 0, 16)
    track.Position = pos
    track.ZIndex = 804
    Library.Utils.MakeCorner(track, 8)
    track.Parent = parent

    local knob = Instance.new("Frame")
    knob.Name = "MiniKnob"
    knob.BackgroundColor3 = Color3.new(1,1,1)
    knob.BorderSizePixel = 0
    knob.Size = UDim2.new(0, 12, 0, 12)
    knob.Position = state and UDim2.new(1, -14, 0, 2) or UDim2.new(0, 2, 0, 2)
    knob.ZIndex = 805
    Library.Utils.MakeCorner(knob, 6)
    knob.Parent = track

    local btn = Instance.new("TextButton")
    btn.Text = ""
    btn.BackgroundTransparency = 1
    btn.Size = UDim2.new(1,0,1,0)
    btn.ZIndex = 806
    btn.Parent = track
    btn.MouseButton1Click:Connect(function()
        state = not state
        Library.Utils.QuickTween(track, 0.2, {BackgroundColor3 = state and Library.Theme.Toggle or Library.Theme.ToggleOff})
        Library.Utils.QuickTween(knob, 0.2, {Position = state and UDim2.new(1,-14,0,2) or UDim2.new(0,2,0,2)})
        if onChange then onChange(state) end
    end)

    return {Track = track, Knob = knob, GetState = function() return state end}
end

function Library._UpdateColorSwatch(element, color)
    -- Update swatch on element row
    if element and element._colorSwatch then
        element._colorSwatch.BackgroundColor3 = color
    end
end

-- ============================================================
-- GRAPH ELEMENT BUILDER
-- ============================================================
function Library._BuildGraph(parent, opts)
    opts = opts or {}
    local width  = opts.Width  or 250
    local height = opts.Height or 90
    local status = opts.Status or ""
    local statusColor = opts.StatusColor or Library.Theme.StatusGreen
    local onChanged  = opts.Callback or function() end

    local container = Instance.new("Frame")
    container.Name = "GraphContainer"
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    container.Size = UDim2.new(1, 0, 0, height + 22)
    container.ZIndex = 5
    container.Parent = parent

    -- Label row
    local labelRow = Library.Utils.NewFrame(container, "GraphLabelRow",
        Color3.fromRGBA(0,0,0,0),
        UDim2.new(1, 0, 0, 20), UDim2.new(0, 0, 0, 0), 5)
    labelRow.BackgroundTransparency = 1

    local titleLbl = Library.Utils.NewLabel(labelRow, opts.Name or "This is a graph", 13,
        Library.Theme.Text, Enum.Font.GothamBold, 6)
    titleLbl.Size = UDim2.new(0.6, 0, 1, 0)
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left

    -- Status / coords label (right side)
    local coordLbl = Library.Utils.NewLabel(labelRow, status ~= "" and status or "X: 0, Y: 0",
        12, status ~= "" and statusColor or Library.Theme.TextDim, Enum.Font.Gotham, 6)
    coordLbl.Size = UDim2.new(0.4, 0, 1, 0)
    coordLbl.Position = UDim2.new(0.6, 0, 0, 0)
    coordLbl.TextXAlignment = Enum.TextXAlignment.Right
    if status ~= "" then coordLbl.TextColor3 = statusColor end

    -- Graph canvas
    local canvas = Instance.new("Frame")
    canvas.Name = "GraphCanvas"
    canvas.BackgroundColor3 = Library.Theme.GraphBg
    canvas.BorderSizePixel = 0
    canvas.Size = UDim2.new(1, 0, 0, height)
    canvas.Position = UDim2.new(0, 0, 0, 22)
    canvas.ZIndex = 5
    canvas.ClipsDescendants = true
    Library.Utils.MakeCorner(canvas, 8)
    Library.Utils.MakeStroke(canvas, Library.Theme.Border, 1, 0.3)
    canvas.Parent = container

    -- Grid lines
    for i = 1, 3 do
        local gl = Library.Utils.NewFrame(canvas, "GridLineH"..i,
            Library.Theme.Border,
            UDim2.new(1, 0, 0, 1),
            UDim2.new(0, 0, i/4, 0), 5)
        gl.BackgroundTransparency = 0.7
    end
    for i = 1, 3 do
        local gl = Library.Utils.NewFrame(canvas, "GridLineV"..i,
            Library.Theme.Border,
            UDim2.new(0, 1, 1, 0),
            UDim2.new(i/4, 0, 0, 0), 5)
        gl.BackgroundTransparency = 0.7
    end

    -- Control points: normalized (0-1) positions
    local points = opts.Points or {
        {x=0.05, y=0.5}, {x=0.28, y=0.8}, {x=0.5, y=0.3},
        {x=0.72, y=0.65}, {x=0.92, y=0.2}
    }

    -- Draw curve using line segments via small frames
    local lineFrames = {}

    local function drawCurve()
        -- Destroy old lines
        for _, lf in ipairs(lineFrames) do lf:Destroy() end
        lineFrames = {}

        local absW = canvas.AbsoluteSize.X
        local absH = canvas.AbsoluteSize.Y
        if absW <= 0 or absH <= 0 then return end

        -- Build pixel coords
        local pts = {}
        for _, p in ipairs(points) do
            table.insert(pts, {x = p.x * absW, y = p.y * absH})
        end

        -- Draw straight segments between points (catmull-rom style with subdivisions)
        local function lerp(a, b, t) return a + (b-a)*t end
        local segs = 24
        for i = 1, #pts - 1 do
            local p0 = pts[math.max(1, i-1)]
            local p1 = pts[i]
            local p2 = pts[math.min(#pts, i+1)]
            local p3 = pts[math.min(#pts, i+2)]
            for s = 0, segs-1 do
                local t1 = s/segs
                local t2 = (s+1)/segs
                -- Catmull-Rom
                local function catmull(p0v, p1v, p2v, p3v, tt)
                    return 0.5 * ((2*p1v) + (-p0v+p2v)*tt + (2*p0v-5*p1v+4*p2v-p3v)*tt*tt + (-p0v+3*p1v-3*p2v+p3v)*tt*tt*tt)
                end
                local x1 = catmull(p0.x, p1.x, p2.x, p3.x, t1)
                local y1 = catmull(p0.y, p1.y, p2.y, p3.y, t1)
                local x2 = catmull(p0.x, p1.x, p2.x, p3.x, t2)
                local y2 = catmull(p0.y, p1.y, p2.y, p3.y, t2)

                -- Draw segment as a thin rotated frame
                local dx = x2 - x1
                local dy = y2 - y1
                local len = math.sqrt(dx*dx + dy*dy)
                if len < 0.5 then continue end
                local angle = math.atan2(dy, dx)
                local midX = (x1+x2)/2
                local midY = (y1+y2)/2

                local seg = Instance.new("Frame")
                seg.Name = "CurveSeg"
                seg.BackgroundColor3 = Library.Theme.GraphLine
                seg.BorderSizePixel = 0
                seg.Size = UDim2.new(0, len+1, 0, 2)
                seg.Position = UDim2.new(0, midX - (len+1)/2, 0, midY - 1)
                seg.Rotation = math.deg(angle)
                seg.ZIndex = 7
                seg.Parent = canvas
                table.insert(lineFrames, seg)
            end
        end
    end

    -- Drag handles for points
    local dotFrames = {}
    local function buildDots()
        for _, d in ipairs(dotFrames) do d:Destroy() end
        dotFrames = {}
        for idx, p in ipairs(points) do
            local dot = Instance.new("Frame")
            dot.Name = "GraphDot"..idx
            dot.BackgroundColor3 = Library.Theme.Accent
            dot.BorderSizePixel = 0
            dot.Size = UDim2.new(0, 10, 0, 10)
            dot.Position = UDim2.new(p.x, -5, p.y, -5)
            dot.ZIndex = 10
            Library.Utils.MakeCorner(dot, 5)
            dot.Parent = canvas
            table.insert(dotFrames, dot)

            -- Drag
            local draggingDot = false
            dot.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then draggingDot = true end
            end)
            UserInputService.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    if draggingDot then
                        draggingDot = false
                        onChanged(points)
                    end
                end
            end)
            UserInputService.InputChanged:Connect(function(inp)
                if draggingDot and inp.UserInputType == Enum.UserInputType.MouseMovement then
                    local absPos = canvas.AbsolutePosition
                    local absSize = canvas.AbsoluteSize
                    local nx = math.clamp((inp.Position.X - absPos.X) / absSize.X, 0, 1)
                    local ny = math.clamp((inp.Position.Y - absPos.Y) / absSize.Y, 0, 1)
                    points[idx] = {x = nx, y = ny}
                    dot.Position = UDim2.new(nx, -5, ny, -5)
                    coordLbl.Text = string.format("X: %.2f, Y: %.2f", nx, 1-ny)
                    drawCurve()
                end
            end)
        end
    end

    -- Draw after a tick (so AbsoluteSize is available)
    task.defer(function()
        drawCurve()
        buildDots()
    end)

    return container
end

-- ============================================================
-- WINDOW BUILDER
-- ============================================================
function Library:CreateWindow(opts)
    opts = opts or {}
    local title       = opts.Title or ".gg/robloxuis version"
    local winWidth    = opts.Width  or 590
    local winHeight   = opts.Height or 480
    local draggable   = opts.Draggable ~= false
    local resizable   = opts.Resizable or false
    local accentColor = opts.AccentColor or Library.Theme.Accent

    if not Library.GUI then Library._InitGUI() end

    -- Shadow
    local shadowFrame = Library.Utils.NewFrame(Library.GUI, "WindowShadow",
        Color3.new(0,0,0),
        UDim2.new(0, winWidth+8, 0, winHeight+8),
        UDim2.new(0.5, -(winWidth/2)-4, 0.5, -(winHeight/2)-4), 1)
    shadowFrame.BackgroundTransparency = 0.55
    Library.Utils.MakeCorner(shadowFrame, 14)

    -- Main window frame
    local win = Library.Utils.NewFrame(Library.GUI, "MainWindowFrame",
        Library.Theme.Background,
        UDim2.new(0, winWidth, 0, winHeight),
        UDim2.new(0.5, -winWidth/2, 0.5, -winHeight/2), 5)
    Library.Utils.MakeCorner(win, 12)
    Library.Utils.MakeStroke(win, Library.Theme.Border, 1, 0.2)

    -- Open animation
    win.BackgroundTransparency = 1
    win.Size = UDim2.new(0, winWidth * 0.95, 0, winHeight * 0.95)
    win.Position = UDim2.new(0.5, -(winWidth*0.95)/2, 0.5, -(winHeight*0.95)/2)
    Library.Utils.QuickTween(win, 0.25, {
        BackgroundTransparency = 0,
        Size = UDim2.new(0, winWidth, 0, winHeight),
        Position = UDim2.new(0.5, -winWidth/2, 0.5, -winHeight/2)
    }, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    -- ---- TOP BAR ----
    local topBar = Library.Utils.NewFrame(win, "TopBar",
        Library.Theme.TopbarBg,
        UDim2.new(1, 0, 0, 46), UDim2.new(0,0,0,0), 6)
    Library.Utils.MakeCorner(topBar, 12)

    -- Cover bottom corners of topbar (it's inside the window)
    local topBarFix = Library.Utils.NewFrame(win, "TopBarFix",
        Library.Theme.TopbarBg,
        UDim2.new(1, 0, 0, 8), UDim2.new(0,0,0,38), 5)

    -- Icon + Title
    local iconLbl = Library.Utils.NewLabel(topBar, "🐺", 18, Library.Theme.Text, Enum.Font.GothamBold, 7)
    iconLbl.Size = UDim2.new(0, 28, 1, 0)
    iconLbl.Position = UDim2.new(0, 10, 0, 0)
    iconLbl.TextXAlignment = Enum.TextXAlignment.Left

    local titleLbl = Library.Utils.NewLabel(topBar, title, 13, Library.Theme.Text, Enum.Font.GothamBold, 7)
    titleLbl.Size = UDim2.new(0, 200, 1, 0)
    titleLbl.Position = UDim2.new(0, 42, 0, 0)
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left

    -- Search bar
    local searchFrame = Library.Utils.NewFrame(topBar, "SearchFrame",
        Library.Theme.InputBg,
        UDim2.new(0, 200, 0, 28), UDim2.new(0.5, -100, 0.5, -14), 7)
    Library.Utils.MakeCorner(searchFrame, 8)
    Library.Utils.MakeStroke(searchFrame, Library.Theme.Border, 1, 0.35)

    local searchIcon = Library.Utils.NewLabel(searchFrame, "🔍", 12, Library.Theme.TextDim, Enum.Font.Gotham, 8)
    searchIcon.Size = UDim2.new(0, 22, 1, 0)
    searchIcon.Position = UDim2.new(0, 4, 0, 0)

    local searchBox = Instance.new("TextBox")
    searchBox.Name = "SearchBox"
    searchBox.PlaceholderText = "Search.."
    searchBox.PlaceholderColor3 = Library.Theme.TextDim
    searchBox.Text = ""
    searchBox.BackgroundTransparency = 1
    searchBox.Size = UDim2.new(1, -28, 1, 0)
    searchBox.Position = UDim2.new(0, 24, 0, 0)
    searchBox.Font = Enum.Font.Gotham
    searchBox.TextSize = 12
    searchBox.TextColor3 = Library.Theme.Text
    searchBox.ZIndex = 8
    searchBox.Parent = searchFrame

    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseBtn"
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Library.Theme.TextSecondary
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 20
    closeBtn.BackgroundTransparency = 1
    closeBtn.Size = UDim2.new(0, 32, 0, 32)
    closeBtn.Position = UDim2.new(1, -38, 0.5, -16)
    closeBtn.ZIndex = 7
    closeBtn.Parent = topBar
    closeBtn.MouseButton1Click:Connect(function()
        -- Auto-save config before close
        if Library.Config.AutoSaveEnabled then Library.Config:Save("__autosave__") end
        Library.Utils.QuickTween(win, 0.25, {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, winWidth*0.95, 0, winHeight*0.95),
            Position = UDim2.new(0.5, -(winWidth*0.95)/2, 0.5, -(winHeight*0.95)/2)
        }):Completed:Connect(function()
            win:Destroy()
            shadowFrame:Destroy()
        end)
    end)

    -- Hover on close
    closeBtn.MouseEnter:Connect(function()
        Library.Utils.QuickTween(closeBtn, 0.1, {TextColor3 = Color3.fromRGB(255,80,80)})
    end)
    closeBtn.MouseLeave:Connect(function()
        Library.Utils.QuickTween(closeBtn, 0.1, {TextColor3 = Library.Theme.TextSecondary})
    end)

    -- ---- SIDEBAR ----
    local sidebarWidth = 46
    local sidebar = Library.Utils.NewFrame(win, "SidebarTabContainer",
        Library.Theme.SidebarBg,
        UDim2.new(0, sidebarWidth, 1, -46), UDim2.new(0, 0, 0, 46), 6)

    local sidebarLayout = Instance.new("UIListLayout")
    sidebarLayout.FillDirection = Enum.FillDirection.Vertical
    sidebarLayout.Padding = UDim.new(0, 4)
    sidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
    sidebarLayout.Parent = sidebar

    local sidebarPad = Instance.new("UIPadding")
    sidebarPad.PaddingTop = UDim.new(0, 8)
    sidebarPad.Parent = sidebar

    -- Active tab highlight bar
    local activeBar = Library.Utils.NewFrame(sidebar, "ActiveTabBar",
        Library.Theme.Accent,
        UDim2.new(0, 3, 0, 24), UDim2.new(0, 0, 0, 8), 8)
    Library.Utils.MakeCorner(activeBar, 2)

    -- ---- CONTENT AREA ----
    local contentArea = Library.Utils.NewFrame(win, "ContentArea",
        Library.Theme.Panel,
        UDim2.new(1, -sidebarWidth, 1, -46),
        UDim2.new(0, sidebarWidth, 0, 46), 5)

    -- Separator line
    local sep = Library.Utils.NewFrame(win, "SidebarSep",
        Library.Theme.Border,
        UDim2.new(0, 1, 1, -46), UDim2.new(0, sidebarWidth, 0, 46), 6)
    sep.BackgroundTransparency = 0.4

    -- Dragging
    if draggable then
        Library.Dragging.Enable(win, topBar)
        -- Keep shadow in sync
        local origWinPos = win.Position
        RunService.Heartbeat:Connect(function()
            if win.Parent then
                local wp = win.Position
                shadowFrame.Position = UDim2.new(wp.X.Scale, wp.X.Offset - 4, wp.Y.Scale, wp.Y.Offset - 4)
            end
        end)
    end

    -- ---- WINDOW OBJECT ----
    local Window = {}
    Window._Frame      = win
    Window._Shadow     = shadowFrame
    Window._Sidebar    = sidebar
    Window._Content    = contentArea
    Window._ActiveBar  = activeBar
    Window._Tabs       = {}
    Window._ActiveTab  = nil
    Window._TabButtons = {}

    function Window:CreateTab(tabOpts)
        tabOpts = tabOpts or {}
        local tabName = tabOpts.Name or "Tab"
        local tabIcon = tabOpts.Icon or "⚙"

        -- Sidebar button
        local tabBtn = Instance.new("TextButton")
        tabBtn.Name = "TabBtn_" .. tabName
        tabBtn.Text = tabIcon
        tabBtn.Font = Enum.Font.GothamBold
        tabBtn.TextSize = 18
        tabBtn.TextColor3 = Library.Theme.TextDim
        tabBtn.BackgroundTransparency = 1
        tabBtn.Size = UDim2.new(0, 36, 0, 36)
        tabBtn.ZIndex = 7
        tabBtn.LayoutOrder = #Window._Tabs + 1
        tabBtn.Parent = sidebar
        Library.Utils.MakeCorner(tabBtn, 8)
        Library._BindTooltip(tabBtn, tabName)

        -- Content frame for this tab
        local tabContent = Library.Utils.NewFrame(contentArea, "TabContent_"..tabName,
            Library.Theme.Panel,
            UDim2.new(1, 0, 1, 0), UDim2.new(0,0,0,0), 5)
        tabContent.Visible = false
        tabContent.ClipsDescendants = true

        -- Scroll frame inside
        local scrollFrame = Instance.new("ScrollingFrame")
        scrollFrame.Name = "TabScroll"
        scrollFrame.BackgroundTransparency = 1
        scrollFrame.BorderSizePixel = 0
        scrollFrame.Size = UDim2.new(1, 0, 1, 0)
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        scrollFrame.ScrollBarThickness = 3
        scrollFrame.ScrollBarImageColor3 = Library.Theme.Accent
        scrollFrame.ZIndex = 5
        scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
        scrollFrame.Parent = tabContent

        -- Two-column layout inside scroll
        local colContainer = Library.Utils.NewFrame(scrollFrame, "ColumnContainer",
            Color3.fromRGBA(0,0,0,0),
            UDim2.new(1, 0, 1, 0), UDim2.new(0,0,0,0), 5)
        colContainer.BackgroundTransparency = 1
        colContainer.AutomaticSize = Enum.AutomaticSize.Y

        local colLayout = Instance.new("UIListLayout")
        colLayout.FillDirection = Enum.FillDirection.Horizontal
        colLayout.SortOrder = Enum.SortOrder.LayoutOrder
        colLayout.Padding = UDim.new(0, 0)
        colLayout.VerticalAlignment = Enum.VerticalAlignment.Top
        colLayout.Parent = colContainer

        local Tab = {}
        Tab._Frame      = tabContent
        Tab._Scroll     = scrollFrame
        Tab._ColContainer = colContainer
        Tab._Sections   = {}
        Tab._Button     = tabBtn
        Tab._Name       = tabName
        Tab._Columns    = {}  -- column frames

        function Tab:CreateColumn(colOpts)
            colOpts = colOpts or {}
            local colWidth = colOpts.Width or 0.5  -- fraction of content area

            local col = Library.Utils.NewFrame(colContainer, "Column_"..(#Tab._Columns+1),
                Color3.fromRGBA(0,0,0,0),
                UDim2.new(colWidth, 0, 0, 10), UDim2.new(0,0,0,0), 5)
            col.BackgroundTransparency = 1
            col.AutomaticSize = Enum.AutomaticSize.Y
            col.LayoutOrder = #Tab._Columns + 1

            local colInnerLayout = Instance.new("UIListLayout")
            colInnerLayout.FillDirection = Enum.FillDirection.Vertical
            colInnerLayout.SortOrder = Enum.SortOrder.LayoutOrder
            colInnerLayout.Padding = UDim.new(0, 0)
            colInnerLayout.Parent = col

            local colPad = Instance.new("UIPadding")
            colPad.PaddingLeft  = UDim.new(0, 8)
            colPad.PaddingRight = UDim.new(0, 8)
            colPad.PaddingTop   = UDim.new(0, 8)
            colPad.Parent = col

            table.insert(Tab._Columns, col)

            local Column = {}
            Column._Frame = col

            function Column:CreateSection(secOpts)
                secOpts = secOpts or {}
                local secName = secOpts.Name or "Section"
                local collapsible = secOpts.Collapsible ~= false

                -- Section header
                local secHeader = Library.Utils.NewFrame(col, "SectionHeader_"..secName,
                    Library.Theme.PanelDark,
                    UDim2.new(1, 0, 0, 30), UDim2.new(0,0,0,0), 6)
                Library.Utils.MakeCorner(secHeader, 8)
                Library.Utils.MakeStroke(secHeader, Library.Theme.Border, 1, 0.35)
                secHeader.LayoutOrder = #col:GetChildren()
                secHeader.AutomaticSize = Enum.AutomaticSize.None

                -- MultiSection icon row (like screenshot right column)
                if secOpts.IconRow then
                    -- Row of small icon buttons
                    local iconRowFrame = Library.Utils.NewFrame(secHeader, "IconRow",
                        Color3.fromRGBA(0,0,0,0),
                        UDim2.new(1, -40, 1, -8), UDim2.new(0, 8, 0, 4), 7)
                    iconRowFrame.BackgroundTransparency = 1
                    local icLayout = Instance.new("UIListLayout")
                    icLayout.FillDirection = Enum.FillDirection.Horizontal
                    icLayout.Padding = UDim.new(0, 6)
                    icLayout.Parent = iconRowFrame
                    for _, ic in ipairs(secOpts.IconRow) do
                        local icBtn = Instance.new("TextButton")
                        icBtn.Text = ic
                        icBtn.Font = Enum.Font.GothamBold
                        icBtn.TextSize = 14
                        icBtn.TextColor3 = Library.Theme.TextDim
                        icBtn.BackgroundTransparency = 1
                        icBtn.Size = UDim2.new(0, 22, 1, 0)
                        icBtn.ZIndex = 7
                        icBtn.Parent = iconRowFrame
                    end
                end

                local secNameLbl = Library.Utils.NewLabel(secHeader, secName, 13,
                    Library.Theme.Text, Enum.Font.GothamBold, 7)
                secNameLbl.Size = UDim2.new(1, -50, 1, 0)
                secNameLbl.Position = UDim2.new(0, 10, 0, 0)
                secNameLbl.TextXAlignment = Enum.TextXAlignment.Left

                -- Collapse icon
                local collapseIcon
                if collapsible then
                    collapseIcon = Library.Utils.NewLabel(secHeader, "⊟", 14,
                        Library.Theme.TextDim, Enum.Font.GothamBold, 7)
                    collapseIcon.Size = UDim2.new(0, 24, 1, 0)
                    collapseIcon.Position = UDim2.new(1, -28, 0, 0)
                    collapseIcon.TextXAlignment = Enum.TextXAlignment.Center
                end

                -- Copy icon (right side, shown in screenshot)
                if secOpts.ShowCopyIcon then
                    local copyIcon = Library.Utils.NewLabel(secHeader, "⧉", 14,
                        Library.Theme.TextDim, Enum.Font.GothamBold, 7)
                    copyIcon.Size = UDim2.new(0, 24, 1, 0)
                    copyIcon.Position = UDim2.new(1, -50, 0, 0)
                    copyIcon.TextXAlignment = Enum.TextXAlignment.Center
                end

                -- Elements container
                local elemContainer = Library.Utils.NewFrame(col, "SectionElements_"..secName,
                    Color3.fromRGBA(0,0,0,0),
                    UDim2.new(1, 0, 0, 0), UDim2.new(0,0,0,0), 5)
                elemContainer.BackgroundTransparency = 1
                elemContainer.AutomaticSize = Enum.AutomaticSize.Y
                elemContainer.LayoutOrder = secHeader.LayoutOrder + 1
                elemContainer.ClipsDescendants = true

                local elemLayout = Instance.new("UIListLayout")
                elemLayout.FillDirection = Enum.FillDirection.Vertical
                elemLayout.SortOrder = Enum.SortOrder.LayoutOrder
                elemLayout.Padding = UDim.new(0, 2)
                elemLayout.Parent = elemContainer

                local elemPad = Instance.new("UIPadding")
                elemPad.PaddingBottom = UDim.new(0, 4)
                elemPad.PaddingTop    = UDim.new(0, 2)
                elemPad.Parent        = elemContainer

                -- Collapse logic
                local collapsed = false
                local fullHeight = 0

                if collapsible then
                    secHeader.MouseButton1Click:Connect(function()
                        collapsed = not collapsed
                        if collapsed then
                            collapseIcon.Text = "⊞"
                            Library.Utils.QuickTween(elemContainer, 0.25, {Size = UDim2.new(1, 0, 0, 0)})
                        else
                            collapseIcon.Text = "⊟"
                            elemContainer.AutomaticSize = Enum.AutomaticSize.Y
                            Library.Utils.QuickTween(elemContainer, 0.25, {Size = UDim2.new(1, 0, 0, fullHeight)})
                        end
                    end)
                end

                -- Section object
                local Section = {}
                Section._Container = elemContainer
                Section._Header    = secHeader

                -- ---- ELEMENT BUILDERS ----

                -- Helper: standard row frame
                local function makeRow(name, h)
                    local row = Library.Utils.NewFrame(elemContainer, name,
                        Color3.fromRGBA(0,0,0,0),
                        UDim2.new(1, 0, 0, h or 32), nil, 6)
                    row.BackgroundTransparency = 1
                    row.LayoutOrder = #elemContainer:GetChildren()
                    return row
                end

                -- Helper: row label (left side)
                local function rowLabel(row, text, size, color)
                    local lbl = Library.Utils.NewLabel(row, text, size or 13,
                        color or Library.Theme.TextSecondary, Enum.Font.Gotham, 7)
                    lbl.Size = UDim2.new(0.5, 0, 1, 0)
                    lbl.TextXAlignment = Enum.TextXAlignment.Left
                    lbl.Position = UDim2.new(0, 0, 0, 0)
                    return lbl
                end

                -- ---- TOGGLE ----
                function Section:CreateToggle(topts)
                    topts = topts or {}
                    local tname    = topts.Name or "Toggle"
                    local tdefault = topts.Default or false
                    local tcb      = topts.Callback or function() end
                    local tmode    = topts.Mode or "Toggle"
                    local tooltip  = topts.Tooltip or ""
                    local state    = tdefault

                    local row = makeRow("ToggleRow_"..tname, 30)

                    local lbl = rowLabel(row, tname)
                    lbl.Size = UDim2.new(1, -46, 1, 0)

                    -- Checkbox style toggle (as seen in screenshot: blue checkbox when on)
                    local checkBg = Library.Utils.NewFrame(row, "CheckBg",
                        state and Library.Theme.CheckFill or Library.Theme.ToggleOff,
                        UDim2.new(0, 20, 0, 20), UDim2.new(1, -24, 0.5, -10), 7)
                    Library.Utils.MakeCorner(checkBg, 5)
                    Library.Utils.MakeStroke(checkBg, Library.Theme.Border, 1, 0.2)

                    local checkMark = Library.Utils.NewLabel(checkBg, "✓", 14,
                        Color3.new(1,1,1), Enum.Font.GothamBold, 8)
                    checkMark.Size = UDim2.new(1,0,1,0)
                    checkMark.TextXAlignment = Enum.TextXAlignment.Center
                    checkMark.BackgroundTransparency = 1
                    checkMark.TextTransparency = state and 0 or 1

                    -- Click area
                    local btn = Instance.new("TextButton")
                    btn.Text = ""
                    btn.BackgroundTransparency = 1
                    btn.Size = UDim2.new(1, 0, 1, 0)
                    btn.ZIndex = 9
                    btn.Parent = row

                    local function setState(newState, fire)
                        state = newState
                        Library.Utils.QuickTween(checkBg, 0.2, {
                            BackgroundColor3 = state and Library.Theme.CheckFill or Library.Theme.ToggleOff
                        })
                        Library.Utils.QuickTween(checkMark, 0.15, {
                            TextTransparency = state and 0 or 1
                        })
                        if fire then tcb(state) end
                        -- Auto-save
                        if Library.Config.AutoSaveEnabled then
                            Library.Config:_Debounce()
                        end
                    end

                    btn.MouseButton1Click:Connect(function()
                        if tmode == "Toggle" then setState(not state, true)
                        elseif tmode == "Always" then setState(true, true)
                        end
                    end)

                    if tmode == "Hold" then
                        btn.MouseButton1Down:Connect(function() setState(true, true) end)
                        btn.MouseButton1Up:Connect(function() setState(false, true) end)
                        UserInputService.InputEnded:Connect(function(inp)
                            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                                setState(false, true)
                            end
                        end)
                    end

                    -- Hover
                    btn.MouseEnter:Connect(function()
                        Library.Utils.QuickTween(row, 0.1, {BackgroundTransparency = 0.92})
                    end)
                    btn.MouseLeave:Connect(function()
                        Library.Utils.QuickTween(row, 0.1, {BackgroundTransparency = 1})
                    end)

                    if tooltip ~= "" then Library._BindTooltip(btn, tooltip) end

                    -- Register element
                    local id = Library.Utils.Unique("Toggle")
                    local el = {
                        _id = id, _type = "Toggle", _name = tname,
                        _state = state, _row = row,
                        Set = function(self, val) setState(val, true) end,
                        Get = function(self) return state end,
                        Update = function(self, o) if o.Name then lbl.Text = o.Name end end,
                        Destroy = function(self) row:Destroy() end,
                        FireCallback = function(self) tcb(state) end,
                    }
                    Library.Elements[id] = el
                    fullHeight = fullHeight + 32
                    return el
                end

                -- ---- SLIDER ----
                function Section:CreateSlider(sopts)
                    sopts = sopts or {}
                    local sname   = sopts.Name or "Slider"
                    local smin    = sopts.Min or 0
                    local smax    = sopts.Max or 1
                    local sstep   = sopts.Step or 0.01
                    local sdef    = sopts.Default or smin
                    local ssuffix = sopts.Suffix or ""
                    local scb     = sopts.Callback or function() end
                    local tooltip = sopts.Tooltip or ""
                    local value   = sdef

                    local row = makeRow("SliderRow_"..sname, 44)

                    -- Name + value row
                    local topRow = Library.Utils.NewFrame(row, "SliderTopRow",
                        Color3.fromRGBA(0,0,0,0),
                        UDim2.new(1, 0, 0, 18), UDim2.new(0,0,0,0), 6)
                    topRow.BackgroundTransparency = 1

                    local nameLbl = Library.Utils.NewLabel(topRow, sname, 12,
                        Library.Theme.TextSecondary, Enum.Font.Gotham, 7)
                    nameLbl.Size = UDim2.new(0.65, 0, 1, 0)
                    nameLbl.TextXAlignment = Enum.TextXAlignment.Left

                    local valLbl = Library.Utils.NewLabel(topRow, tostring(value)..ssuffix, 12,
                        Library.Theme.TextDim, Enum.Font.GothamBold, 7)
                    valLbl.Size = UDim2.new(0.35, 0, 1, 0)
                    valLbl.Position = UDim2.new(0.65, 0, 0, 0)
                    valLbl.TextXAlignment = Enum.TextXAlignment.Right

                    -- Track
                    local track = Library.Utils.NewFrame(row, "SliderTrack",
                        Library.Theme.SliderTrack,
                        UDim2.new(1, 0, 0, 6), UDim2.new(0, 0, 0, 22), 7)
                    Library.Utils.MakeCorner(track, 3)

                    -- Fill
                    local fill = Library.Utils.NewFrame(track, "SliderFill",
                        Library.Theme.SliderFill,
                        UDim2.new((value-smin)/(smax-smin), 0, 1, 0),
                        UDim2.new(0,0,0,0), 8)
                    Library.Utils.MakeCorner(fill, 3)

                    -- Knob
                    local knob = Library.Utils.NewFrame(track, "SliderKnob",
                        Color3.new(1,1,1),
                        UDim2.new(0, 12, 0, 12),
                        UDim2.new((value-smin)/(smax-smin), -6, 0.5, -6), 9)
                    Library.Utils.MakeCorner(knob, 6)

                    local draggingSlider = false

                    local function setSliderValue(raw)
                        local pct = math.clamp((raw - smin)/(smax - smin), 0, 1)
                        -- Snap to step
                        local stepped = smin + math.floor((raw - smin)/sstep + 0.5)*sstep
                        stepped = math.clamp(stepped, smin, smax)
                        stepped = math.floor(stepped * 1000 + 0.5) / 1000
                        value = stepped
                        local displayVal
                        if sstep >= 1 then
                            displayVal = tostring(math.floor(stepped))
                        else
                            displayVal = string.format("%.2f", stepped)
                        end
                        valLbl.Text = displayVal .. ssuffix
                        Library.Utils.QuickTween(fill, 0.08, {Size = UDim2.new(pct, 0, 1, 0)})
                        Library.Utils.QuickTween(knob, 0.08, {Position = UDim2.new(pct, -6, 0.5, -6)})
                        scb(stepped)
                        if Library.Config.AutoSaveEnabled then Library.Config:_Debounce() end
                    end

                    local function handleSliderInput(inp)
                        local absPos  = track.AbsolutePosition
                        local absSize = track.AbsoluteSize
                        local pct = math.clamp((inp.Position.X - absPos.X) / absSize.X, 0, 1)
                        setSliderValue(smin + pct*(smax-smin))
                    end

                    track.InputBegan:Connect(function(inp)
                        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                            draggingSlider = true
                            handleSliderInput(inp)
                        end
                    end)
                    UserInputService.InputEnded:Connect(function(inp)
                        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                            draggingSlider = false
                        end
                    end)
                    UserInputService.InputChanged:Connect(function(inp)
                        if draggingSlider and inp.UserInputType == Enum.UserInputType.MouseMovement then
                            handleSliderInput(inp)
                        end
                    end)

                    if tooltip ~= "" then Library._BindTooltip(track, tooltip) end

                    local id = Library.Utils.Unique("Slider")
                    local el = {
                        _id = id, _type = "Slider", _name = sname,
                        Set = function(self, v) setSliderValue(v) end,
                        Get = function(self) return value end,
                        Update = function(self, o)
                            if o.Min then smin = o.Min end
                            if o.Max then smax = o.Max end
                        end,
                        Destroy = function(self) row:Destroy() end,
                        FireCallback = function(self) scb(value) end,
                    }
                    Library.Elements[id] = el
                    fullHeight = fullHeight + 46
                    return el
                end

                -- ---- DROPDOWN ----
                function Section:CreateDropdown(dopts)
                    dopts = dopts or {}
                    local dname    = dopts.Name or "Dropdown"
                    local doptions = dopts.Options or {}
                    local ddefault = dopts.Default or (doptions[1] or "")
                    local dcb      = dopts.Callback or function() end
                    local tooltip  = dopts.Tooltip or ""
                    local selected = ddefault
                    local open     = false

                    local row = makeRow("DropdownRow_"..dname, 56)

                    local nameLbl = rowLabel(row, dname)

                    -- Selected display box
                    local dropBox = Library.Utils.NewFrame(row, "DropdownBox",
                        Library.Theme.DropdownBg,
                        UDim2.new(1, 0, 0, 28), UDim2.new(0, 0, 0, 24), 7)
                    Library.Utils.MakeCorner(dropBox, 8)
                    Library.Utils.MakeStroke(dropBox, Library.Theme.Border, 1, 0.3)

                    local selLbl = Library.Utils.NewLabel(dropBox, selected, 12,
                        Library.Theme.Text, Enum.Font.Gotham, 8)
                    selLbl.Size = UDim2.new(1, -40, 1, 0)
                    selLbl.Position = UDim2.new(0, 10, 0, 0)
                    selLbl.TextXAlignment = Enum.TextXAlignment.Left

                    -- Copy icon
                    local copyIco = Library.Utils.NewLabel(dropBox, "⧉", 14,
                        Library.Theme.TextDim, Enum.Font.GothamBold, 8)
                    copyIco.Size = UDim2.new(0, 24, 1, 0)
                    copyIco.Position = UDim2.new(1, -28, 0, 0)
                    copyIco.TextXAlignment = Enum.TextXAlignment.Center

                    -- Expand list (appended below, in scrollframe parent)
                    local listFrame = nil

                    local function closeDropdown()
                        open = false
                        if listFrame then
                            Library.Utils.QuickTween(listFrame, 0.15, {Size = UDim2.new(0, dropBox.AbsoluteSize.X, 0, 0)}):Completed:Connect(function()
                                if listFrame then listFrame:Destroy() listFrame = nil end
                            end)
                        end
                    end

                    local function openDropdown()
                        open = true
                        if listFrame then listFrame:Destroy() end
                        local absPos  = dropBox.AbsolutePosition
                        local absSize = dropBox.AbsoluteSize
                        local sgPos   = Library.GUI.AbsolutePosition

                        listFrame = Library.Utils.NewFrame(Library.GUI, "DropdownList",
                            Library.Theme.DropdownBg,
                            UDim2.new(0, absSize.X, 0, 0),
                            UDim2.new(0, absPos.X - sgPos.X, 0, absPos.Y - sgPos.Y + absSize.Y + 4), 500)
                        Library.Utils.MakeCorner(listFrame, 8)
                        Library.Utils.MakeStroke(listFrame, Library.Theme.Border, 1, 0.25)
                        listFrame.ClipsDescendants = true

                        -- Search input
                        local searchTb = Instance.new("TextBox")
                        searchTb.Name = "DropSearchBox"
                        searchTb.PlaceholderText = "Search..."
                        searchTb.PlaceholderColor3 = Library.Theme.TextDim
                        searchTb.Text = ""
                        searchTb.BackgroundColor3 = Library.Theme.InputBg
                        searchTb.BorderSizePixel = 0
                        searchTb.Size = UDim2.new(1, -10, 0, 24)
                        searchTb.Position = UDim2.new(0, 5, 0, 4)
                        searchTb.Font = Enum.Font.Gotham
                        searchTb.TextSize = 11
                        searchTb.TextColor3 = Library.Theme.Text
                        searchTb.ZIndex = 501
                        Library.Utils.MakeCorner(searchTb, 5)
                        searchTb.Parent = listFrame

                        local itemContainer = Instance.new("ScrollingFrame")
                        itemContainer.BackgroundTransparency = 1
                        itemContainer.BorderSizePixel = 0
                        itemContainer.Size = UDim2.new(1, 0, 1, -32)
                        itemContainer.Position = UDim2.new(0, 0, 0, 30)
                        itemContainer.ZIndex = 501
                        itemContainer.CanvasSize = UDim2.new(0,0,0,0)
                        itemContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
                        itemContainer.ScrollBarThickness = 2
                        itemContainer.ScrollBarImageColor3 = Library.Theme.Accent
                        itemContainer.Parent = listFrame

                        local itemLayout = Instance.new("UIListLayout")
                        itemLayout.FillDirection = Enum.FillDirection.Vertical
                        itemLayout.Padding = UDim.new(0, 1)
                        itemLayout.Parent = itemContainer

                        local function buildItems(filter)
                            itemContainer:ClearAllChildren()
                            local layout2 = Instance.new("UIListLayout")
                            layout2.FillDirection = Enum.FillDirection.Vertical
                            layout2.Padding = UDim.new(0, 1)
                            layout2.Parent = itemContainer

                            for _, opt in ipairs(doptions) do
                                if filter and filter ~= "" and not opt:lower():find(filter:lower(), 1, true) then
                                    continue
                                end
                                local item = Instance.new("TextButton")
                                item.Name = "DropItem_"..opt
                                item.Text = (opt == selected and "✓  " or "   ") .. opt
                                item.Font = Enum.Font.Gotham
                                item.TextSize = 12
                                item.TextColor3 = opt == selected and Library.Theme.Accent or Library.Theme.Text
                                item.BackgroundTransparency = 1
                                item.Size = UDim2.new(1, 0, 0, 26)
                                item.ZIndex = 502
                                item.TextXAlignment = Enum.TextXAlignment.Left
                                local ip = Instance.new("UIPadding")
                                ip.PaddingLeft = UDim.new(0, 10)
                                ip.Parent = item
                                item.Parent = itemContainer

                                item.MouseEnter:Connect(function()
                                    Library.Utils.QuickTween(item, 0.1, {BackgroundTransparency = 0.85})
                                    item.BackgroundColor3 = Library.Theme.Accent
                                end)
                                item.MouseLeave:Connect(function()
                                    Library.Utils.QuickTween(item, 0.1, {BackgroundTransparency = 1})
                                end)
                                item.MouseButton1Click:Connect(function()
                                    selected = opt
                                    selLbl.Text = opt
                                    dcb(opt)
                                    closeDropdown()
                                    if Library.Config.AutoSaveEnabled then Library.Config:_Debounce() end
                                end)
                            end
                        end

                        buildItems("")
                        local itemCount = math.min(#doptions, 6)
                        local listH = 32 + itemCount * 27
                        Library.Utils.QuickTween(listFrame, 0.15, {Size = UDim2.new(0, absSize.X, 0, listH)})

                        searchTb:GetPropertyChangedSignal("Text"):Connect(function()
                            buildItems(searchTb.Text)
                        end)

                        -- Click outside closes
                        local closeConn
                        closeConn = UserInputService.InputBegan:Connect(function(inp)
                            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                                task.wait()
                                if open then closeDropdown() end
                                closeConn:Disconnect()
                            end
                        end)
                    end

                    local dropBtn = Instance.new("TextButton")
                    dropBtn.Text = ""
                    dropBtn.BackgroundTransparency = 1
                    dropBtn.Size = UDim2.new(1, 0, 1, 0)
                    dropBtn.ZIndex = 9
                    dropBtn.Parent = dropBox
                    dropBtn.MouseButton1Click:Connect(function()
                        if open then closeDropdown() else openDropdown() end
                    end)

                    if tooltip ~= "" then Library._BindTooltip(dropBtn, tooltip) end

                    local id = Library.Utils.Unique("Dropdown")
                    local el = {
                        _id = id, _type = "Dropdown", _name = dname,
                        Set = function(self, v) selected = v selLbl.Text = v end,
                        Get = function(self) return selected end,
                        AddOption = function(self, opt) table.insert(doptions, opt) end,
                        RemoveOption = function(self, opt)
                            for i,v in ipairs(doptions) do if v == opt then table.remove(doptions,i) break end end
                        end,
                        Update = function(self, o) if o.Options then doptions = o.Options end end,
                        Destroy = function(self) row:Destroy() end,
                        FireCallback = function(self) dcb(selected) end,
                    }
                    Library.Elements[id] = el
                    fullHeight = fullHeight + 58
                    return el
                end

                -- ---- TEXTBOX ----
                function Section:CreateTextbox(tbOpts)
                    tbOpts = tbOpts or {}
                    local tname  = tbOpts.Name or "Textbox"
                    local tph    = tbOpts.Placeholder or "Placeholder text"
                    local tcb    = tbOpts.Callback or function() end
                    local tentcb = tbOpts.OnEnter or function() end
                    local multiLine = tbOpts.MultiLine or false
                    local tooltip   = tbOpts.Tooltip or ""

                    local row = makeRow("TextboxRow_"..tname, multiLine and 64 or 48)

                    local nameLbl = rowLabel(row, tname)

                    local tbFrame = Library.Utils.NewFrame(row, "TBFrame",
                        Library.Theme.InputBg,
                        UDim2.new(1, 0, 0, multiLine and 48 or 28), UDim2.new(0, 0, 0, 18), 7)
                    Library.Utils.MakeCorner(tbFrame, 8)
                    Library.Utils.MakeStroke(tbFrame, Library.Theme.Border, 1, 0.35)

                    local tbInput = Instance.new("TextBox")
                    tbInput.Name = "TextInput"
                    tbInput.PlaceholderText = tph
                    tbInput.PlaceholderColor3 = Library.Theme.TextDim
                    tbInput.Text = tbOpts.Default or ""
                    tbInput.BackgroundTransparency = 1
                    tbInput.Size = UDim2.new(1, -16, 1, 0)
                    tbInput.Position = UDim2.new(0, 8, 0, 0)
                    tbInput.Font = Enum.Font.Gotham
                    tbInput.TextSize = 12
                    tbInput.TextColor3 = Library.Theme.Text
                    tbInput.TextXAlignment = Enum.TextXAlignment.Left
                    tbInput.MultiLine = multiLine
                    tbInput.TextWrapped = multiLine
                    tbInput.ClearTextOnFocus = false
                    tbInput.ZIndex = 8
                    tbInput.Parent = tbFrame

                    -- Focus glow
                    tbInput.Focused:Connect(function()
                        Library.Utils.QuickTween(tbFrame, 0.15, {BackgroundColor3 = Color3.fromRGB(30, 36, 52)})
                        Library.Utils.MakeStroke(tbFrame, Library.Theme.Accent, 1, 0.2)
                    end)
                    tbInput.FocusLost:Connect(function(enter)
                        Library.Utils.QuickTween(tbFrame, 0.15, {BackgroundColor3 = Library.Theme.InputBg})
                        Library.Utils.MakeStroke(tbFrame, Library.Theme.Border, 1, 0.35)
                        tcb(tbInput.Text)
                        if enter then tentcb(tbInput.Text) end
                        if Library.Config.AutoSaveEnabled then Library.Config:_Debounce() end
                    end)

                    if tooltip ~= "" then Library._BindTooltip(tbInput, tooltip) end

                    local id = Library.Utils.Unique("Textbox")
                    local el = {
                        _id = id, _type = "Textbox", _name = tname,
                        Set = function(self, v) tbInput.Text = v end,
                        Get = function(self) return tbInput.Text end,
                        Update = function(self, o)
                            if o.Placeholder then tbInput.PlaceholderText = o.Placeholder end
                        end,
                        Destroy = function(self) row:Destroy() end,
                        FireCallback = function(self) tcb(tbInput.Text) end,
                    }
                    Library.Elements[id] = el
                    fullHeight = fullHeight + (multiLine and 66 or 50)
                    return el
                end

                -- ---- TEXT LABEL ----
                function Section:CreateLabel(lOpts)
                    lOpts = lOpts or {}
                    local ltext  = lOpts.Name or lOpts.Text or "Label"
                    local lcolor = lOpts.Color or Library.Theme.TextSecondary
                    local lfont  = lOpts.Bold and Enum.Font.GothamBold or Enum.Font.Gotham
                    local lsize  = lOpts.TextSize or 12

                    local row = makeRow("LabelRow_"..ltext, 26)
                    local lbl = Library.Utils.NewLabel(row, ltext, lsize, lcolor, lfont, 7)
                    lbl.Size = UDim2.new(1, 0, 1, 0)
                    lbl.TextXAlignment = Enum.TextXAlignment.Left

                    local id = Library.Utils.Unique("Label")
                    local el = {
                        _id = id, _type = "Label",
                        Set = function(self, v) lbl.Text = v end,
                        Get = function(self) return lbl.Text end,
                        Update = function(self, o) if o.Text then lbl.Text = o.Text end end,
                        Destroy = function(self) row:Destroy() end,
                        FireCallback = function() end,
                    }
                    Library.Elements[id] = el
                    fullHeight = fullHeight + 28
                    return el
                end

                -- ---- BUTTON ----
                function Section:CreateButton(bOpts)
                    bOpts = bOpts or {}
                    local bname   = bOpts.Name or "Button"
                    local bstyle  = bOpts.Style or "Normal"  -- Normal / Accent
                    local bcb     = bOpts.Callback or function() end
                    local tooltip = bOpts.Tooltip or ""

                    local row = makeRow("ButtonRow_"..bname, 34)
                    row.BackgroundTransparency = 1

                    local btn = Instance.new("TextButton")
                    btn.Name = "Btn_"..bname
                    btn.Text = bname
                    btn.Font = Enum.Font.GothamBold
                    btn.TextSize = 12
                    btn.TextColor3 = Library.Theme.Text
                    btn.BackgroundColor3 = bstyle == "Accent" and Library.Theme.Accent or Library.Theme.ButtonBg
                    btn.BorderSizePixel = 0
                    btn.Size = UDim2.new(1, 0, 0, 28)
                    btn.Position = UDim2.new(0, 0, 0, 3)
                    btn.ZIndex = 7
                    Library.Utils.MakeCorner(btn, 8)
                    Library.Utils.MakeStroke(btn, Library.Theme.Border, 1, 0.3)
                    btn.Parent = row

                    -- Hover/click animations
                    btn.MouseEnter:Connect(function()
                        Library.Utils.QuickTween(btn, 0.1, {
                            BackgroundColor3 = bstyle == "Accent" and Library.Theme.AccentHover or Library.Theme.ButtonHover,
                            Size = UDim2.new(1, 0, 0, 29)
                        })
                    end)
                    btn.MouseLeave:Connect(function()
                        Library.Utils.QuickTween(btn, 0.1, {
                            BackgroundColor3 = bstyle == "Accent" and Library.Theme.Accent or Library.Theme.ButtonBg,
                            Size = UDim2.new(1, 0, 0, 28)
                        })
                    end)
                    btn.MouseButton1Click:Connect(function()
                        -- Ripple
                        local ripple = Instance.new("Frame")
                        ripple.BackgroundColor3 = Color3.new(1,1,1)
                        ripple.BackgroundTransparency = 0.7
                        ripple.BorderSizePixel = 0
                        ripple.Size = UDim2.new(0, 0, 0, 0)
                        ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
                        ripple.ZIndex = btn.ZIndex + 1
                        Library.Utils.MakeCorner(ripple, 0)
                        ripple.Parent = btn
                        Library.Utils.QuickTween(ripple, 0.3, {
                            Size = UDim2.new(2, 0, 4, 0),
                            BackgroundTransparency = 1,
                            Position = UDim2.new(-0.5, 0, -1.5, 0)
                        }):Completed:Connect(function() ripple:Destroy() end)
                        bcb()
                    end)

                    if tooltip ~= "" then Library._BindTooltip(btn, tooltip) end

                    local id = Library.Utils.Unique("Button")
                    local el = {
                        _id = id, _type = "Button", _name = bname,
                        Set = function(self, v) btn.Text = v end,
                        Get = function(self) return bname end,
                        Update = function(self, o) if o.Name then btn.Text = o.Name end end,
                        Destroy = function(self) row:Destroy() end,
                        FireCallback = function(self) bcb() end,
                    }
                    Library.Elements[id] = el
                    fullHeight = fullHeight + 36
                    return el
                end

                -- ---- BUTTON ROW (two side by side, as seen in screenshot) ----
                function Section:CreateButtonRow(brOpts)
                    brOpts = brOpts or {}
                    local buttons = brOpts.Buttons or {
                        {Name = "Button", Callback = function() end},
                        {Name = "Button", Callback = function() end},
                    }

                    local row = makeRow("ButtonRowDouble", 36)
                    row.BackgroundTransparency = 1

                    local rowLayout = Instance.new("UIListLayout")
                    rowLayout.FillDirection = Enum.FillDirection.Horizontal
                    rowLayout.Padding = UDim.new(0, 6)
                    rowLayout.Parent = row

                    for _, bOpts in ipairs(buttons) do
                        local btn = Instance.new("TextButton")
                        btn.Text = bOpts.Name or "Button"
                        btn.Font = Enum.Font.GothamBold
                        btn.TextSize = 12
                        btn.TextColor3 = Library.Theme.Text
                        btn.BackgroundColor3 = Library.Theme.ButtonBg
                        btn.BorderSizePixel = 0
                        btn.Size = UDim2.new(0.5, -3, 0, 28)
                        btn.ZIndex = 7
                        Library.Utils.MakeCorner(btn, 8)
                        Library.Utils.MakeStroke(btn, Library.Theme.Border, 1, 0.3)
                        btn.Parent = row

                        btn.MouseEnter:Connect(function()
                            Library.Utils.QuickTween(btn, 0.1, {BackgroundColor3 = Library.Theme.ButtonHover})
                        end)
                        btn.MouseLeave:Connect(function()
                            Library.Utils.QuickTween(btn, 0.1, {BackgroundColor3 = Library.Theme.ButtonBg})
                        end)
                        btn.MouseButton1Click:Connect(function()
                            if bOpts.Callback then bOpts.Callback() end
                        end)
                    end

                    fullHeight = fullHeight + 38
                end

                -- ---- COLORPICKER ROW ----
                function Section:CreateColorpicker(cpOpts)
                    cpOpts = cpOpts or {}
                    local cpname    = cpOpts.Name or "Colorpicker"
                    local cpdefault = cpOpts.Default or Color3.fromRGB(146, 255, 155)
                    local cpcb      = cpOpts.Callback or function() end
                    local tooltip   = cpOpts.Tooltip or ""
                    local twoSwatches = cpOpts.TwoSwatches or false  -- like screenshot shows two boxes

                    local row = makeRow("ColorpickerRow_"..cpname, 32)

                    local nameLbl = rowLabel(row, cpname)
                    nameLbl.Size = UDim2.new(1, -80, 1, 0)

                    -- Checkerboard + color swatch (two boxes as shown in screenshot)
                    local swatchRow = Library.Utils.NewFrame(row, "SwatchRow",
                        Color3.fromRGBA(0,0,0,0),
                        UDim2.new(0, 70, 0, 22), UDim2.new(1, -74, 0.5, -11), 7)
                    swatchRow.BackgroundTransparency = 1

                    local swLayout = Instance.new("UIListLayout")
                    swLayout.FillDirection = Enum.FillDirection.Horizontal
                    swLayout.Padding = UDim.new(0, 4)
                    swLayout.Parent = swatchRow

                    -- Checkerboard swatch
                    local checkSwatch = Library.Utils.NewFrame(swatchRow, "CheckerSwatch",
                        Color3.fromRGB(180, 180, 180),
                        UDim2.new(0, 32, 1, 0), nil, 8)
                    Library.Utils.MakeCorner(checkSwatch, 5)
                    Library.Utils.MakeStroke(checkSwatch, Library.Theme.Border, 1, 0.2)
                    -- Checkerboard pattern via UIGradient
                    local cg = Instance.new("UIGradient")
                    cg.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(160,160,160)),
                        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(200,200,200)),
                        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(160,160,160)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(200,200,200)),
                    })
                    cg.Rotation = 45
                    cg.Parent = checkSwatch

                    -- Color swatch
                    local colorSwatch = Library.Utils.NewFrame(swatchRow, "ColorSwatch",
                        cpdefault,
                        UDim2.new(0, 32, 1, 0), nil, 8)
                    Library.Utils.MakeCorner(colorSwatch, 5)
                    Library.Utils.MakeStroke(colorSwatch, Library.Theme.Border, 1, 0.2)

                    -- Click to open colorpicker
                    local cpOpen = false
                    local cpInstance = nil

                    local clickBtn = Instance.new("TextButton")
                    clickBtn.Text = ""
                    clickBtn.BackgroundTransparency = 1
                    clickBtn.Size = UDim2.new(1, 0, 1, 0)
                    clickBtn.ZIndex = 10
                    clickBtn.Parent = swatchRow
                    clickBtn.MouseButton1Click:Connect(function()
                        if cpOpen and cpInstance then
                            cpInstance.Frame:Destroy()
                            cpOpen = false
                        else
                            cpOpen = true
                            local rowEl = {
                                _colorSwatch = colorSwatch,
                                AbsolutePosition = colorSwatch.AbsolutePosition,
                            }
                            cpInstance = Library._BuildColorPicker({
                                Default = cpdefault,
                                Callback = function(c)
                                    colorSwatch.BackgroundColor3 = c
                                    cpcb(c)
                                    if Library.Config.AutoSaveEnabled then Library.Config:_Debounce() end
                                end
                            }, colorSwatch)
                        end
                    end)

                    if tooltip ~= "" then Library._BindTooltip(clickBtn, tooltip) end

                    local id = Library.Utils.Unique("Colorpicker")
                    local el = {
                        _id = id, _type = "Colorpicker", _name = cpname,
                        _colorSwatch = colorSwatch,
                        Set = function(self, c)
                            colorSwatch.BackgroundColor3 = c
                            cpdefault = c
                        end,
                        Get = function(self) return colorSwatch.BackgroundColor3 end,
                        Update = function(self, o) end,
                        Destroy = function(self) row:Destroy() end,
                        FireCallback = function(self) cpcb(colorSwatch.BackgroundColor3) end,
                    }
                    Library.Elements[id] = el
                    fullHeight = fullHeight + 34
                    return el
                end

                -- ---- KEYBIND ----
                function Section:CreateKeybind(kOpts)
                    kOpts = kOpts or {}
                    local kname    = kOpts.Name or "Keybinds"
                    local kdefault = kOpts.Default or Enum.KeyCode.Unknown
                    local kcb      = kOpts.Callback or function() end
                    local tooltip  = kOpts.Tooltip or ""
                    local listening = false
                    local boundKey  = kdefault
                    local modifiers = {}

                    local row = makeRow("KeybindRow_"..kname, 30)
                    local nameLbl = rowLabel(row, kname)
                    nameLbl.Size = UDim2.new(1, -100, 1, 0)

                    local keyBtn = Instance.new("TextButton")
                    keyBtn.Name = "KeybindBtn"
                    keyBtn.Text = Library._FormatKeybind(boundKey, modifiers)
                    keyBtn.Font = Enum.Font.GothamBold
                    keyBtn.TextSize = 11
                    keyBtn.TextColor3 = Library.Theme.Text
                    keyBtn.BackgroundColor3 = Library.Theme.ButtonBg
                    keyBtn.BorderSizePixel = 0
                    keyBtn.Size = UDim2.new(0, 90, 0, 22)
                    keyBtn.Position = UDim2.new(1, -94, 0.5, -11)
                    keyBtn.ZIndex = 8
                    Library.Utils.MakeCorner(keyBtn, 6)
                    Library.Utils.MakeStroke(keyBtn, Library.Theme.Border, 1, 0.3)
                    keyBtn.Parent = row

                    keyBtn.MouseButton1Click:Connect(function()
                        listening = true
                        keyBtn.Text = "..."
                        keyBtn.TextColor3 = Library.Theme.Accent
                    end)

                    UserInputService.InputBegan:Connect(function(inp, gameProcessed)
                        if not listening then
                            -- Check if bound key was pressed
                            if inp.KeyCode == boundKey then kcb(boundKey) end
                            return
                        end
                        if inp.UserInputType == Enum.UserInputType.Keyboard then
                            local mod = inp.KeyCode
                            if mod == Enum.KeyCode.LeftShift or mod == Enum.KeyCode.RightShift or
                               mod == Enum.KeyCode.LeftControl or mod == Enum.KeyCode.RightControl or
                               mod == Enum.KeyCode.LeftAlt or mod == Enum.KeyCode.RightAlt then
                                table.insert(modifiers, mod)
                            else
                                boundKey = mod
                                listening = false
                                keyBtn.Text = Library._FormatKeybind(boundKey, modifiers)
                                keyBtn.TextColor3 = Library.Theme.Text
                                modifiers = {}
                                kcb(boundKey)
                                if Library.Config.AutoSaveEnabled then Library.Config:_Debounce() end
                            end
                        end
                    end)

                    if tooltip ~= "" then Library._BindTooltip(keyBtn, tooltip) end

                    local id = Library.Utils.Unique("Keybind")
                    local el = {
                        _id = id, _type = "Keybind", _name = kname,
                        Set = function(self, k)
                            boundKey = k
                            keyBtn.Text = Library._FormatKeybind(k, {})
                        end,
                        Get = function(self) return boundKey end,
                        Update = function(self, o) end,
                        Destroy = function(self) row:Destroy() end,
                        FireCallback = function(self) kcb(boundKey) end,
                    }
                    Library.Elements[id] = el
                    fullHeight = fullHeight + 32
                    return el
                end

                -- ---- GRAPH ----
                function Section:CreateGraph(gOpts)
                    gOpts = gOpts or {}
                    local gname = gOpts.Name or "This is a graph"
                    local gcb   = gOpts.Callback or function() end
                    local gstatus = gOpts.Status or ""
                    local gstatusColor = gOpts.StatusColor or Library.Theme.StatusGreen

                    local container = Library._BuildGraph(elemContainer, {
                        Name = gname,
                        Width = 250,
                        Height = 90,
                        Status = gstatus,
                        StatusColor = gstatusColor,
                        Points = gOpts.Points,
                        Callback = gcb,
                    })
                    container.LayoutOrder = #elemContainer:GetChildren()

                    local id = Library.Utils.Unique("Graph")
                    local el = {
                        _id = id, _type = "Graph", _name = gname,
                        Set = function() end,
                        Get = function() end,
                        Update = function() end,
                        Destroy = function(self) container:Destroy() end,
                        FireCallback = function() end,
                    }
                    Library.Elements[id] = el
                    fullHeight = fullHeight + 114
                    return el
                end

                -- ---- STATUS ROW ----
                function Section:CreateStatusRow(srOpts)
                    srOpts = srOpts or {}
                    local srlabel  = srOpts.Label or "Status"
                    local srvalue  = srOpts.Value or ""
                    local srcolor  = srOpts.ValueColor or Library.Theme.StatusGreen

                    local row = makeRow("StatusRow_"..srlabel, 26)
                    local lbl = rowLabel(row, srlabel)

                    local valLbl = Library.Utils.NewLabel(row, srvalue, 12, srcolor, Enum.Font.GothamBold, 7)
                    valLbl.Size = UDim2.new(0.5, 0, 1, 0)
                    valLbl.Position = UDim2.new(0.5, 0, 0, 0)
                    valLbl.TextXAlignment = Enum.TextXAlignment.Right

                    local id = Library.Utils.Unique("StatusRow")
                    local el = {
                        _id = id, _type = "StatusRow",
                        Set = function(self, v) valLbl.Text = v end,
                        Get = function(self) return valLbl.Text end,
                        SetColor = function(self, c) valLbl.TextColor3 = c end,
                        Update = function(self, o)
                            if o.Value then valLbl.Text = o.Value end
                            if o.ValueColor then valLbl.TextColor3 = o.ValueColor end
                        end,
                        Destroy = function(self) row:Destroy() end,
                        FireCallback = function() end,
                    }
                    Library.Elements[id] = el
                    fullHeight = fullHeight + 28
                    return el
                end

                -- ---- MODE SELECTOR (Toggle/Hold/Always) ----
                function Section:CreateModeSelector(msOpts)
                    msOpts = msOpts or {}
                    local modes   = msOpts.Modes or {"Toggle", "Hold", "Always"}
                    local msdefault = msOpts.Default or modes[1]
                    local mscb    = msOpts.Callback or function() end
                    local active  = msdefault

                    local row = makeRow("ModeSelectorRow", 36)
                    row.BackgroundTransparency = 1

                    local btnFrameLayout = Instance.new("UIListLayout")
                    btnFrameLayout.FillDirection = Enum.FillDirection.Horizontal
                    btnFrameLayout.Padding = UDim.new(0, 4)
                    btnFrameLayout.Parent = row

                    local btns = {}

                    local function updateActive()
                        for _, b in ipairs(btns) do
                            local isActive = b._mode == active
                            Library.Utils.QuickTween(b._btn, 0.15, {
                                BackgroundColor3 = isActive and Library.Theme.Accent or Library.Theme.ButtonBg,
                                TextColor3 = isActive and Color3.new(1,1,1) or Library.Theme.TextSecondary,
                            })
                        end
                    end

                    for _, mode in ipairs(modes) do
                        local mBtn = Instance.new("TextButton")
                        mBtn.Text = mode
                        mBtn.Font = Enum.Font.GothamBold
                        mBtn.TextSize = 11
                        mBtn.TextColor3 = mode == active and Color3.new(1,1,1) or Library.Theme.TextSecondary
                        mBtn.BackgroundColor3 = mode == active and Library.Theme.Accent or Library.Theme.ButtonBg
                        mBtn.BorderSizePixel = 0
                        mBtn.Size = UDim2.new(0, 60, 0, 28)
                        mBtn.ZIndex = 7
                        Library.Utils.MakeCorner(mBtn, 7)
                        Library.Utils.MakeStroke(mBtn, Library.Theme.Border, 1, 0.3)
                        mBtn.Parent = row
                        local entry = {_mode = mode, _btn = mBtn}
                        table.insert(btns, entry)

                        mBtn.MouseButton1Click:Connect(function()
                            active = mode
                            updateActive()
                            mscb(mode)
                        end)
                    end

                    local id = Library.Utils.Unique("ModeSelector")
                    local el = {
                        _id = id, _type = "ModeSelector",
                        Set = function(self, v) active = v updateActive() end,
                        Get = function(self) return active end,
                        Update = function() end,
                        Destroy = function(self) row:Destroy() end,
                        FireCallback = function(self) mscb(active) end,
                    }
                    Library.Elements[id] = el
                    fullHeight = fullHeight + 38
                    return el
                end

                return Section
            end -- CreateSection

            return Column
        end -- CreateColumn

        -- Convenience: shorthand for single-column tabs
        function Tab:CreateSection(secOpts)
            if #Tab._Columns == 0 then
                Tab:CreateColumn({Width = 1})
            end
            return Tab._Columns[1]:CreateSection(secOpts)
        end

        -- Activate tab
        tabBtn.MouseButton1Click:Connect(function()
            Window:_SetActiveTab(Tab)
        end)

        -- Hover
        tabBtn.MouseEnter:Connect(function()
            if Window._ActiveTab ~= Tab then
                Library.Utils.QuickTween(tabBtn, 0.1, {TextColor3 = Library.Theme.Text})
            end
        end)
        tabBtn.MouseLeave:Connect(function()
            if Window._ActiveTab ~= Tab then
                Library.Utils.QuickTween(tabBtn, 0.1, {TextColor3 = Library.Theme.TextDim})
            end
        end)

        table.insert(Window._Tabs, Tab)
        table.insert(Window._TabButtons, tabBtn)

        -- Auto-activate first tab
        if #Window._Tabs == 1 then
            Window:_SetActiveTab(Tab)
        end

        return Tab
    end -- CreateTab

    function Window:_SetActiveTab(tab)
        -- Hide all
        for _, t in ipairs(Window._Tabs) do
            t._Frame.Visible = false
        end
        for _, b in ipairs(Window._TabButtons) do
            Library.Utils.QuickTween(b, 0.15, {TextColor3 = Library.Theme.TextDim})
        end

        tab._Frame.Visible = true
        Library.Utils.QuickTween(tab._Button, 0.15, {TextColor3 = Library.Theme.Text})

        -- Slide active bar to button position
        local btnPos = tab._Button.Position
        Library.Utils.QuickTween(Window._ActiveBar, 0.2, {
            Position = UDim2.new(0, 0, 0, tab._Button.Position.Y.Offset + 6)
        })

        Window._ActiveTab = tab
    end

    function Window:Destroy()
        if Library.Config.AutoSaveEnabled then Library.Config:Save("__autosave__") end
        win:Destroy()
        shadowFrame:Destroy()
    end

    table.insert(Library._Windows, Window)
    return Window
end -- CreateWindow

-- ============================================================
-- KEYBIND FORMAT HELPER
-- ============================================================
function Library._FormatKeybind(key, mods)
    local parts = {}
    if mods then
        for _, m in ipairs(mods) do
            if m == Enum.KeyCode.LeftShift or m == Enum.KeyCode.RightShift then
                table.insert(parts, "Shift")
            elseif m == Enum.KeyCode.LeftControl or m == Enum.KeyCode.RightControl then
                table.insert(parts, "Ctrl")
            elseif m == Enum.KeyCode.LeftAlt or m == Enum.KeyCode.RightAlt then
                table.insert(parts, "Alt")
            end
        end
    end
    if key and key ~= Enum.KeyCode.Unknown then
        local keyName = tostring(key):gsub("Enum%.KeyCode%.", "")
        table.insert(parts, keyName)
    else
        return "None"
    end
    return table.concat(parts, " + ")
end

-- ============================================================
-- ADDON SYSTEM
-- ============================================================
function Library:LoadAddon(name)
    local path = "addons/" .. name .. ".lua"
    local ok, err = pcall(function()
        local content = readfile(path)
        if not content then error("File not found: " .. path) end
        local fn, loadErr = loadstring(content)
        if not fn then error("Load error: " .. tostring(loadErr)) end
        fn()
    end)
    if not ok then
        warn("[RobloxUILibrary] Failed to load addon '" .. name .. "': " .. tostring(err))
    end
end

-- ============================================================
-- LIVE THEME SYSTEM
-- ============================================================
function Library:SetTheme(newTheme)
    -- Merge into Library.Theme
    for k, v in pairs(newTheme) do
        Library.Theme[k] = v
    end
    -- Recolor all tracked elements
    if Library.GUI then
        -- Walk all UI instances and recolor by Name conventions
        local function recolor(inst)
            local name = inst.Name
            if inst:IsA("Frame") or inst:IsA("ScrollingFrame") then
                if name == "MainWindowFrame" then
                    inst.BackgroundColor3 = Library.Theme.Background
                elseif name:find("Panel") or name:find("Section") or name == "ContentArea"
                    or name == "TabContent_" or name:find("TabContent") then
                    inst.BackgroundColor3 = Library.Theme.Panel
                elseif name == "SidebarTabContainer" or name == "TopBar" then
                    inst.BackgroundColor3 = Library.Theme.TopbarBg
                elseif name == "SliderFill" then
                    inst.BackgroundColor3 = Library.Theme.SliderFill
                elseif name == "SliderTrack" then
                    inst.BackgroundColor3 = Library.Theme.SliderTrack
                elseif name == "ActiveTabBar" then
                    inst.BackgroundColor3 = Library.Theme.Accent
                end
            elseif inst:IsA("UIStroke") then
                inst.Color = Library.Theme.Border
            elseif inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("TextBox") then
                if inst.TextColor3 == Color3.fromRGB(255,255,255) then
                    inst.TextColor3 = Library.Theme.Text
                elseif inst.TextColor3 == Color3.fromRGB(200,200,200) then
                    inst.TextColor3 = Library.Theme.TextSecondary
                end
            end
            for _, child in ipairs(inst:GetChildren()) do
                recolor(child)
            end
        end
        recolor(Library.GUI)
    end
end

function Library:SetGradient(gradOpts)
    gradOpts = gradOpts or {}
    if not Library.GUI then return end
    -- Apply to all panel frames
    local function applyGrad(inst)
        if inst:IsA("Frame") and (inst.Name == "MainWindowFrame" or inst.Name:find("TabContent")) then
            local existing = inst:FindFirstChildOfClass("UIGradient")
            if existing then existing:Destroy() end
            local ug = Instance.new("UIGradient")
            ug.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, gradOpts.Color1 or Color3.new(1,1,1)),
                ColorSequenceKeypoint.new(1, gradOpts.Color2 or Color3.new(0,0,0)),
            })
            ug.Rotation = gradOpts.Rotation or 90
            ug.Parent = inst
        end
        for _, child in ipairs(inst:GetChildren()) do applyGrad(child) end
    end
    applyGrad(Library.GUI)
end

-- ============================================================
-- INIT
-- ============================================================
Library._InitGUI()
Library._InitTooltip()

return Library
