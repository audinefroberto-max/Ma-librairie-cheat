-- ================================================================
-- SoroniceLib_Buttons.lua
-- Module séparé : tous les types d'éléments (Button, Toggle, etc.)
-- Utilisé par la librairie principale via loadstring(game:HttpGet(URL))()
-- Pour ajouter un nouveau type : créez une fonction Reg["NomDuType"]
-- ================================================================

return function(Ctx)
    local Settings      = Ctx.Settings
    local TweenService  = Ctx.TweenService
    local UserInputService = Ctx.UserInputService
    local ApplyLock     = Ctx.ApplyLock
    local ActiveToggles = Ctx.ActiveToggles

    local Reg = {}

    -- ============================================================
    -- BUTTON
    -- ============================================================
    function Reg.Button(Page, Config)
        local ReturnedTable = {}
        local BtnFrame = Instance.new("Frame")
        BtnFrame.Parent = Page
        BtnFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
        BtnFrame.Size = UDim2.new(1,-10,0,35)
        Instance.new("UICorner", BtnFrame).CornerRadius = UDim.new(0,6)
        BtnFrame:SetAttribute("SearchName", string.lower(Config.Name or ""))

        local Btn = Instance.new("TextButton")
        Btn.Parent = BtnFrame
        Btn.BackgroundTransparency = 1
        Btn.Size = UDim2.new(1,0,1,0)
        Btn.Font = Enum.Font.SourceSans
        Btn.Text = "  " .. (Config.Name or "")
        Btn.TextColor3 = Settings.TextColor
        Btn.TextSize = 16
        Btn.TextXAlignment = Enum.TextXAlignment.Left

        local Locked = ApplyLock(BtnFrame, Config)
        if not Locked then
            Btn.MouseButton1Click:Connect(function()
                TweenService:Create(BtnFrame, TweenInfo.new(0.1), {BackgroundColor3=Color3.fromRGB(50,50,50)}):Play()
                task.wait(0.1)
                TweenService:Create(BtnFrame, TweenInfo.new(0.1), {BackgroundColor3=Color3.fromRGB(30,30,30)}):Play()
                if Config.Callback then Config.Callback() end
            end)
        else
            Btn.Active = false
        end

        function ReturnedTable:Set(NewName)
            Btn.Text = "  " .. NewName
        end
        return ReturnedTable
    end

    -- ============================================================
    -- TOGGLE — 3 styles configurables via Config.ToggleStyle = 1/2/3
    --   Style 1 : classique (défaut)
    --   Style 2 : esthétique — plus large, icône dans le bouton, glow
    --   Style 3 : Rainbow — contour multicolore tournant
    -- ============================================================
    function Reg.Toggle(Page, Config)
        local ReturnedTable = {}
        local Style = Config.ToggleStyle or 1

        local ToggleFrame = Instance.new("Frame")
        ToggleFrame.Parent = Page
        ToggleFrame.BackgroundTransparency = 1
        ToggleFrame.Size = UDim2.new(1,-10,0,35)
        ToggleFrame:SetAttribute("SearchName", string.lower(Config.Name or ""))

        local Label = Instance.new("TextLabel")
        Label.Parent = ToggleFrame
        Label.BackgroundTransparency = 1
        Label.Size = UDim2.new(0.7,0,1,0)
        Label.Position = UDim2.new(0,10,0,0)
        Label.Text = Config.Name or ""
        Label.TextColor3 = Settings.TextColor
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.TextSize = 16
        Label.Font = Enum.Font.SourceSans

        local Locked   = ApplyLock(ToggleFrame, Config)
        local Toggled  = Config.CurrentValue or false

        -- ─── Style 1 : Classique ───────────────────────────────
        if Style == 1 then
            local SwitchBg = Instance.new("Frame")
            SwitchBg.Parent = ToggleFrame
            SwitchBg.BackgroundColor3 = Color3.fromRGB(40,40,40)
            SwitchBg.Position = UDim2.new(1,-60,0.5,-12)
            SwitchBg.Size = UDim2.new(0,50,0,24)
            Instance.new("UICorner", SwitchBg).CornerRadius = UDim.new(1,0)

            local Knob = Instance.new("Frame")
            Knob.Parent = SwitchBg
            Knob.BackgroundColor3 = Settings.TextColor
            Knob.Position = UDim2.new(0,2,0.5,-10)
            Knob.Size = UDim2.new(0,20,0,20)
            Instance.new("UICorner", Knob).CornerRadius = UDim.new(1,0)

            table.insert(ActiveToggles, {Callback = Config.Callback})

            local function Update()
                local TargetPos = Toggled and UDim2.new(1,-22,0.5,-10) or UDim2.new(0,2,0.5,-10)
                local TargetCol = Toggled and Settings.AccentColor or Color3.fromRGB(40,40,40)
                TweenService:Create(Knob, TweenInfo.new(0.2), {Position=TargetPos}):Play()
                TweenService:Create(SwitchBg, TweenInfo.new(0.2), {BackgroundColor3=TargetCol}):Play()
                if Config.Callback then Config.Callback(Toggled) end
            end
            if Toggled then Update() end

            local ClickBtn = Instance.new("TextButton")
            ClickBtn.Parent = SwitchBg
            ClickBtn.BackgroundTransparency = 1
            ClickBtn.Size = UDim2.new(1,0,1,0)
            ClickBtn.Text = ""
            if not Locked then
                ClickBtn.MouseButton1Click:Connect(function() Toggled = not Toggled; Update() end)
            else
                ClickBtn.Active = false
            end

            function ReturnedTable:Set(Value)
                Toggled = Value; Update()
            end

        -- ─── Style 2 : Esthétique ─────────────────────────────
        elseif Style == 2 then
            local SwitchBg = Instance.new("Frame")
            SwitchBg.Parent = ToggleFrame
            SwitchBg.BackgroundColor3 = Color3.fromRGB(35,35,35)
            SwitchBg.Position = UDim2.new(1,-74,0.5,-14)
            SwitchBg.Size = UDim2.new(0,64,0,28)
            Instance.new("UICorner", SwitchBg).CornerRadius = UDim.new(1,0)

            -- Gradient de fond
            local BgGrad = Instance.new("UIGradient")
            BgGrad.Parent = SwitchBg
            BgGrad.Rotation = 0
            BgGrad.Color = ColorSequence.new(Color3.fromRGB(35,35,35), Color3.fromRGB(25,25,25))

            local Knob = Instance.new("Frame")
            Knob.Parent = SwitchBg
            Knob.BackgroundColor3 = Color3.fromRGB(230,230,230)
            Knob.AnchorPoint = Vector2.new(0,0.5)
            Knob.Position = UDim2.new(0,3,0.5,0)
            Knob.Size = UDim2.new(0,22,0,22)
            Instance.new("UICorner", Knob).CornerRadius = UDim.new(1,0)

            -- Ombre sur le bouton
            local KnobStroke = Instance.new("UIStroke")
            KnobStroke.Parent = Knob
            KnobStroke.Color = Color3.fromRGB(0,0,0)
            KnobStroke.Thickness = 1
            KnobStroke.Transparency = 0.5

            -- Icône dans le bouton (cercle coloré ou X)
            local KnobIcon = Instance.new("ImageLabel")
            KnobIcon.Parent = Knob
            KnobIcon.BackgroundTransparency = 1
            KnobIcon.AnchorPoint = Vector2.new(0.5,0.5)
            KnobIcon.Position = UDim2.new(0.5,0,0.5,0)
            KnobIcon.Size = UDim2.new(0,10,0,10)
            KnobIcon.Image = "rbxassetid://7072725344" -- icône X
            KnobIcon.ImageColor3 = Color3.fromRGB(120,120,120)

            table.insert(ActiveToggles, {Callback = Config.Callback})

            local function Update()
                if Toggled then
                    TweenService:Create(Knob, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {Position=UDim2.new(1,-25,0.5,0)}):Play()
                    TweenService:Create(SwitchBg, TweenInfo.new(0.25), {BackgroundColor3=Settings.AccentColor}):Play()
                    BgGrad.Color = ColorSequence.new(Settings.AccentColor, Color3.new(
                        math.clamp(Settings.AccentColor.R * 0.7, 0, 1),
                        math.clamp(Settings.AccentColor.G * 0.7, 0, 1),
                        math.clamp(Settings.AccentColor.B * 0.7, 0, 1)
                    ))
                    KnobIcon.Image = "rbxassetid://6031094678" -- ✓
                    KnobIcon.ImageColor3 = Settings.AccentColor
                else
                    TweenService:Create(Knob, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {Position=UDim2.new(0,3,0.5,0)}):Play()
                    TweenService:Create(SwitchBg, TweenInfo.new(0.25), {BackgroundColor3=Color3.fromRGB(35,35,35)}):Play()
                    BgGrad.Color = ColorSequence.new(Color3.fromRGB(35,35,35), Color3.fromRGB(25,25,25))
                    KnobIcon.Image = "rbxassetid://7072725344" -- ✗
                    KnobIcon.ImageColor3 = Color3.fromRGB(120,120,120)
                end
                if Config.Callback then Config.Callback(Toggled) end
            end
            if Toggled then Update() end

            local ClickBtn = Instance.new("TextButton")
            ClickBtn.Parent = SwitchBg
            ClickBtn.BackgroundTransparency = 1
            ClickBtn.Size = UDim2.new(1,0,1,0)
            ClickBtn.Text = ""
            if not Locked then
                ClickBtn.MouseButton1Click:Connect(function() Toggled = not Toggled; Update() end)
            else
                ClickBtn.Active = false
            end

            function ReturnedTable:Set(Value)
                Toggled = Value; Update()
            end

        -- ─── Style 3 : Rainbow (contour multicolore tournant) ──
        elseif Style == 3 then
            local SwitchBg = Instance.new("Frame")
            SwitchBg.Parent = ToggleFrame
            SwitchBg.BackgroundColor3 = Color3.fromRGB(28,28,28)
            SwitchBg.Position = UDim2.new(1,-74,0.5,-14)
            SwitchBg.Size = UDim2.new(0,64,0,28)
            Instance.new("UICorner", SwitchBg).CornerRadius = UDim.new(1,0)

            -- Contour Rainbow tournant
            local RainbowStroke = Instance.new("UIStroke")
            RainbowStroke.Parent = SwitchBg
            RainbowStroke.Thickness = 2
            RainbowStroke.Color = Color3.fromRGB(80,80,80)
            RainbowStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

            local Knob = Instance.new("Frame")
            Knob.Parent = SwitchBg
            Knob.BackgroundColor3 = Color3.fromRGB(220,220,220)
            Knob.AnchorPoint = Vector2.new(0,0.5)
            Knob.Position = UDim2.new(0,3,0.5,0)
            Knob.Size = UDim2.new(0,22,0,22)
            Instance.new("UICorner", Knob).CornerRadius = UDim.new(1,0)

            -- Animation rainbow permanente
            local rainbowToken = 0
            local function StartRainbow()
                rainbowToken = rainbowToken + 1
                local myToken = rainbowToken
                task.spawn(function()
                    local hue = 0
                    while rainbowToken == myToken do
                        hue = (hue + 0.006) % 1
                        RainbowStroke.Color = Color3.fromHSV(hue, 1, 1)
                        task.wait(0.025)
                    end
                end)
            end
            StartRainbow()

            table.insert(ActiveToggles, {Callback = Config.Callback})

            local function Update()
                if Toggled then
                    TweenService:Create(Knob, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {Position=UDim2.new(1,-25,0.5,0), BackgroundColor3=Color3.fromRGB(255,255,255)}):Play()
                    TweenService:Create(SwitchBg, TweenInfo.new(0.25), {BackgroundColor3=Color3.fromRGB(40,40,40)}):Play()
                else
                    TweenService:Create(Knob, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {Position=UDim2.new(0,3,0.5,0), BackgroundColor3=Color3.fromRGB(160,160,160)}):Play()
                    TweenService:Create(SwitchBg, TweenInfo.new(0.25), {BackgroundColor3=Color3.fromRGB(28,28,28)}):Play()
                end
                if Config.Callback then Config.Callback(Toggled) end
            end
            if Toggled then Update() end

            local ClickBtn = Instance.new("TextButton")
            ClickBtn.Parent = SwitchBg
            ClickBtn.BackgroundTransparency = 1
            ClickBtn.Size = UDim2.new(1,0,1,0)
            ClickBtn.Text = ""
            if not Locked then
                ClickBtn.MouseButton1Click:Connect(function() Toggled = not Toggled; Update() end)
            else
                ClickBtn.Active = false
            end

            function ReturnedTable:Set(Value)
                Toggled = Value; Update()
            end
        end

        return ReturnedTable
    end

    -- ============================================================
    -- KEYBIND
    -- ============================================================
    function Reg.Keybind(Page, Config)
        local ReturnedTable = {}
        local BindFrame = Instance.new("Frame")
        BindFrame.Parent = Page
        BindFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
        BindFrame.Size = UDim2.new(1,-10,0,35)
        Instance.new("UICorner", BindFrame).CornerRadius = UDim.new(0,6)
        BindFrame:SetAttribute("SearchName", string.lower(Config.Name or ""))

        local Label = Instance.new("TextLabel")
        Label.Parent = BindFrame
        Label.BackgroundTransparency = 1
        Label.Size = UDim2.new(0.7,0,1,0)
        Label.Position = UDim2.new(0,10,0,0)
        Label.Text = Config.Name or ""
        Label.TextColor3 = Settings.TextColor
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.TextSize = 16
        Label.Font = Enum.Font.SourceSans

        local BindBtn = Instance.new("TextButton")
        BindBtn.Parent = BindFrame
        BindBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
        BindBtn.Position = UDim2.new(1,-80,0.5,-12)
        BindBtn.Size = UDim2.new(0,70,0,24)
        BindBtn.Text = UserInputService:GetStringForKeyCode(Settings.Keybind)
        BindBtn.Font = Enum.Font.SourceSansBold
        BindBtn.TextColor3 = Settings.TextColor
        BindBtn.TextSize = 14
        Instance.new("UICorner", BindBtn).CornerRadius = UDim.new(0,6)

        BindBtn.MouseButton1Click:Connect(function()
            BindBtn.Text = "..."
            local Conn
            Conn = UserInputService.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    Settings.Keybind = input.KeyCode
                    BindBtn.Text = UserInputService:GetStringForKeyCode(input.KeyCode)
                    Conn:Disconnect()
                    game.StarterGui:SetCore("SendNotification", {Title = "Réglages", Text = "Nouvelle touche : " .. BindBtn.Text, Duration = 3})
                end
            end)
        end)

        function ReturnedTable:Set(KeyName)
            BindBtn.Text = KeyName
        end
        return ReturnedTable
    end

    -- ============================================================
    -- LABEL
    -- ============================================================
    function Reg.Label(Page, Config)
        local ReturnedTable = {}
        local LabelFrame = Instance.new("Frame")
        LabelFrame.Parent = Page
        LabelFrame.BackgroundTransparency = 1
        LabelFrame.Size = UDim2.new(1,-10,0,25)
        LabelFrame:SetAttribute("SearchName", string.lower(Config.Text or ""))

        local Txt = Instance.new("TextLabel")
        Txt.Parent = LabelFrame
        Txt.BackgroundTransparency = 1
        Txt.Size = UDim2.new(1,0,1,0)
        Txt.Position = UDim2.new(0,10,0,0)
        Txt.Text = Config.Text or ""
        Txt.TextColor3 = Settings.SubTextColor
        Txt.TextXAlignment = Enum.TextXAlignment.Left
        Txt.Font = Enum.Font.SourceSans
        Txt.TextSize = 16

        function ReturnedTable:Set(NewText)
            Txt.Text = NewText
        end
        return ReturnedTable
    end

    -- ============================================================
    -- PARAGRAPH
    -- ============================================================
    function Reg.Paragraph(Page, Config)
        local ReturnedTable = {}
        local ParaFrame = Instance.new("Frame")
        ParaFrame.Parent = Page
        ParaFrame.BackgroundTransparency = 1
        ParaFrame.Size = UDim2.new(1,-10,0,60)
        ParaFrame:SetAttribute("SearchName", string.lower(Config.Title or ""))

        local Title = Instance.new("TextLabel")
        Title.Parent = ParaFrame
        Title.BackgroundTransparency = 1
        Title.Size = UDim2.new(1,0,0,20)
        Title.Position = UDim2.new(0,10,0,0)
        Title.Text = Config.Title or ""
        Title.TextColor3 = Settings.AccentColor
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.Font = Enum.Font.SourceSansBold
        Title.TextSize = 16

        local Content = Instance.new("TextLabel")
        Content.Parent = ParaFrame
        Content.BackgroundTransparency = 1
        Content.Size = UDim2.new(1,-20,0,40)
        Content.Position = UDim2.new(0,10,0,20)
        Content.Text = Config.Content or ""
        Content.TextColor3 = Color3.new(0.8,0.8,0.8)
        Content.TextXAlignment = Enum.TextXAlignment.Left
        Content.Font = Enum.Font.SourceSans
        Content.TextSize = 14
        Content.TextWrapped = true

        function ReturnedTable:Set(NewConfig)
            if NewConfig.Title then Title.Text = NewConfig.Title end
            if NewConfig.Content then Content.Text = NewConfig.Content end
        end
        return ReturnedTable
    end

    -- ============================================================
    -- INPUT (TextBox)
    -- ============================================================
    function Reg.Input(Page, Config)
        local ReturnedTable = {}
        local InputFrame = Instance.new("Frame")
        InputFrame.Parent = Page
        InputFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
        InputFrame.Size = UDim2.new(1,-10,0,35)
        Instance.new("UICorner", InputFrame).CornerRadius = UDim.new(0,6)
        InputFrame:SetAttribute("SearchName", string.lower(Config.Name or ""))

        local Label = Instance.new("TextLabel")
        Label.Parent = InputFrame
        Label.BackgroundTransparency = 1
        Label.Position = UDim2.new(0,10,0,0)
        Label.Size = UDim2.new(0.5,0,1,0)
        Label.Text = Config.Name or ""
        Label.TextColor3 = Settings.TextColor
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Font = Enum.Font.SourceSans
        Label.TextSize = 16

        local Box = Instance.new("TextBox")
        Box.Parent = InputFrame
        Box.BackgroundColor3 = Color3.fromRGB(40,40,40)
        Box.Position = UDim2.new(0.6,0,0.15,0)
        Box.Size = UDim2.new(0.38,0,0.7,0)
        Box.Font = Enum.Font.SourceSans
        Box.Text = Config.CurrentValue or ""
        Box.PlaceholderText = Config.PlaceholderText or ""
        Box.TextColor3 = Color3.new(1,1,1)
        Box.TextSize = 14
        Instance.new("UICorner", Box).CornerRadius = UDim.new(0,4)

        Box.FocusLost:Connect(function()
            if Config.RemoveTextAfterFocusLost then Box.Text = "" end
            if Config.Callback then Config.Callback(Box.Text) end
        end)

        function ReturnedTable:Set(NewText)
            Box.Text = NewText
        end
        return ReturnedTable
    end

    -- ============================================================
    -- SECTION (titre de groupe)
    -- ============================================================
    function Reg.Section(Page, Config)
        local ReturnedTable = {}
        local SectionFrame = Instance.new("Frame")
        SectionFrame.Parent = Page
        SectionFrame.BackgroundTransparency = 1
        SectionFrame.Size = UDim2.new(1,-10,0,30)
        SectionFrame:SetAttribute("SearchName", string.lower(Config.Text or ""))

        local Txt = Instance.new("TextLabel")
        Txt.Parent = SectionFrame
        Txt.BackgroundTransparency = 1
        Txt.Size = UDim2.new(1,0,1,0)
        Txt.Position = UDim2.new(0,10,0,0)
        Txt.Text = Config.Text or ""
        Txt.TextColor3 = Settings.AccentColor
        Txt.TextXAlignment = Enum.TextXAlignment.Left
        Txt.Font = Enum.Font.SourceSansBold
        Txt.TextSize = 18

        function ReturnedTable:Set(NewText)
            Txt.Text = NewText
        end
        return ReturnedTable
    end

    -- ============================================================
    -- DIVIDER (ligne de séparation)
    -- ============================================================
    function Reg.Divider(Page, Config)
        local ReturnedTable = {}
        local DivFrame = Instance.new("Frame")
        DivFrame.Parent = Page
        DivFrame.BackgroundTransparency = 1
        DivFrame.Size = UDim2.new(1,-10,0,10)

        local Line = Instance.new("Frame")
        Line.Parent = DivFrame
        Line.BackgroundColor3 = Color3.fromRGB(60,60,60)
        Line.Size = UDim2.new(1,0,0,2)
        Line.Position = UDim2.new(0,0,0.5,0)
        Line.BorderSizePixel = 0

        function ReturnedTable:Set(Visible)
            DivFrame.Visible = Visible
        end
        return ReturnedTable
    end

    -- ============================================================
    -- COLOR PICKER
    -- ============================================================
    function Reg.ColorPicker(Page, Config)
        local ReturnedTable = {}
        local ColorFrame = Instance.new("Frame")
        ColorFrame.Parent = Page
        ColorFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
        ColorFrame.Size = UDim2.new(1,-10,0,160)
        Instance.new("UICorner", ColorFrame).CornerRadius = UDim.new(0,6)
        ColorFrame:SetAttribute("SearchName", string.lower(Config.Name or ""))

        local Locked = ApplyLock(ColorFrame, Config)

        local Label = Instance.new("TextLabel")
        Label.Parent = ColorFrame
        Label.BackgroundTransparency = 1
        Label.Position = UDim2.new(0,10,0,5)
        Label.Size = UDim2.new(1,0,0,20)
        Label.Text = Config.Name or ""
        Label.TextColor3 = Settings.TextColor
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Font = Enum.Font.SourceSansBold
        Label.TextSize = 16

        local Preview = Instance.new("Frame")
        Preview.Parent = ColorFrame
        Preview.Position = UDim2.new(0,10,0,30)
        Preview.Size = UDim2.new(0,30,0,30)
        Preview.BackgroundColor3 = Config.Color or Color3.new(1,1,1)
        Instance.new("UICorner", Preview).CornerRadius = UDim.new(0,4)

        local SVBox = Instance.new("TextButton")
        SVBox.Parent = ColorFrame
        SVBox.Position = UDim2.new(0,60,0,30)
        SVBox.Size = UDim2.new(0,150,0,100)
        SVBox.BackgroundColor3 = Color3.new(1,0,0)
        SVBox.Text = ""
        local SVGrad = Instance.new("UIGradient")
        SVGrad.Parent = SVBox
        SVGrad.Color = ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.new(1,1,1)), ColorSequenceKeypoint.new(1,Color3.new(1,0,0))}
        local SVBlack = Instance.new("ImageLabel")
        SVBlack.Parent = SVBox
        SVBlack.Size = UDim2.new(1,0,1,0)
        SVBlack.Image = "rbxassetid://156579757"
        SVBlack.BackgroundTransparency = 1

        local HueBar = Instance.new("TextButton")
        HueBar.Parent = ColorFrame
        HueBar.Position = UDim2.new(0,60,0,135)
        HueBar.Size = UDim2.new(0,150,0,15)
        HueBar.Text = ""
        local HueGrad = Instance.new("UIGradient")
        HueGrad.Parent = HueBar
        HueGrad.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0,     Color3.new(1,0,0)),
            ColorSequenceKeypoint.new(0.167, Color3.new(1,1,0)),
            ColorSequenceKeypoint.new(0.333, Color3.new(0,1,0)),
            ColorSequenceKeypoint.new(0.5,   Color3.new(0,1,1)),
            ColorSequenceKeypoint.new(0.667, Color3.new(0,0,1)),
            ColorSequenceKeypoint.new(0.833, Color3.new(1,0,1)),
            ColorSequenceKeypoint.new(1,     Color3.new(1,0,0))
        }

        local function MakeRGBBox(Placeholder, XOffset)
            local Box = Instance.new("TextBox")
            Box.Parent = ColorFrame
            Box.BackgroundColor3 = Color3.fromRGB(40,40,40)
            Box.Position = UDim2.new(0,220,0,XOffset)
            Box.Size = UDim2.new(0,40,0,25)
            Box.Font = Enum.Font.SourceSans
            Box.PlaceholderText = Placeholder
            Box.Text = ""
            Box.TextColor3 = Color3.new(1,1,1)
            Box.TextSize = 14
            Instance.new("UICorner", Box).CornerRadius = UDim.new(0,4)
            return Box
        end
        local RBox = MakeRGBBox("R", 30)
        local GBox = MakeRGBBox("G", 60)
        local BBox = MakeRGBBox("B", 90)

        local HexBox = Instance.new("TextBox")
        HexBox.Parent = ColorFrame
        HexBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
        HexBox.Position = UDim2.new(0,220,0,120)
        HexBox.Size = UDim2.new(0,60,0,25)
        HexBox.Font = Enum.Font.SourceSans
        HexBox.PlaceholderText = "#Hex"
        HexBox.Text = ""
        HexBox.TextColor3 = Settings.TextColor
        HexBox.TextSize = 14
        Instance.new("UICorner", HexBox).CornerRadius = UDim.new(0,4)

        local H, S, V = 0, 1, 1
        local function UpdateColor(NewH, NewS, NewV)
            H = NewH or H; S = NewS or S; V = NewV or V
            local Col = Color3.fromHSV(H,S,V)
            Preview.BackgroundColor3 = Col
            SVBox.BackgroundColor3 = Color3.fromHSV(H,1,1)
            RBox.Text = math.floor(Col.R*255)
            GBox.Text = math.floor(Col.G*255)
            BBox.Text = math.floor(Col.B*255)
            if Config.Callback then Config.Callback(Col) end
        end

        if not Locked then
            local dHue, dSV = false, false
            UserInputService.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                    if dHue then
                        UpdateColor(math.clamp((input.Position.X - HueBar.AbsolutePosition.X)/HueBar.AbsoluteSize.X, 0, 1), nil, nil)
                    elseif dSV then
                        UpdateColor(nil,
                            math.clamp((input.Position.X - SVBox.AbsolutePosition.X)/SVBox.AbsoluteSize.X, 0, 1),
                            1 - math.clamp((input.Position.Y - SVBox.AbsolutePosition.Y)/SVBox.AbsoluteSize.Y, 0, 1))
                    end
                end
            end)
            HueBar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dHue=true end end)
            SVBox.InputBegan:Connect(function(i)  if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dSV=true end end)
            UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dHue=false; dSV=false end end)
            local function FromRGB()
                local col = Color3.fromRGB(tonumber(RBox.Text) or 0, tonumber(GBox.Text) or 0, tonumber(BBox.Text) or 0)
                local h2,s2,v2 = col:ToHSV(); UpdateColor(h2,s2,v2)
            end
            RBox.FocusLost:Connect(FromRGB); GBox.FocusLost:Connect(FromRGB); BBox.FocusLost:Connect(FromRGB)
        else
            RBox.Editable=false; GBox.Editable=false; BBox.Editable=false; HexBox.Editable=false
            SVBox.Active=false; HueBar.Active=false
        end

        function ReturnedTable:Set(NewColor)
            local h,s,v = NewColor:ToHSV(); UpdateColor(h,s,v)
        end
        return ReturnedTable
    end

    -- ============================================================
    -- DROPDOWN
    -- ============================================================
    function Reg.Dropdown(Page, Config)
        local ReturnedTable = {}
        local DropdownFrame = Instance.new("Frame")
        DropdownFrame.Parent = Page
        DropdownFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
        DropdownFrame.Size = UDim2.new(1,-10,0,35)
        DropdownFrame.ClipsDescendants = true
        Instance.new("UICorner", DropdownFrame).CornerRadius = UDim.new(0,6)
        DropdownFrame:SetAttribute("SearchName", string.lower(Config.Name or ""))

        local Locked = ApplyLock(DropdownFrame, Config)
        local DropdownOpen = false
        local Options = Config.Options or {}
        local CurrentOption = Config.CurrentOption or Options[1] or "Sélectionner..."

        local MainBtn = Instance.new("TextButton")
        MainBtn.Parent = DropdownFrame
        MainBtn.BackgroundTransparency = 1
        MainBtn.Size = UDim2.new(1,0,0,35)
        MainBtn.Font = Enum.Font.SourceSans
        MainBtn.Text = "  " .. (Config.Name or "") .. ": " .. CurrentOption
        MainBtn.TextColor3 = Color3.new(1,1,1)
        MainBtn.TextSize = 16
        MainBtn.TextXAlignment = Enum.TextXAlignment.Left

        local ArrowIcon = Instance.new("ImageLabel")
        ArrowIcon.Parent = MainBtn
        ArrowIcon.BackgroundTransparency = 1
        ArrowIcon.Position = UDim2.new(1,-30,0,7)
        ArrowIcon.Size = UDim2.new(0,20,0,20)
        ArrowIcon.Image = "rbxassetid://6034818372"

        local OptionsContainer = Instance.new("Frame")
        OptionsContainer.Parent = DropdownFrame
        OptionsContainer.BackgroundTransparency = 1
        OptionsContainer.Position = UDim2.new(0,0,0,35)
        OptionsContainer.Size = UDim2.new(1,0,0,0)
        OptionsContainer.Visible = false
        Instance.new("UIListLayout", OptionsContainer).SortOrder = Enum.SortOrder.LayoutOrder

        local function RefreshOptions(NewList)
            for _, v in pairs(OptionsContainer:GetChildren()) do
                if v:IsA("TextButton") then v:Destroy() end
            end
            Options = NewList
            for _, option in ipairs(Options) do
                local OptBtn = Instance.new("TextButton")
                OptBtn.Parent = OptionsContainer
                OptBtn.BackgroundColor3 = Color3.fromRGB(35,35,35)
                OptBtn.Size = UDim2.new(1,0,0,30)
                OptBtn.Text = "  " .. option
                OptBtn.TextColor3 = Settings.TextColor
                OptBtn.TextXAlignment = Enum.TextXAlignment.Left
                OptBtn.Font = Enum.Font.SourceSans
                OptBtn.TextSize = 15
                OptBtn.MouseButton1Click:Connect(function()
                    CurrentOption = option
                    MainBtn.Text = "  " .. (Config.Name or "") .. ": " .. option
                    DropdownOpen = false
                    TweenService:Create(ArrowIcon, TweenInfo.new(0.2), {Rotation=0}):Play()
                    local ct = TweenService:Create(DropdownFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size=UDim2.new(1,-10,0,35)})
                    ct:Play(); ct.Completed:Wait(); OptionsContainer.Visible=false
                    if Config.Callback then Config.Callback(option) end
                end)
            end
        end
        RefreshOptions(Options)

        if not Locked then
            MainBtn.MouseButton1Click:Connect(function()
                DropdownOpen = not DropdownOpen
                if DropdownOpen then
                    OptionsContainer.Visible = true
                    TweenService:Create(ArrowIcon, TweenInfo.new(0.2), {Rotation=180}):Play()
                    TweenService:Create(DropdownFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size=UDim2.new(1,-10,0,35+#Options*30)}):Play()
                else
                    TweenService:Create(ArrowIcon, TweenInfo.new(0.2), {Rotation=0}):Play()
                    local ct = TweenService:Create(DropdownFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size=UDim2.new(1,-10,0,35)})
                    ct:Play(); ct.Completed:Wait(); OptionsContainer.Visible=false
                end
            end)
        else
            MainBtn.Active = false
        end

        function ReturnedTable:Refresh(List) RefreshOptions(List) end
        function ReturnedTable:Set(Option)
            CurrentOption = Option
            MainBtn.Text = "  " .. (Config.Name or "") .. ": " .. Option
        end
        return ReturnedTable
    end

    -- ============================================================
    -- SLIDER
    -- ============================================================
    function Reg.Slider(Page, Config)
        local SliderFrame = Instance.new("Frame")
        SliderFrame.Parent = Page
        SliderFrame.BackgroundTransparency = 1
        SliderFrame.Size = UDim2.new(1,-10,0,50)
        SliderFrame:SetAttribute("SearchName", string.lower(Config.Name or ""))

        local Locked = ApplyLock(SliderFrame, Config)

        local Label = Instance.new("TextLabel")
        Label.Parent = SliderFrame
        Label.BackgroundTransparency = 1
        Label.Position = UDim2.new(0,10,0,0)
        Label.Size = UDim2.new(1,0,0,20)
        Label.Text = Config.Name or ""
        Label.TextColor3 = Color3.new(1,1,1)
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Font = Enum.Font.SourceSans
        Label.TextSize = 16

        local ValLabel = Instance.new("TextLabel")
        ValLabel.Parent = SliderFrame
        ValLabel.BackgroundTransparency = 1
        ValLabel.Position = UDim2.new(1,-60,0,0)
        ValLabel.Size = UDim2.new(0,50,0,20)
        ValLabel.TextColor3 = Color3.new(1,1,1)
        ValLabel.TextXAlignment = Enum.TextXAlignment.Right
        ValLabel.Font = Enum.Font.SourceSansBold
        ValLabel.TextSize = 16

        local Bar = Instance.new("Frame")
        Bar.Parent = SliderFrame
        Bar.BackgroundColor3 = Color3.fromRGB(10,10,10)
        Bar.Position = UDim2.new(0,10,0,25)
        Bar.Size = UDim2.new(1,-20,0,10)
        Instance.new("UICorner", Bar).CornerRadius = UDim.new(1,0)

        local Knob = Instance.new("TextButton")
        Knob.Parent = Bar
        Knob.BackgroundColor3 = Settings.AccentColor
        Knob.Size = UDim2.new(0,20,0,20)
        Knob.AnchorPoint = Vector2.new(0.5,0.5)
        Knob.Position = UDim2.new(0,0,0.5,0)
        Knob.Text = ""
        Instance.new("UICorner", Knob).CornerRadius = UDim.new(1,0)

        local Min, Max = Config.Range[1] or 0, Config.Range[2] or 100
        local Default = Config.CurrentValue or Min
        ValLabel.Text = tostring(Default) .. "%"
        Knob.Position = UDim2.new((Default-Min)/(Max-Min), 0, 0.5, 0)

        local SliderObj = {}
        if not Locked then
            local dragging = false
            Knob.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=true end end)
            UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=false end end)
            UserInputService.InputChanged:Connect(function(i)
                if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
                    local P = math.clamp((i.Position.X - Bar.AbsolutePosition.X)/Bar.AbsoluteSize.X, 0, 1)
                    Knob.Position = UDim2.new(P, 0, 0.5, 0)
                    local Val = math.floor(Min + (Max-Min)*P)
                    ValLabel.Text = tostring(Val) .. "%"
                    if Config.Callback then Config.Callback(Val) end
                end
            end)
        else
            Knob.Active = false
        end

        function SliderObj:Set(Value)
            local P = (Value-Min)/(Max-Min)
            Knob.Position = UDim2.new(P, 0, 0.5, 0)
            ValLabel.Text = tostring(Value) .. "%"
            if Config.Callback then Config.Callback(Value) end
        end
        return SliderObj
    end

    return Reg
end
