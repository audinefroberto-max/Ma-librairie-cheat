-- ================================================================
-- SoroniceLib_IconCard.lua  (V2 — FIX GRILLE + nouveaux paramètres)
-- ================================================================
-- BUG CORRIGÉ : La grille UIGridLayout absorbait les éléments
-- Button/Toggle/etc. créés APRÈS les IconCard dans la même page.
-- SOLUTION : La grille est désormais dans un Frame SÉPARÉ avec
-- AutomaticSize, inséré comme un seul élément dans le UIListLayout
-- de la page. Les éléments suivants (Button, Toggle...) sont dans
-- le ListLayout normal de la page, pas dans la grille.
-- ================================================================

return function(Ctx)
    local Settings         = Ctx.Settings
    local TweenService     = Ctx.TweenService
    local UserInputService = Ctx.UserInputService
    local ApplyLock        = Ctx.ApplyLock
    local ActiveToggles    = Ctx.ActiveToggles

    local function Corner(Parent, Shape)
        local c = Instance.new("UICorner")
        c.Parent = Parent
        c.CornerRadius = (Shape == "Square") and UDim.new(0,4) or UDim.new(0,16)
        return c
    end

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

        if Style == 3 then
            local RS = Instance.new("UIStroke")
            RS.Parent = Bg; RS.Thickness = 2; RS.Color = AccentColor
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
            ConnectClick = function(fn) ClickBtn.MouseButton1Click:Connect(fn) end
        }
    end

    -- ─────────────────────────────────────────────────────────────
    -- FONCTION PRINCIPALE
    -- ─────────────────────────────────────────────────────────────
    local function CreateIconCard(Page, Config)
        local ReturnedTable = {}
        Config = Config or {}

        -- ★ FIX BUG GRILLE ★
        -- On cherche un wrapper dédié aux IconCards UNIQUEMENT s'il
        -- est l'ENFANT DIRECT SUIVANT dans le ListLayout. Si le dernier
        -- enfant de la page est une grille IconCard, on la réutilise.
        -- Sinon, on en crée une nouvelle. Cela garantit qu'un Button
        -- créé AVANT ou APRÈS les IconCards reste dans le ListLayout
        -- normal et ne se retrouve PAS dans la grille.
        local Grid = nil
        local Children = Page:GetChildren()
        local LastChild = nil
        for _, c in ipairs(Children) do
            if c:IsA("Frame") and c.Name == "IconCardGrid" then
                LastChild = c
            end
        end
        -- On ne réutilise la grille que si c'est le dernier élément ajouté
        -- ET qu'aucun élément non-IconCard n'a été ajouté depuis.
        -- Pour simplifier : on cherche si le dernier Frame du ListLayout
        -- est bien une IconCardGrid. Sinon on en crée une nouvelle.
        local lastLayoutOrder = 0
        for _, c in ipairs(Children) do
            if c:IsA("Frame") or c:IsA("ScrollingFrame") then
                local lo = c.LayoutOrder
                if lo > lastLayoutOrder then
                    lastLayoutOrder = lo
                    LastChild = c
                end
            end
        end
        if LastChild and LastChild.Name == "IconCardGrid" then
            Grid = LastChild
        end

        if not Grid then
            Grid = Instance.new("Frame")
            Grid.Name = "IconCardGrid"
            Grid.Parent = Page
            Grid.BackgroundTransparency = 1
            -- Prend toute la largeur de la page, hauteur automatique
            Grid.Size = UDim2.new(1, -10, 0, 0)
            Grid.AutomaticSize = Enum.AutomaticSize.Y
            -- LayoutOrder plus grand que les éléments précédents
            Grid.LayoutOrder = lastLayoutOrder + 1

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

        local Grad = Instance.new("UIGradient")
        Grad.Parent = Card; Grad.Rotation = 90
        Grad.Color = ColorSequence.new(Color3.fromRGB(38,38,38), Color3.fromRGB(22,22,22))

        local StrokeColor = Config.StrokeColor or Color3.fromRGB(55,55,55)
        local CardStroke = Instance.new("UIStroke")
        CardStroke.Parent = Card; CardStroke.Color = StrokeColor
        CardStroke.Thickness = 1; CardStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

        local ImageHolder = Instance.new("ImageLabel")
        ImageHolder.Name = "Icon"; ImageHolder.Parent = Card
        ImageHolder.BackgroundColor3 = Color3.fromRGB(40,40,40)
        ImageHolder.BackgroundTransparency = 0.2
        ImageHolder.Position = UDim2.new(0, 8, 0, 8)
        ImageHolder.Size = UDim2.new(1,-16,0,88)
        ImageHolder.Image = Config.Image or ""
        ImageHolder.ScaleType = Enum.ScaleType.Fit
        Corner(ImageHolder, Config.BaseShape)

        if Config.StrokeImage then
            local IS = Instance.new("UIStroke"); IS.Parent = ImageHolder
            IS.Color = StrokeColor; IS.Thickness = 1
            IS.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        end

        local NameLabel = Instance.new("TextLabel"); NameLabel.Parent = Card
        NameLabel.BackgroundTransparency = 1
        NameLabel.Position = UDim2.new(0,4,0,100)
        NameLabel.Size = UDim2.new(1,-8,0,20)
        NameLabel.Font = Enum.Font.SourceSansBold
        NameLabel.Text = Config.Name or ""
        NameLabel.TextColor3 = Settings.TextColor
        NameLabel.TextScaled = false; NameLabel.TextSize = 15; NameLabel.TextWrapped = true

        if Config.StrokeTitle then
            local TL = Instance.new("Frame"); TL.Parent = Card
            TL.BackgroundColor3 = StrokeColor
            TL.Position = UDim2.new(0, 4, 0, 120)
            TL.Size = UDim2.new(1, -8, 0, 1); TL.BorderSizePixel = 0
        end

        local Mode = Config.Mode or "Button"
        local Locked = ApplyLock(Card, Config)

        local ActionRow = Instance.new("Frame"); ActionRow.Parent = Card
        ActionRow.AnchorPoint = Vector2.new(0.5, 0)
        ActionRow.Position = UDim2.new(0.5, 0, 0, 126)
        ActionRow.Size = UDim2.new(1, -16, 0, 32)
        ActionRow.BackgroundColor3 = Color3.fromRGB(40,40,40)
        Corner(ActionRow, Config.ButtonShape)

        local BtnStrokeEnabled = (Config.StrokeButton ~= false)
        local BtnStroke = nil
        if BtnStrokeEnabled then
            BtnStroke = Instance.new("UIStroke"); BtnStroke.Parent = ActionRow
            BtnStroke.Color = StrokeColor; BtnStroke.Thickness = 1
            BtnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        end

        if Mode == "Toggle" then
            local BtnLabel = Instance.new("TextLabel"); BtnLabel.Parent = ActionRow
            BtnLabel.BackgroundTransparency = 1
            BtnLabel.Position = UDim2.new(0,8,0,0)
            BtnLabel.Size = UDim2.new(0.55,0,1,0)
            BtnLabel.Font = Enum.Font.SourceSansBold
            BtnLabel.Text = Config.ButtonText or ""
            BtnLabel.TextColor3 = Settings.TextColor
            BtnLabel.TextSize = 15; BtnLabel.TextXAlignment = Enum.TextXAlignment.Left

            local Pill = MakeTogglePill(ActionRow, Config.ToggleStyle, Settings.AccentColor)
            table.insert(ActiveToggles, {Callback = Config.Callback})
            local Toggled = Config.CurrentValue or false
            Pill.Set(Toggled)

            if not Locked then
                Pill.ConnectClick(function()
                    Toggled = not Toggled; Pill.Set(Toggled)
                    if Config.Callback then Config.Callback(Toggled) end
                end)
            else Pill.Frame.Active = false end

            function ReturnedTable:Set(Value)
                Toggled = Value; Pill.Set(Value)
                if Config.Callback then Config.Callback(Value) end
            end
        else
            local ActionBtn = Instance.new("TextButton"); ActionBtn.Parent = ActionRow
            ActionBtn.BackgroundTransparency = 1; ActionBtn.Size = UDim2.new(1,0,1,0)
            ActionBtn.Font = Enum.Font.SourceSansBold
            ActionBtn.Text = Config.ButtonText or ""
            ActionBtn.TextColor3 = Settings.TextColor; ActionBtn.TextSize = 18

            local OverlayImg = nil
            if Config.ButtonImage then
                OverlayImg = Instance.new("ImageLabel"); OverlayImg.Name = "OverlayImage"
                OverlayImg.Parent = ActionRow; OverlayImg.BackgroundTransparency = 1
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
            else ActionBtn.Active = false end

            function ReturnedTable:Set(Value) ActionBtn.Text = tostring(Value) end
            function ReturnedTable:SetButtonImage(NewImage) if OverlayImg then OverlayImg.Image = NewImage end end
        end

        if Config.HoverEffect ~= false then
            local BtnBaseSize = ActionRow.Size
            ActionRow.AnchorPoint = Vector2.new(0.5, 0)
            Card.MouseEnter:Connect(function()
                TweenService:Create(ActionRow, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Size = UDim2.new(BtnBaseSize.X.Scale, BtnBaseSize.X.Offset + 6, BtnBaseSize.Y.Scale, BtnBaseSize.Y.Offset + 4)
                }):Play()
                TweenService:Create(CardStroke, TweenInfo.new(0.15), {Color = Settings.AccentColor, Thickness = 2}):Play()
            end)
            Card.MouseLeave:Connect(function()
                TweenService:Create(ActionRow, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = BtnBaseSize}):Play()
                TweenService:Create(CardStroke, TweenInfo.new(0.15), {Color = StrokeColor, Thickness = 1}):Play()
            end)
        end

        function ReturnedTable:SetImage(NewImage) ImageHolder.Image = NewImage end
        function ReturnedTable:SetText(NewName)
            NameLabel.Text = NewName
            Card:SetAttribute("SearchName", string.lower(NewName))
        end
        function ReturnedTable:SetButtonText(NewText)
            for _, c in pairs(ActionRow:GetChildren()) do
                if c:IsA("TextLabel") or c:IsA("TextButton") then c.Text = NewText end
            end
        end
        function ReturnedTable:SetStrokeColor(NewColor)
            StrokeColor = NewColor; CardStroke.Color = NewColor
            if BtnStroke then BtnStroke.Color = NewColor end
        end
        function ReturnedTable:SetStroke(Enabled)
            CardStroke.Enabled = Enabled
            if BtnStroke then BtnStroke.Enabled = Enabled end
        end
        function ReturnedTable:SetTransparency(Alpha) Card.BackgroundTransparency = Alpha end

        return ReturnedTable
    end

    return CreateIconCard
end
