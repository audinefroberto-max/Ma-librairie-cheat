-- ================================================================
-- SoroniceLib_IconCard.lua
-- Composant "IconCard" séparé, chargeable depuis GitHub
--
-- Config disponible :
--   Name          (string)  Texte affiché sous l'image
--   Image         (string)  rbxassetid://...
--   ButtonText    (string)  Texte du bouton du bas (ex. "TP")
--   ButtonImage   (string)  Image par-dessus le bouton (optionnel)
--   Mode          (string)  "Button" (défaut) ou "Toggle"
--   ToggleStyle   (number)  1/2/3 — style du toggle (si Mode="Toggle")
--   BaseShape     (string)  "Round" (défaut) ou "Square"
--   ButtonShape   (string)  "Round" (défaut) ou "Square"
--   HoverEffect   (bool)    true (défaut) / false pour désactiver
--   CurrentValue  (bool)    valeur initiale du toggle
--   Callback      (func)    fonction appelée au clic / changement
--   StrokeColor   (Color3)  couleur du contour de la carte
--   StrokeImage   (bool)    contour sur la zone image ? (défaut false)
--   StrokeButton  (bool)    contour sur le bouton/toggle ? (défaut true)
--   StrokeTitle   (bool)    contour sous le texte titre ? (défaut false)
--   BgTransparency (number) transparence du fond de la carte (0-1)
--   Height        (number)  hauteur de la carte en px (défaut 178)
-- ================================================================

