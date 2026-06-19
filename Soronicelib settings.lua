-- ================================================================
-- SoroniceLib_Settings.lua  (V3 — ajout de la SAUVEGARDE PERSISTANTE)
-- Module séparé : éléments de la page Paramètres ⚙️
--
-- NOUVEAU EN V3 :
--   - Tous les réglages (apparence, contour, dégradé, multicolore,
--     transparence, taille de fenêtre, touche...) sont sauvegardés
--     dans un fichier "Soronice_Config.json" via writefile/readfile.
--   - Au lancement, ces réglages sont relus et réappliqués.
--   - EXCEPTION : le Mode AFK n'est JAMAIS sauvegardé. Il redémarre
--     toujours désactivé, comme demandé.
--
-- Nécessite un executor supportant writefile / readfile / isfile
-- (Synapse X, Script-Ware, KRNL, Fluxus, etc. — tous le supportent).
-- Si l'executor ne le supporte pas, la lib continue de fonctionner
-- normalement mais sans persistance (fallback silencieux).
-- ================================================================

return function(Ctx)
    local Settings       = Ctx.Settings
    local TweenService    = Ctx.TweenService
    local CreateElement   = Ctx.CreateElement
    local SettingsPage    = Ctx.SettingsPage
    local IsMobile         = Ctx.IsMobile
    local MainFrame        = Ctx.MainFrame
    local MainCorner       = Ctx.MainCorner
    local MainStroke       = Ctx.MainStroke
    local ForceShow         = Ctx.ForceShow
    local StartMulticolor   = Ctx.StartMulticolor
    local StopMulticolor    = Ctx.StopMulticolor
    local antiAfkActive     = Ctx.antiAfkActive
    local TargetSize        = Ctx.TargetSize
    local Notify            = Ctx.Notify
    local UserInputService  = Ctx.UserInputService

    local function SafeNotify(title, content)
        if Notify then
            Notify({ Title = title, Content = content, Duration = 3 })
        end
    end

    -- ============================================================
    -- SYSTÈME DE SAUVEGARDE
    -- ============================================================
    local SAVE_FILE = "Soronice_Config.json"
    local CanSave = (typeof(writefile) == "function" and typeof(readfile) == "function" and typeof(isfile) == "function")

    -- Valeurs par défaut (utilisées si rien n'est encore sauvegardé)
    local SaveData = {
        SquareCorners       = false,
        WindowTransparency  = 20,
        WindowColorR        = Settings.ThemeColor.R * 255,
        WindowColorG        = Settings.ThemeColor.G * 255,
        WindowColorB        = Settings.ThemeColor.B * 255,
        WindowMulticolor    = false,

        StrokeVisible       = true,
        StrokeThickness     = 2,
        StrokeTransparency  = 0,
        StrokeColorR        = 50,
        StrokeColorG        = 50,
        StrokeColorB        = 50,
        StrokeMulticolor    = false,
        StrokeGradient      = false,
        GradientColorAR     = 0,   GradientColorAG = 54,  GradientColorAB = 203,
        GradientColorBR     = 255, GradientColorBG = 0,   GradientColorBB = 150,

        WindowWidth         = TargetSize.X.Offset or 550,
        WindowHeight        = TargetSize.Y.Offset or 350,

        KeybindName         = nil, -- nil = on garde la touche par défaut (P)
    }

    -- Charge le fichier de sauvegarde s'il existe (écrase les valeurs par défaut)
    if CanSave and isfile(SAVE_FILE) then
        local ok, decoded = pcall(function()
            return game:GetService("HttpService"):JSONDecode(readfile(SAVE_FILE))
        end)
        if ok and type(decoded) == "table" then
            for key, value in pairs(decoded) do
                SaveData[key] = value
            end
        end
    end

    -- Écrit SaveData sur le disque (appelé après chaque changement de réglage)
    local function PersistSave()
        if not CanSave then return end
        pcall(function()
            local encoded = game:GetService("HttpService"):JSONEncode(SaveData)
            writefile(SAVE_FILE, encoded)
        end)
    end

    -- ============================================================
    -- SECTION : Paramètres de base
    -- L'AFK n'est JAMAIS lu ni écrit dans SaveData : il démarre
    -- toujours désactivé, comme demandé.
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
        local KeybindElement = CreateElement(SettingsPage, "Keybind", {
            Name = "Touche pour Cacher/Montrer",
            Callback = function()
                SaveData.KeybindName = UserInputService:GetStringForKeyCode(Settings.Keybind)
                PersistSave()
                SafeNotify("Réglages", "Touche mise à jour : " .. SaveData.KeybindName)
            end
        })
        -- Réapplique la touche sauvegardée au lancement
        if SaveData.KeybindName then
            local ok, keyCode = pcall(function() return Enum.KeyCode[SaveData.KeybindName] end)
            if ok and keyCode then
                Settings.Keybind = keyCode
                if KeybindElement and KeybindElement.Set then
                    KeybindElement:Set(SaveData.KeybindName)
                end
            end
        end
    end

    -- ============================================================
    -- SECTION : Apparence de la fenêtre
    -- ============================================================
    CreateElement(SettingsPage, "Section", {Text = "🎛️ Apparence de la fenêtre"})

    local CornersToggle = CreateElement(SettingsPage, "Toggle", {
        Name = "⬜ Coins carrés (non-arrondis)",
        CurrentValue = SaveData.SquareCorners,
        Callback = function(Value)
            local Target = Value and UDim.new(0,0) or UDim.new(0,10)
            TweenService:Create(MainCorner, TweenInfo.new(0.2), {CornerRadius = Target}):Play()
            SaveData.SquareCorners = Value
            PersistSave()
            SafeNotify("Apparence", Value and "Coins carrés activés." or "Coins arrondis activés.")
        end
    })
    -- Applique immédiatement la valeur sauvegardée (sans tween, direct)
    if SaveData.SquareCorners then
        MainCorner.CornerRadius = UDim.new(0,0)
    end

    -- Transparence de la fenêtre : slider 0 → 100% (100% = invisible)
    CreateElement(SettingsPage, "Slider", {
        Name = "🌫️ Transparence de la fenêtre",
        Range = {0, 100},
        CurrentValue = SaveData.WindowTransparency,
        Callback = function(Value)
            MainFrame.BackgroundTransparency = Value / 100
            SaveData.WindowTransparency = Value
            PersistSave()
        end
    })
    MainFrame.BackgroundTransparency = SaveData.WindowTransparency / 100

    -- Couleur de fond de la fenêtre
    local WindowBaseColor = Color3.fromRGB(SaveData.WindowColorR, SaveData.WindowColorG, SaveData.WindowColorB)
    local WindowColorPicker

    WindowColorPicker = CreateElement(SettingsPage, "ColorPicker", {
        Name = "🎨 Couleur de la fenêtre",
        Color = WindowBaseColor,
        Callback = function(NewColor)
            WindowBaseColor = NewColor
            MainFrame.BackgroundColor3 = NewColor
            SaveData.WindowColorR = NewColor.R * 255
            SaveData.WindowColorG = NewColor.G * 255
            SaveData.WindowColorB = NewColor.B * 255
            PersistSave()
        end
    })
    MainFrame.BackgroundColor3 = WindowBaseColor

    -- Multicolore pour le FOND de la fenêtre
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

    local WindowMulticolorToggle
    WindowMulticolorToggle = CreateElement(SettingsPage, "Toggle", {
        Name = "🌈 Fond multicolore (RGB)",
        CurrentValue = SaveData.WindowMulticolor,
        Callback = function(Value)
            SaveData.WindowMulticolor = Value
            PersistSave()
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
    if SaveData.WindowMulticolor then
        StartWindowMulticolor()
    end

    -- ============================================================
    -- SECTION : Contour de la fenêtre
    -- ============================================================
    CreateElement(SettingsPage, "Section", {Text = "🖼️ Contour de la fenêtre"})

    CreateElement(SettingsPage, "Toggle", {
        Name = "🔲 Afficher le contour",
        CurrentValue = SaveData.StrokeVisible,
        Callback = function(Value)
            MainStroke.Enabled = Value
            SaveData.StrokeVisible = Value
            PersistSave()
            SafeNotify("Contour", Value and "Contour affiché." or "Contour masqué.")
        end
    })
    MainStroke.Enabled = SaveData.StrokeVisible

    local LastManualStrokeColor = Color3.fromRGB(SaveData.StrokeColorR, SaveData.StrokeColorG, SaveData.StrokeColorB)
    local StrokeColorPicker

    CreateElement(SettingsPage, "Slider", {
        Name = "📏 Épaisseur du contour",
        Range = {0, 10},
        CurrentValue = SaveData.StrokeThickness,
        Callback = function(Value)
            MainStroke.Thickness = Value
            SaveData.StrokeThickness = Value
            PersistSave()
        end
    })
    MainStroke.Thickness = SaveData.StrokeThickness

    CreateElement(SettingsPage, "Slider", {
        Name = "🫥 Transparence du contour",
        Range = {0, 100},
        CurrentValue = SaveData.StrokeTransparency,
        Callback = function(Value)
            MainStroke.Transparency = Value / 100
            SaveData.StrokeTransparency = Value
            PersistSave()
        end
    })
    MainStroke.Transparency = SaveData.StrokeTransparency / 100

    StrokeColorPicker = CreateElement(SettingsPage, "ColorPicker", {
        Name = "🖌️ Couleur du contour",
        Color = LastManualStrokeColor,
        Callback = function(NewColor)
            StopMulticolor()
            LastManualStrokeColor = NewColor
            MainStroke.Color = NewColor
            SaveData.StrokeColorR = NewColor.R * 255
            SaveData.StrokeColorG = NewColor.G * 255
            SaveData.StrokeColorB = NewColor.B * 255
            PersistSave()
        end
    })
    MainStroke.Color = LastManualStrokeColor

    CreateElement(SettingsPage, "Toggle", {
        Name = "🌈 Contour multicolore (RGB)",
        CurrentValue = SaveData.StrokeMulticolor,
        Callback = function(Value)
            SaveData.StrokeMulticolor = Value
            if Value then SaveData.StrokeGradient = false end
            PersistSave()
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

    -- Mode Dégradé pour le contour
    local GradientToken = 0
    local GradientColorA = Color3.fromRGB(SaveData.GradientColorAR, SaveData.GradientColorAG, SaveData.GradientColorAB)
    local GradientColorB = Color3.fromRGB(SaveData.GradientColorBR, SaveData.GradientColorBG, SaveData.GradientColorBB)

    local function StopGradient()
        GradientToken = GradientToken + 1
    end
    local function StartGradient()
        StopMulticolor()
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
        Callback = function(NewColor)
            GradientColorA = NewColor
            SaveData.GradientColorAR = NewColor.R * 255
            SaveData.GradientColorAG = NewColor.G * 255
            SaveData.GradientColorAB = NewColor.B * 255
            PersistSave()
        end
    })

    CreateElement(SettingsPage, "ColorPicker", {
        Name = "🌗 Dégradé — Couleur B",
        Color = GradientColorB,
        Callback = function(NewColor)
            GradientColorB = NewColor
            SaveData.GradientColorBR = NewColor.R * 255
            SaveData.GradientColorBG = NewColor.G * 255
            SaveData.GradientColorBB = NewColor.B * 255
            PersistSave()
        end
    })

    CreateElement(SettingsPage, "Toggle", {
        Name = "🌗 Mode dégradé (contour)",
        CurrentValue = SaveData.StrokeGradient,
        Callback = function(Value)
            SaveData.StrokeGradient = Value
            if Value then SaveData.StrokeMulticolor = false end
            PersistSave()
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

    -- Réapplique au lancement le mode contour sauvegardé (un seul des deux actif)
    if SaveData.StrokeMulticolor then
        StartMulticolor()
    elseif SaveData.StrokeGradient then
        StartGradient()
    end

    -- ============================================================
    -- SECTION : Taille de la fenêtre
    -- ============================================================
    CreateElement(SettingsPage, "Section", {Text = "📐 Taille de la fenêtre"})

    CreateElement(SettingsPage, "Slider", {
        Name = "Largeur",
        Range = {300, 800},
        CurrentValue = SaveData.WindowWidth,
        Callback = function(Value)
            TweenService:Create(MainFrame, TweenInfo.new(0.2), {
                Size = UDim2.new(0, Value, 0, MainFrame.AbsoluteSize.Y)
            }):Play()
            SaveData.WindowWidth = Value
            PersistSave()
        end
    })

    CreateElement(SettingsPage, "Slider", {
        Name = "Hauteur",
        Range = {200, 600},
        CurrentValue = SaveData.WindowHeight,
        Callback = function(Value)
            TweenService:Create(MainFrame, TweenInfo.new(0.2), {
                Size = UDim2.new(0, MainFrame.AbsoluteSize.X, 0, Value)
            }):Play()
            SaveData.WindowHeight = Value
            PersistSave()
        end
    })

    -- Applique la taille sauvegardée dès l'ouverture (sans attendre que
    -- l'utilisateur touche aux sliders), avec un petit tween doux.
    if SaveData.WindowWidth ~= (TargetSize.X.Offset or 550) or SaveData.WindowHeight ~= (TargetSize.Y.Offset or 350) then
        task.delay(0.75, function() -- attend la fin de l'animation d'ouverture
            TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, SaveData.WindowWidth, 0, SaveData.WindowHeight)
            }):Play()
        end)
    end
end
