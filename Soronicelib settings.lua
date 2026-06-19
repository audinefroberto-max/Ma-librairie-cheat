-- ================================================================
-- SoroniceLib_Settings.lua  (V2 — corrections demandées)
-- Module séparé : éléments de la page Paramètres ⚙️
-- Chargeable depuis GitHub, sans toucher à la librairie principale
--
-- CHANGEMENTS V2 :
--   - Suppression du toggle "Toujours visible"
--   - Contour : slider Épaisseur (0-10) + slider Transparence (0-100%)
--   - Contour : mode Dégradé (2 couleurs) en plus du Multicolore
--   - Mémorisation de la dernière couleur manuelle du contour
--   - Fenêtre : transparence jusqu'à 100% via slider (au lieu d'un
--     dropdown limité à 70%)
--   - Fenêtre : toggle Multicolore pour le FOND (séparé du contour)
--   - Notify() envoyée à chaque changement de réglage
-- ================================================================

return function(Ctx)
    local Settings       = Ctx.Settings
    local TweenService   = Ctx.TweenService
    local CreateElement  = Ctx.CreateElement
    local SettingsPage   = Ctx.SettingsPage
    local IsMobile        = Ctx.IsMobile
    local MainFrame       = Ctx.MainFrame
    local MainCorner      = Ctx.MainCorner
    local MainStroke      = Ctx.MainStroke
    local ForceShow        = Ctx.ForceShow
    local StartMulticolor  = Ctx.StartMulticolor   -- contour, défini dans Main
    local StopMulticolor   = Ctx.StopMulticolor    -- contour, défini dans Main
    local antiAfkActive    = Ctx.antiAfkActive
    local TargetSize       = Ctx.TargetSize
    local Notify           = Ctx.Notify            -- SoroniceLib:Notify exposé via Ctx

    local function SafeNotify(title, content)
        if Notify then
            Notify({ Title = title, Content = content, Duration = 3 })
        end
    end

    -- ============================================================
    -- SECTION : Paramètres de base
    -- ============================================================
    CreateElement(SettingsPage, "Toggle", {
        Name = "💤 Mode AFK (Anti-Kick)",
        CurrentValue = false,
        Callback = function(Value)
            antiAfkActive.value = Value
            SafeNotify("Anti-AFK", Value and "Activé : vous ne serez pas kické." or "Désactivé.")
        end
    })

    if not IsMobile then
        CreateElement(SettingsPage, "Keybind", {
            Name = "Touche pour Cacher/Montrer",
            Callback = function()
                SafeNotify("Réglages", "Touche mise à jour.")
            end
        })
    end

    -- ============================================================
    -- SECTION : Apparence de la fenêtre
    -- (le toggle "Toujours visible" a été retiré ici)
    -- ============================================================
    CreateElement(SettingsPage, "Section", {Text = "🎛️ Apparence de la fenêtre"})

    CreateElement(SettingsPage, "Toggle", {
        Name = "⬜ Coins carrés (non-arrondis)",
        CurrentValue = false,
        Callback = function(Value)
            local Target = Value and UDim.new(0,0) or UDim.new(0,10)
            TweenService:Create(MainCorner, TweenInfo.new(0.2), {CornerRadius = Target}):Play()
            SafeNotify("Apparence", Value and "Coins carrés activés." or "Coins arrondis activés.")
        end
    })

    -- Transparence de la fenêtre : slider 0 → 100% (100% = invisible)
    CreateElement(SettingsPage, "Slider", {
        Name = "🌫️ Transparence de la fenêtre",
        Range = {0, 100},
        CurrentValue = 20,
        Callback = function(Value)
            MainFrame.BackgroundTransparency = Value / 100
        end
    })

    -- Couleur de fond de la fenêtre
    local WindowBaseColor = Settings.ThemeColor
    local WindowColorPicker -- déclaré ici pour pouvoir le piloter depuis le toggle multicolore plus bas

    WindowColorPicker = CreateElement(SettingsPage, "ColorPicker", {
        Name = "🎨 Couleur de la fenêtre",
        Color = Settings.ThemeColor,
        Callback = function(NewColor)
            WindowBaseColor = NewColor
            MainFrame.BackgroundColor3 = NewColor
        end
    })

    -- Multicolore pour le FOND de la fenêtre (indépendant du contour)
    local WindowMulticolorToken = 0
    local function StopWindowMulticolor()
        WindowMulticolorToken = WindowMulticolorToken + 1
    end
    local function StartWindowMulticolor()
        WindowMulticolorToken = WindowMulticolorToken + 1
        local MyToken = WindowMulticolorToken
        task.spawn(function()
            local Hue = 0
            while WindowMulticolorToken == MyToken do
                Hue = (Hue + 0.006) % 1
                MainFrame.BackgroundColor3 = Color3.fromHSV(Hue, 1, 1)
                task.wait(0.03)
            end
        end)
    end

    CreateElement(SettingsPage, "Toggle", {
        Name = "🌈 Fond multicolore (RGB)",
        CurrentValue = false,
        Callback = function(Value)
            if Value then
                StartWindowMulticolor()
                SafeNotify("Apparence", "Fond multicolore activé.")
            else
                StopWindowMulticolor()
                MainFrame.BackgroundColor3 = WindowBaseColor
                if WindowColorPicker and WindowColorPicker.Set then
                    WindowColorPicker:Set(WindowBaseColor)
                end
                SafeNotify("Apparence", "Fond multicolore désactivé — couleur restaurée.")
            end
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
            SafeNotify("Contour", Value and "Contour affiché." or "Contour masqué.")
        end
    })

    -- Mémorise la dernière couleur choisie MANUELLEMENT pour le contour
    local LastManualStrokeColor = Color3.fromRGB(50,50,50)
    local StrokeColorPicker -- référence pour pouvoir resynchroniser l'affichage du picker

    -- Slider Épaisseur (remplace/complète le dropdown — réglage fin de 0 à 10)
    CreateElement(SettingsPage, "Slider", {
        Name = "📏 Épaisseur du contour",
        Range = {0, 10},
        CurrentValue = 2, -- correspond à 1.5px arrondi, valeur de base raisonnable
        Callback = function(Value)
            MainStroke.Thickness = Value
        end
    })

    -- Slider Transparence du contour (0 = visible, 100 = invisible)
    CreateElement(SettingsPage, "Slider", {
        Name = "🫥 Transparence du contour",
        Range = {0, 100},
        CurrentValue = 0,
        Callback = function(Value)
            MainStroke.Transparency = Value / 100
        end
    })

    StrokeColorPicker = CreateElement(SettingsPage, "ColorPicker", {
        Name = "🖌️ Couleur du contour",
        Color = Color3.fromRGB(50,50,50),
        Callback = function(NewColor)
            StopMulticolor()
            LastManualStrokeColor = NewColor
            MainStroke.Color = NewColor
        end
    })

    CreateElement(SettingsPage, "Toggle", {
        Name = "🌈 Contour multicolore (RGB)",
        CurrentValue = false,
        Callback = function(Value)
            if Value then
                StartMulticolor()
                SafeNotify("Contour", "Mode multicolore activé.")
            else
                StopMulticolor()
                MainStroke.Color = LastManualStrokeColor
                if StrokeColorPicker and StrokeColorPicker.Set then
                    StrokeColorPicker:Set(LastManualStrokeColor)
                end
                SafeNotify("Contour", "Multicolore désactivé — couleur d'origine restaurée.")
            end
        end
    })

    -- Mode Dégradé pour le contour : 2 couleurs, transition douce en boucle
    local GradientToken = 0
    local GradientColorA = Color3.fromRGB(0, 54, 203)
    local GradientColorB = Color3.fromRGB(255, 0, 150)

    local function StopGradient()
        GradientToken = GradientToken + 1
    end
    local function StartGradient()
        StopMulticolor() -- les 2 modes ne tournent pas en même temps
        GradientToken = GradientToken + 1
        local MyToken = GradientToken
        task.spawn(function()
            local t = 0
            local Direction = 1
            while GradientToken == MyToken do
                t = t + 0.01 * Direction
                if t >= 1 then t = 1; Direction = -1 end
                if t <= 0 then t = 0; Direction = 1 end
                MainStroke.Color = GradientColorA:Lerp(GradientColorB, t)
                task.wait(0.03)
            end
        end)
    end

    CreateElement(SettingsPage, "ColorPicker", {
        Name = "🌗 Dégradé — Couleur A",
        Color = GradientColorA,
        Callback = function(NewColor) GradientColorA = NewColor end
    })

    CreateElement(SettingsPage, "ColorPicker", {
        Name = "🌗 Dégradé — Couleur B",
        Color = GradientColorB,
        Callback = function(NewColor) GradientColorB = NewColor end
    })

    CreateElement(SettingsPage, "Toggle", {
        Name = "🌗 Mode dégradé (contour)",
        CurrentValue = false,
        Callback = function(Value)
            if Value then
                StartGradient()
                SafeNotify("Contour", "Mode dégradé activé.")
            else
                StopGradient()
                MainStroke.Color = LastManualStrokeColor
                if StrokeColorPicker and StrokeColorPicker.Set then
                    StrokeColorPicker:Set(LastManualStrokeColor)
                end
                SafeNotify("Contour", "Mode dégradé désactivé — couleur d'origine restaurée.")
            end
        end
    })

    -- ============================================================
    -- SECTION : Taille de la fenêtre
    -- Ces sliders pilotent MainFrame.Size ; comme Sidebar et
    -- ContentContainer sont désormais en Scale (cf. Main corrigé),
    -- tout le contenu suit automatiquement.
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