return function(Ctx)
    local Settings      = Ctx.Settings
    local TweenService  = Ctx.TweenService
    local UserInputService = Ctx.UserInputService
    local ApplyLock     = Ctx.ApplyLock
    local ActiveToggles = Ctx.ActiveToggles

    -- ─── Helper coins ─────────────────────────────────────────
    local function Corner(Parent, Shape)
        local c = Instance.new("UICorner")
        c.Parent = Parent
        c.CornerRadius = (Shape == "Square") and UDim.new(0,4) or UDim.new(0,16)
        return c
    end

    -- ─── Helper : toggle pill (vrai bouton bascule) ───────────
    -- Renvoie { Frame, Set(bool), ConnectClick(fn) }
    local function MakeTogglePill(Parent, Style, AccentColor)
        Style = Style or 1
        local PillW, PillH = 54, 24

        local Bg = Instance.new("Frame")
        Bg.Parent = Parent
        Bg.BackgroundColor3 = Color3.fromRGB(40,40,40)
        Bg.AnchorPoint = Vector2.new(1, 0.5)
        Bg.Position = UDim2.new(1, -8, 0.5, 0)
        Bg.Size = UDim2.new(0, PillW, 0, PillH)
        Instance.new("UICorner", Bg).CornerRadius = UDim.new(1,0)

        local Knob = Instance.new("Frame")
        Knob.Parent = Bg
        Knob.BackgroundColor3 = Color3.fromRGB(230,230,230)
        Knob.AnchorPoint = Vector2.new(0, 0.5)
        Knob.Position = UDim2.new(0, 2, 0.5, 0)
        Knob.Size = UDim2.new(0, PillH-4, 0, PillH-4)
        Instance.new("UICorner", Knob).CornerRadius = UDim.new(1,0)

        -- Style 3 = rainbow stroke sur le pill
        if Style == 3 then
            local RS = Instance.new("UIStroke")
            RS.Parent = Bg
            RS.Thickness = 2
            RS.Color = AccentColor
            RS.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            task.spawn(function()
                local hue = 0
                while Bg.Parent do
                    hue = (hue + 0.006) % 1
                    RS.Color = Color3.fromHSV(hue,1,1)
                    task.wait(0.025)
                end
            end)
        end

        local ClickBtn = Instance.new("TextButton")
        ClickBtn.Parent = Bg
        ClickBtn.BackgroundTransparency = 1
        ClickBtn.Size = UDim2.new(1,0,1,0)
        ClickBtn.Text = ""
        ClickBtn.ZIndex = Bg.ZIndex + 2

        local Toggled = false
        local function SetState(val)
            Toggled = val
            local TargetPos = Toggled and UDim2.new(1, -(PillH-2), 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
            local TargetBg  = Toggled and AccentColor or Color3.fromRGB(40,40,40)
            TweenService:Create(Knob, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {Position=TargetPos}):Play()
            TweenService:Create(Bg,   TweenInfo.new(0.2), {BackgroundColor3=TargetBg}):Play()
        end

        return {
            Frame = Bg,
            Set   = SetState,
            ConnectClick = function(fn)
                ClickBtn.MouseButton1Click:Connect(fn)
            end
        }
    end

    -- ─── Fonction principale : crée une IconCard ──────────────
    local function CreateIconCard(Page, Config)
        local ReturnedTable = {}
        Config = Config or {}

        -- Conteneur en grille (4 par ligne) partagé sur toute la Page
        local Grid = Page:FindFirstChild("IconCardGrid")
        if not Grid then
            Grid = Instance.new("Frame")
            Grid.Name = "IconCardGrid"
            Grid.Parent = Page
            Grid.BackgroundTransparency = 1
            Grid.Size = UDim2.new(1, -10, 0, 0)
            Grid.AutomaticSize = Enum.AutomaticSize.Y

            local P = Instance.new("UIPadding")
            P.Parent = Grid
            P.PaddingLeft   = UDim.new(0, 4)
            P.PaddingRight  = UDim.new(0, 4)
            P.PaddingTop    = UDim.new(0, 4)
            P.PaddingBottom = UDim.new(0, 4)

            local GL = Instance.new("UIGridLayout")
            GL.Parent = Grid
            GL.SortOrder = Enum.SortOrder.LayoutOrder
            GL.CellPadding = UDim2.new(0, 8, 0, 8)
            GL.CellSize = UDim2.new(0.25, -8, 0, Config.Height or 178)
            GL.FillDirectionMaxCells = 4
            GL.HorizontalAlignment = Enum.HorizontalAlignment.Left
        end

        -- ─── Carte principale ──────────────────────────────────
        local Card = Instance.new("Frame")
        Card.Parent = Grid
        Card.BackgroundColor3 = Color3.fromRGB(28,28,28)
        Card.BackgroundTransparency = Config.BgTransparency or 0
        Card.Size = UDim2.new(1,0,1,0)
        Card.ClipsDescendants = false
        Card:SetAttribute("SearchName", string.lower(Config.Name or ""))
        Corner(Card, Config.BaseShape)

        -- Dégradé léger
        local Grad = Instance.new("UIGradient")
        Grad.Parent = Card
        Grad.Rotation = 90
        Grad.Color = ColorSequence.new(Color3.fromRGB(38,38,38), Color3.fromRGB(22,22,22))

        -- Contour de la carte (UIStroke)
        local StrokeColor = Config.StrokeColor or Color3.fromRGB(55,55,55)
        local CardStroke = Instance.new("UIStroke")
        CardStroke.Parent = Card
        CardStroke.Color = StrokeColor
        CardStroke.Thickness = 1
        CardStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

        -- ─── Zone image ────────────────────────────────────────
        local ImageHolder = Instance.new("ImageLabel")
        ImageHolder.Name = "Icon"
        ImageHolder.Parent = Card
        ImageHolder.BackgroundColor3 = Color3.fromRGB(40,40,40)
        ImageHolder.BackgroundTransparency = 0.2
        ImageHolder.Position = UDim2.new(0, 8, 0, 8)
        ImageHolder.Size = UDim2.new(1,-16,0,88)
        ImageHolder.Image = Config.Image or ""
        ImageHolder.ScaleType = Enum.ScaleType.Fit
        Corner(ImageHolder, Config.BaseShape)

        -- Contour optionnel sur l'image
        if Config.StrokeImage then
            local IS = Instance.new("UIStroke")
            IS.Parent = ImageHolder
            IS.Color = StrokeColor
            IS.Thickness = 1
            IS.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        end

        -- ─── Texte titre ───────────────────────────────────────
        local NameLabel = Instance.new("TextLabel")
        NameLabel.Parent = Card
        NameLabel.BackgroundTransparency = 1
        NameLabel.Position = UDim2.new(0,4,0,100)
        NameLabel.Size = UDim2.new(1,-8,0,20)
        NameLabel.Font = Enum.Font.SourceSansBold
        NameLabel.Text = Config.Name or ""
        NameLabel.TextColor3 = Settings.TextColor
        NameLabel.TextScaled = false
        NameLabel.TextSize = 15
        NameLabel.TextWrapped = true

        -- Soulignement optionnel sur le titre
        if Config.StrokeTitle then
            local TL = Instance.new("Frame")
            TL.Parent = Card
            TL.BackgroundColor3 = StrokeColor
            TL.Position = UDim2.new(0, 4, 0, 120)
            TL.Size = UDim2.new(1, -8, 0, 1)
            TL.BorderSizePixel = 0
        end

        -- ─── Bouton du bas (Button ou Toggle) ─────────────────
        local Mode = Config.Mode or "Button"
        local Locked = ApplyLock(Card, Config)

        -- Conteneur du bas : fond arrondi
        local ActionRow = Instance.new("Frame")
        ActionRow.Parent = Card
        ActionRow.AnchorPoint = Vector2.new(0.5, 0)
        ActionRow.Position = UDim2.new(0.5, 0, 0, 126)
        ActionRow.Size = UDim2.new(1, -16, 0, 32)
        ActionRow.BackgroundColor3 = Color3.fromRGB(40,40,40)
        Corner(ActionRow, Config.ButtonShape)

        -- Contour sur le bouton (activé par défaut)
        local BtnStrokeEnabled = (Config.StrokeButton ~= false)
        local BtnStroke = nil
        if BtnStrokeEnabled then
            BtnStroke = Instance.new("UIStroke")
            BtnStroke.Parent = ActionRow
            BtnStroke.Color = StrokeColor
            BtnStroke.Thickness = 1
            BtnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        end

        if Mode == "Toggle" then
            -- ── Vrai toggle pill ──────────────────────────────
            local BtnLabel = Instance.new("TextLabel")
            BtnLabel.Parent = ActionRow
            BtnLabel.BackgroundTransparency = 1
            BtnLabel.Position = UDim2.new(0,8,0,0)
            BtnLabel.Size = UDim2.new(0.55,0,1,0)
            BtnLabel.Font = Enum.Font.SourceSansBold
            BtnLabel.Text = Config.ButtonText or ""
            BtnLabel.TextColor3 = Settings.TextColor
            BtnLabel.TextSize = 15
            BtnLabel.TextXAlignment = Enum.TextXAlignment.Left

            local Pill = MakeTogglePill(ActionRow, Config.ToggleStyle, Settings.AccentColor)
            table.insert(ActiveToggles, {Callback = Config.Callback})

            local Toggled = Config.CurrentValue or false
            Pill.Set(Toggled)

            if not Locked then
                Pill.ConnectClick(function()
                    Toggled = not Toggled
                    Pill.Set(Toggled)
                    if Config.Callback then Config.Callback(Toggled) end
                end)
            else
                Pill.Frame.Active = false
            end

            function ReturnedTable:Set(Value)
                Toggled = Value
                Pill.Set(Value)
                if Config.Callback then Config.Callback(Value) end
            end

        else
            -- ── Bouton classique ──────────────────────────────
            local ActionBtn = Instance.new("TextButton")
            ActionBtn.Parent = ActionRow
            ActionBtn.BackgroundTransparency = 1
            ActionBtn.Size = UDim2.new(1,0,1,0)
            ActionBtn.Font = Enum.Font.SourceSansBold
            ActionBtn.Text = Config.ButtonText or ""
            ActionBtn.TextColor3 = Settings.TextColor
            ActionBtn.TextSize = 18

            -- Image par-dessus le bouton (optionnel)
            local OverlayImg = nil
            if Config.ButtonImage then
                OverlayImg = Instance.new("ImageLabel")
                OverlayImg.Name = "OverlayImage"
                OverlayImg.Parent = ActionRow
                OverlayImg.BackgroundTransparency = 1
                OverlayImg.AnchorPoint = Vector2.new(0.5,0.5)
                OverlayImg.Position = UDim2.new(0.5,0,0.5,0)
                OverlayImg.Size = UDim2.new(0,20,0,20)
                OverlayImg.Image = Config.ButtonImage
                OverlayImg.ZIndex = ActionBtn.ZIndex + 1
            end

            if not Locked then
                ActionBtn.MouseButton1Click:Connect(function()
                    TweenService:Create(ActionRow, TweenInfo.new(0.1), {BackgroundColor3=Color3.fromRGB(60,60,60)}):Play()
                    task.wait(0.1)
                    TweenService:Create(ActionRow, TweenInfo.new(0.1), {BackgroundColor3=Color3.fromRGB(40,40,40)}):Play()
                    if Config.Callback then Config.Callback() end
                end)
            else
                ActionBtn.Active = false
            end

            function ReturnedTable:Set(Value)
                ActionBtn.Text = tostring(Value)
            end
            function ReturnedTable:SetButtonImage(NewImage)
                if OverlayImg then OverlayImg.Image = NewImage end
            end
        end

        -- ─── Toggle "Tout cacher le contour" en bas de la carte ─
        -- Uniquement si Config.ShowStrokeToggle = true
        if Config.ShowStrokeToggle then
            local StrokeToggleRow = Instance.new("Frame")
            StrokeToggleRow.Parent = Card
            StrokeToggleRow.BackgroundTransparency = 1
            StrokeToggleRow.AnchorPoint = Vector2.new(0.5, 0)
            StrokeToggleRow.Position = UDim2.new(0.5, 0, 1, -20)
            StrokeToggleRow.Size = UDim2.new(1, 0, 0, 16)

            local ST = Instance.new("TextButton")
            ST.Parent = StrokeToggleRow
            ST.BackgroundTransparency = 1
            ST.Size = UDim2.new(1,0,1,0)
            ST.Text = "〔 contour 〕"
            ST.TextColor3 = Color3.fromRGB(100,100,100)
            ST.TextSize = 10
            ST.Font = Enum.Font.SourceSans
            ST.ZIndex = 5

            local strokesOn = true
            ST.MouseButton1Click:Connect(function()
                strokesOn = not strokesOn
                CardStroke.Enabled = strokesOn
                if BtnStroke then BtnStroke.Enabled = strokesOn end
                ST.TextColor3 = strokesOn and Color3.fromRGB(100,100,100) or Color3.fromRGB(60,60,60)
            end)
        end

        -- ─── Effet de survol (centré sur le bouton) ───────────
        -- On utilise AnchorPoint 0.5 pour que la croissance soit symétrique
        if Config.HoverEffect ~= false then
            local BtnBaseSize  = ActionRow.Size
            local BtnBasePos   = ActionRow.Position
            ActionRow.AnchorPoint = Vector2.new(0.5, 0)

            Card.MouseEnter:Connect(function()
                TweenService:Create(ActionRow, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Size = UDim2.new(BtnBaseSize.X.Scale, BtnBaseSize.X.Offset + 6, BtnBaseSize.Y.Scale, BtnBaseSize.Y.Offset + 4)
                }):Play()
                TweenService:Create(CardStroke, TweenInfo.new(0.15), {Color = Settings.AccentColor, Thickness = 2}):Play()
            end)
            Card.MouseLeave:Connect(function()
                TweenService:Create(ActionRow, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                    Size = BtnBaseSize
                }):Play()
                TweenService:Create(CardStroke, TweenInfo.new(0.15), {Color = StrokeColor, Thickness = 1}):Play()
            end)
        end

        -- ─── Méthodes publiques ────────────────────────────────
        function ReturnedTable:SetImage(NewImage)
            ImageHolder.Image = NewImage
        end
        function ReturnedTable:SetText(NewName)
            NameLabel.Text = NewName
            Card:SetAttribute("SearchName", string.lower(NewName))
        end
        function ReturnedTable:SetButtonText(NewText)
            -- Fonctionne en mode Button et Toggle (label)
            for _, c in pairs(ActionRow:GetChildren()) do
                if c:IsA("TextLabel") or c:IsA("TextButton") then
                    c.Text = NewText
                end
            end
        end
        function ReturnedTable:SetStrokeColor(NewColor)
            StrokeColor = NewColor
            CardStroke.Color = NewColor
            if BtnStroke then BtnStroke.Color = NewColor end
        end
        function ReturnedTable:SetStroke(Enabled)
            CardStroke.Enabled = Enabled
            if BtnStroke then BtnStroke.Enabled = Enabled end
        end
        function ReturnedTable:SetTransparency(Alpha)
            Card.BackgroundTransparency = Alpha
        end

        return ReturnedTable
    end

    return CreateIconCard
end
