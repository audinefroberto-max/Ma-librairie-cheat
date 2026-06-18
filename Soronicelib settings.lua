-- ================================================================
-- SoroniceLib_Settings.lua
-- Module séparé : éléments de la page Paramètres ⚙️
-- Chargeable depuis GitHub, sans toucher à la librairie principale
--
-- Pour ajouter un nouveau réglage : rajoute un CreateElement(...)
-- dans le bloc approprié, c'est tout.
-- ================================================================

return function(Ctx)
    local Settings      = Ctx.Settings
    local TweenService  = Ctx.TweenService
    local CreateElement = Ctx.CreateElement  -- fonction interne de la lib
    local SettingsPage  = Ctx.SettingsPage
    local IsMobile      = Ctx.IsMobile
    local MainFrame     = Ctx.MainFrame
    local MainCorner    = Ctx.MainCorner
    local MainStroke    = Ctx.MainStroke
    local AlwaysVisible = Ctx.AlwaysVisible     -- table ref {value=bool}
    local ForceShow     = Ctx.ForceShow
    local StartMulticolor = Ctx.StartMulticolor
    local StopMulticolor  = Ctx.StopMulticolor
    local antiAfkActive = Ctx.antiAfkActive     -- table ref {value=bool}
    local TargetSize    = Ctx.TargetSize

    -- ============================================================
    -- SECTION : Paramètres de base (existants)
    -- ============================================================
    CreateElement(SettingsPage, "Toggle", {
        Name = "💤 Mode AFK (Anti-Kick)",
        CurrentValue = false,
        Callback = function(Value)
            antiAfkActive.value = Value
            if Value then
                game.StarterGui:SetCore("SendNotification", {
                    Title = "Anti-AFK",
                    Text  = "Activé : Vous ne serez pas kické.",
                    Duration = 3
                })
            end
        end
    })

    if not IsMobile then
        CreateElement(SettingsPage, "Keybind", {
            Name = "Touche pour Cacher/Montrer",
            Callback = function() end
        })
    end

    -- ============================================================
    -- SECTION : Visibilité
    -- ============================================================
    CreateElement(SettingsPage, "Section", {Text = "👁️ Visibilité"})

    CreateElement(SettingsPage, "Toggle", {
        Name = "👁️ Toujours visible (désactive le masquage)",
        CurrentValue = false,
        Callback = function(Value)
            AlwaysVisible.value = Value
            if Value then ForceShow() end
        end
    })

    -- ============================================================
    -- SECTION : Apparence de la fenêtre
    -- ============================================================
    CreateElement(SettingsPage, "Section", {Text = "🎛️ Apparence de la fenêtre"})

    CreateElement(SettingsPage, "Toggle", {
        Name = "⬜ Coins carrés (non-arrondis)",
        CurrentValue = false,
        Callback = function(Value)
            local Target = Value and UDim.new(0,0) or UDim.new(0,10)
            TweenService:Create(MainCorner, TweenInfo.new(0.2), {CornerRadius = Target}):Play()
        end
    })

    CreateElement(SettingsPage, "Dropdown", {
        Name = "🌫️ Transparence de la fenêtre",
        Options = {"0%", "10%", "20% (défaut)", "30%", "40%", "50%", "60%", "70%"},
        CurrentOption = "20% (défaut)",
        Callback = function(Selected)
            local Pct = tonumber(string.match(Selected, "%d+"))
            if Pct then MainFrame.BackgroundTransparency = Pct / 100 end
        end
    })

    CreateElement(SettingsPage, "ColorPicker", {
        Name = "🎨 Couleur de la fenêtre",
        Color = Settings.ThemeColor,
        Callback = function(NewColor)
            MainFrame.BackgroundColor3 = NewColor
        end
    })

    -- ============================================================
    -- SECTION : Contour de la fenêtre
    -- ============================================================
    CreateElement(SettingsPage, "Section", {Text = "🖼️ Contour de la fenêtre"})

    CreateElement(SettingsPage, "Toggle", {
        Name = "🔲 Afficher le contour",
        CurrentValue = true,
        Callback = function(Value)
            MainStroke.Enabled = Value
        end
    })

    local MulticolorRef = CreateElement(SettingsPage, "Toggle", {
        Name = "🌈 Contour multicolore (RGB)",
        CurrentValue = false,
        Callback = function(Value)
            if Value then StartMulticolor() else StopMulticolor() end
        end
    })

    CreateElement(SettingsPage, "ColorPicker", {
        Name = "🖌️ Couleur du contour",
        Color = Color3.fromRGB(50,50,50),
        Callback = function(NewColor)
            StopMulticolor()
            MainStroke.Color = NewColor
            MulticolorRef:Set(false)
        end
    })

    CreateElement(SettingsPage, "Dropdown", {
        Name = "📏 Épaisseur du contour",
        Options = {"0.5", "1", "1.5 (défaut)", "2", "3", "4", "6"},
        CurrentOption = "1.5 (défaut)",
        Callback = function(Selected)
            local Val = tonumber(Selected:match("[%d%.]+"))
            if Val then MainStroke.Thickness = Val end
        end
    })

    -- ============================================================
    -- SECTION : Taille & Position
    -- ============================================================
    CreateElement(SettingsPage, "Section", {Text = "📐 Taille de la fenêtre"})

    CreateElement(SettingsPage, "Slider", {
        Name = "Largeur",
        Range = {300, 800},
        CurrentValue = TargetSize.X.Offset or 550,
        Callback = function(Value)
            TweenService:Create(MainFrame, TweenInfo.new(0.2), {
                Size = UDim2.new(0, Value, 0, MainFrame.AbsoluteSize.Y)
            }):Play()
        end
    })

    CreateElement(SettingsPage, "Slider", {
        Name = "Hauteur",
        Range = {200, 600},
        CurrentValue = TargetSize.Y.Offset or 350,
        Callback = function(Value)
            TweenService:Create(MainFrame, TweenInfo.new(0.2), {
                Size = UDim2.new(0, MainFrame.AbsoluteSize.X, 0, Value)
            }):Play()
        end
    })
end
