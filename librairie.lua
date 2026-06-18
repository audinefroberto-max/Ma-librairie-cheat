-- [[ SORONICE UI LIBRARY - V11.0 (NOUVEL ID RECHERCHE + TAILLE ORIGINALE + FIX DRAG) ]] --

local SoroniceLib = {}

-- [ SERVICES ] --
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService") 
local HttpService = game:GetService("HttpService")
local StatsService = game:GetService("Stats") 
local LocalPlayer = game.Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local VirtualUser = game:GetService("VirtualUser")
local StarterGui = game:GetService("StarterGui")

-- [ DÉTECTION MOBILE ] --
local IsMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled

-- [ CONFIGURATION GLOBALE ] --
local Settings = {
    Keybind = Enum.KeyCode.P,
    ThemeColor = Color3.fromRGB(20, 20, 20),
    AccentColor = Color3.fromRGB(0, 54, 203),
    TextColor = Color3.fromRGB(255, 255, 255),
    SubTextColor = Color3.fromRGB(180, 180, 180),
    StatsColor = Color3.fromRGB(35, 35, 35)
}

-- [ LISTE DES ÉLÉMENTS ACTIFS ] --
local ActiveToggles = {} 

-- [ SYSTÈME AFK ] --
local antiAfkActive = false
LocalPlayer.Idled:Connect(function()
    if antiAfkActive then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

-- [ DÉTECTION NOM DU JEU ] --
local GameNameText = "Détection..."
task.spawn(function()
    local success, info = pcall(function()
        return MarketplaceService:GetProductInfo(game.PlaceId)
    end)
    if success and info and info.Name then
        GameNameText = info.Name
    else
        GameNameText = "Jeu Inconnu"
    end
end)

-- [ FONCTION LOGIN ] --
local function SpawnLoginSystem(SettingsLogin)
    local Validated = false
    local RealPassword = SettingsLogin.Key or "1234"
    
    if SettingsLogin.GrabKeyFromSite == true then
        pcall(function()
            local content = game:HttpGet(SettingsLogin.Key)
            RealPassword = string.gsub(content, "%s+", "")
        end)
    end

    local LoginGui = Instance.new("ScreenGui")
    LoginGui.Name = "SoroniceLoginSystem"
    LoginGui.Parent = CoreGui
    LoginGui.ResetOnSpawn = false

    local BlurEffect = Instance.new("BlurEffect")
    BlurEffect.Parent = game.Lighting
    BlurEffect.Size = 24

    local BackgroundImage = Instance.new("ImageLabel")
    BackgroundImage.Parent = LoginGui
    BackgroundImage.AnchorPoint = Vector2.new(0.5, 0.5)
    BackgroundImage.Position = UDim2.new(0.5, 0, 0.5, 0)
    BackgroundImage.Size = UDim2.new(0, 500, 0, 350)
    BackgroundImage.Image = "rbxassetid://114617892791025"
    BackgroundImage.BackgroundTransparency = 1

    local TitleText = Instance.new("TextLabel")
    TitleText.Parent = BackgroundImage
    TitleText.BackgroundTransparency = 1
    TitleText.Position = UDim2.new(0.1, 0, 0.04, 0)
    TitleText.Size = UDim2.new(0.5, 0, 0.15, 0)
    TitleText.Font = Enum.Font.FredokaOne
    TitleText.Text = SettingsLogin.Title or "ACCÈS PREMIUM"
    TitleText.TextColor3 = Color3.new(1,1,1)
    TitleText.TextScaled = true
    TitleText.TextXAlignment = Enum.TextXAlignment.Left

    local CloseButton = Instance.new("TextButton")
    CloseButton.Parent = BackgroundImage
    CloseButton.BackgroundTransparency = 1
    CloseButton.Position = UDim2.new(0.92, 0, 0.14, 0)
    CloseButton.Size = UDim2.new(0.06, 0, 0.08, 0)
    CloseButton.Text = ""
    CloseButton.MouseButton1Click:Connect(function() 
        LoginGui:Destroy() 
        BlurEffect:Destroy() 
        script:Destroy() 
    end)

    local InputBg = Instance.new("ImageLabel")
    InputBg.Parent = BackgroundImage
    InputBg.BackgroundTransparency = 1
    InputBg.Position = UDim2.new(0.18, 0, 0.42, 0)
    InputBg.Size = UDim2.new(0.62, 0, 0.15, 0)
    InputBg.Image = "rbxassetid://75238927890132"

    local PasswordBox = Instance.new("TextBox")
    PasswordBox.Parent = InputBg
    PasswordBox.BackgroundTransparency = 1
    PasswordBox.Position = UDim2.new(0.15, 0, 0, 0)
    PasswordBox.Size = UDim2.new(0.8, 0, 1, 0)
    PasswordBox.Font = Enum.Font.SourceSansBold
    PasswordBox.Text = ""
    PasswordBox.PlaceholderText = "Entrez la clé ici..."
    PasswordBox.TextColor3 = Color3.new(1,1,1)
    PasswordBox.TextSize = 18
    PasswordBox.TextXAlignment = Enum.TextXAlignment.Left

    local ValidateBtn = Instance.new("TextButton")
    ValidateBtn.Parent = BackgroundImage
    ValidateBtn.BackgroundColor3 = Color3.fromRGB(167, 167, 167)
    ValidateBtn.Position = UDim2.new(0.5, 0, 0.68, 0)
    ValidateBtn.AnchorPoint = Vector2.new(0.5, 0)
    ValidateBtn.Size = UDim2.new(0.4, 0, 0.12, 0)
    ValidateBtn.Text = "VALIDER"
    ValidateBtn.Font = Enum.Font.SourceSansBold
    ValidateBtn.TextSize = 18
    Instance.new("UICorner", ValidateBtn).CornerRadius = UDim.new(0, 10)

    local LinkBtn = Instance.new("TextButton")
    LinkBtn.Parent = BackgroundImage
    LinkBtn.BackgroundColor3 = Color3.fromRGB(167, 167, 167)
    LinkBtn.Position = UDim2.new(0.5, 0, 0.85, 0)
    LinkBtn.AnchorPoint = Vector2.new(0.5, 0)
    LinkBtn.Size = UDim2.new(0.4, 0, 0.12, 0)
    LinkBtn.Text = SettingsLogin.LinkText or "Obtenir la clé"
    LinkBtn.Font = Enum.Font.SourceSans
    LinkBtn.TextSize = 14
    Instance.new("UICorner", LinkBtn).CornerRadius = UDim.new(0, 10)

    local function Verify()
        if PasswordBox.Text == RealPassword then 
            Validated = true 
            LoginGui:Destroy() 
            BlurEffect:Destroy()
        else 
            PasswordBox.Text = "" 
            PasswordBox.PlaceholderText = "Mot de passe INCORRECT !" 
            wait(1.5) 
            PasswordBox.PlaceholderText = "Entrez la clé ici..." 
        end
    end

    ValidateBtn.MouseButton1Click:Connect(Verify)
    LinkBtn.MouseButton1Click:Connect(function()
        if SettingsLogin.Link then 
            setclipboard(SettingsLogin.Link) 
            LinkBtn.Text = "Lien copié !" 
            wait(2) 
            LinkBtn.Text = SettingsLogin.LinkText or "Obtenir la clé" 
        end
    end)

    repeat wait() until Validated or not LoginGui.Parent
    if not Validated then 
        script:Destroy() 
        while true do wait(999) end 
    end
end

-- [ SYSTÈME NOTIFY ] --
function SoroniceLib:Notify(NotifyConfig)
    local Title = NotifyConfig.Title or "Notification"
    local Content = NotifyConfig.Content or "Message"
    local Duration = NotifyConfig.Duration or 6.5
    local ImageId = NotifyConfig.Image or 4483362458
    
    if ImageId == "rewind" then 
        ImageId = 4483362458 
    end

    local NotifGui = CoreGui:FindFirstChild("SoroniceNotifs")
    if not NotifGui then
        NotifGui = Instance.new("ScreenGui")
        NotifGui.Name = "SoroniceNotifs"
        NotifGui.Parent = CoreGui
        NotifGui.ResetOnSpawn = false
    end

    local Frame = Instance.new("Frame")
    Frame.Name = "NotificationFrame"
    Frame.Parent = NotifGui
    Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Frame.BorderSizePixel = 0
    Frame.Position = UDim2.new(1, 10, 0.8, -((#NotifGui:GetChildren() - 1) * 110))
    Frame.Size = UDim2.new(0, 280, 0, 100)
    Frame.BackgroundTransparency = 1 

    local RealFrame = Instance.new("Frame")
    RealFrame.Parent = Frame
    RealFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    RealFrame.Size = UDim2.new(1, 0, 1, 0)
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = RealFrame

    local Icon = Instance.new("ImageLabel")
    Icon.Parent = RealFrame
    Icon.BackgroundTransparency = 1
    Icon.Position = UDim2.new(0, 15, 0, 25)
    Icon.Size = UDim2.new(0, 50, 0, 50)
    Icon.Image = "rbxassetid://"..tostring(ImageId)

    local TitleLbl = Instance.new("TextLabel")
    TitleLbl.Parent = RealFrame
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Position = UDim2.new(0, 75, 0, 15)
    TitleLbl.Size = UDim2.new(0, 195, 0, 20)
    TitleLbl.Font = Enum.Font.GothamBold
    TitleLbl.Text = Title
    TitleLbl.TextColor3 = Color3.fromRGB(240, 240, 240)
    TitleLbl.TextSize = 15
    TitleLbl.TextXAlignment = Enum.TextXAlignment.Left

    local DescLbl = Instance.new("TextLabel")
    DescLbl.Parent = RealFrame
    DescLbl.BackgroundTransparency = 1
    DescLbl.Position = UDim2.new(0, 75, 0, 40)
    DescLbl.Size = UDim2.new(0, 195, 0, 45)
    DescLbl.Font = Enum.Font.Gotham
    DescLbl.Text = Content
    DescLbl.TextColor3 = Color3.fromRGB(180, 180, 180)
    DescLbl.TextSize = 13
    DescLbl.TextXAlignment = Enum.TextXAlignment.Left
    DescLbl.TextWrapped = true
    DescLbl.TextYAlignment = Enum.TextYAlignment.Top

    TweenService:Create(Frame, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(1, -300, 0.8, -((#NotifGui:GetChildren() - 1) * 110))}):Play()
    TweenService:Create(Frame, TweenInfo.new(0.5), {BackgroundTransparency = 0}):Play()

    task.spawn(function()
        wait(Duration)
        TweenService:Create(Frame, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Position = UDim2.new(1, 10, 0.8, -((#NotifGui:GetChildren() - 1) * 110))}):Play()
        wait(0.5)
        Frame:Destroy()
    end)
end

-- --- [ CRÉATION DE LA FENÊTRE ] ---

function SoroniceLib:CreateWindow(Config)
    if Config.KeySystem == true then 
        SpawnLoginSystem(Config.KeySettings or {}) 
    end

    if Config.TextColor then 
        Settings.TextColor = Config.TextColor 
    end

	local TitleName = Config.Name or "SORONICE HUB"
    local BrandLogoId = Config.BrandLogo or "" 
    local VersionTagText = Config.VersionTag or "" 
    local StatusIconsList = Config.StatusIcons or {}
    
    local ShowDevice = Config.ShowDevice or false
    local ShowPing = Config.ShowPing or false
    local ShowFPS = Config.ShowFPS or false

	if CoreGui:FindFirstChild("Soronice_V6") then CoreGui:FindFirstChild("Soronice_V6"):Destroy() end
    if CoreGui:FindFirstChild("Soronice_V7") then CoreGui:FindFirstChild("Soronice_V7"):Destroy() end
    if CoreGui:FindFirstChild("Soronice_V9") then CoreGui:FindFirstChild("Soronice_V9"):Destroy() end
    if CoreGui:FindFirstChild("Soronice_V11") then CoreGui:FindFirstChild("Soronice_V11"):Destroy() end

	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "Soronice_V11"
	ScreenGui.Parent = CoreGui
    ScreenGui.ResetOnSpawn = false

    -- ============================================================
    -- CHARGEMENT DES MODULES GITHUB
    -- Remplace les 3 URLs ci-dessous après avoir mis les fichiers
    -- sur GitHub. Format raw :
    --   https://raw.githubusercontent.com/COMPTE/REPO/main/FichierX.lua
    -- ============================================================
    local BUTTONS_URL  = "https://raw.githubusercontent.com/audinefroberto-max/Ma-librairie-cheat/refs/heads/main/Soronicelib%20buttons.lua"
    local ICONCARD_URL = "https://raw.githubusercontent.com/audinefroberto-max/Ma-librairie-cheat/refs/heads/main/Soronicelib%20iconcard.lua"
    local SETTINGS_URL = "https://raw.githubusercontent.com/audinefroberto-max/Ma-librairie-cheat/refs/heads/main/Soronicelib%20settings.lua"

    -- antiAfkActive passé par référence aux modules externes
    local antiAfkRef = { value = false }
    local AlwaysVisibleRef = { value = false }

    -- [APPLY LOCK FUNCTION]
    local function ApplyLock(TargetFrame, ElementConfig)
        if not ElementConfig then return false end
        
        local IsLocked = ElementConfig.Locked or false
        local LockReason = nil 

        if ElementConfig.BannedUsers and type(ElementConfig.BannedUsers) == "table" then
            for _, bannedId in pairs(ElementConfig.BannedUsers) do
                if LocalPlayer.UserId == bannedId then
                    IsLocked = true
                    LockReason = "Banned"
                    break
                end
            end
        end

        if not LockReason and ElementConfig.GamePassID then
            IsLocked = true 
            LockReason = "Gamepass"
        end

        if IsLocked then
            TargetFrame.ClipsDescendants = true 
            local LockOverlay = Instance.new("ImageButton")
            LockOverlay.Name = "LockOverlay"
            LockOverlay.Parent = TargetFrame
            LockOverlay.BackgroundTransparency = 1
            LockOverlay.Size = UDim2.new(1, 0, 1, 0)
            LockOverlay.Position = UDim2.new(0, 0, 0, 0)
            LockOverlay.ZIndex = 50 
            LockOverlay.Image = "rbxassetid://139868914964686" 
            LockOverlay.ImageTransparency = 0.53 
            
            LockOverlay.MouseButton1Click:Connect(function()
                if LockReason == "Gamepass" and ElementConfig.GamePassID then
                    MarketplaceService:PromptGamePassPurchase(LocalPlayer, ElementConfig.GamePassID)
                elseif LockReason == "Banned" then
                    game.StarterGui:SetCore("SendNotification", {Title = "Accès Refusé", Text = "Permission refusée.", Duration = 3})
                end
            end)
            return true 
        end
        return false 
    end

    -- [BOUTON MAISON MOBILE]
    local MobileOpenBtn = nil
    if IsMobile then
        MobileOpenBtn = Instance.new("ImageButton")
        MobileOpenBtn.Name = "MobileOpenButton"
        MobileOpenBtn.Parent = ScreenGui
        MobileOpenBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        MobileOpenBtn.BackgroundTransparency = 0.2
        MobileOpenBtn.Position = UDim2.new(0.1, 0, 0.1, 0) 
        MobileOpenBtn.Size = UDim2.new(0, 50, 0, 50)
        MobileOpenBtn.Image = Config.MobileImage or "rbxassetid://133601263847208"
        MobileOpenBtn.Visible = false 
        Instance.new("UICorner", MobileOpenBtn).CornerRadius = UDim.new(0, 12)
        local dragging_mob, dragInput_mob, dragStart_mob, startPos_mob
        
        MobileOpenBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging_mob = true
                dragStart_mob = input.Position
                startPos_mob = MobileOpenBtn.Position
            end
        end)
        
        MobileOpenBtn.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                dragInput_mob = input
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if input == dragInput_mob and dragging_mob then
                local delta = input.Position - dragStart_mob
                MobileOpenBtn.Position = UDim2.new(startPos_mob.X.Scale, startPos_mob.X.Offset + delta.X, startPos_mob.Y.Scale, startPos_mob.Y.Offset + delta.Y)
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging_mob = false
            end
        end)
    end

	-- [ MAIN FRAME : TAILLE D'ORIGINE - 550px STRICTE ]
	local MainFrame = Instance.new("Frame")
	MainFrame.Name = "MainFrame"
	MainFrame.Parent = ScreenGui
	MainFrame.BackgroundColor3 = Settings.ThemeColor
	MainFrame.BackgroundTransparency = 0.2
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    
    local TargetSize
    if IsMobile then
        MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0) 
        TargetSize = UDim2.new(0, 400, 0, 260) 
    else
	    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        TargetSize = UDim2.new(0, 550, 0, 350) -- [TAILLE D'ORIGINE]
    end
    
    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    MainFrame.ClipsDescendants = true 
    TweenService:Create(MainFrame, TweenInfo.new(0.7, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = TargetSize}):Play()
	
	local MainCorner = Instance.new("UICorner")
	MainCorner.CornerRadius = UDim.new(0, 10)
	MainCorner.Parent = MainFrame

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Parent = MainFrame
    MainStroke.Color = Color3.fromRGB(50, 50, 50)
    MainStroke.Thickness = 1.5
    MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    -- [ TOUJOURS VISIBLE (désactive le masquage clavier/bouton mobile) ] --
    local AlwaysVisible = false

    -- [ CONTOUR MULTICOLORE (RGB) ] --
    local MulticolorToken = 0
    local function StopMulticolor()
        MulticolorToken = MulticolorToken + 1
    end
    local function StartMulticolor()
        MulticolorToken = MulticolorToken + 1
        local MyToken = MulticolorToken
        task.spawn(function()
            local Hue = 0
            while MulticolorToken == MyToken do
                Hue = (Hue + 0.008) % 1
                MainStroke.Color = Color3.fromHSV(Hue, 1, 1)
                task.wait(0.03)
            end
        end)
    end

	local TopBar = Instance.new("Frame")
	TopBar.Name = "TopBar"
	TopBar.Parent = MainFrame
	TopBar.BackgroundTransparency = 1 
	TopBar.Size = UDim2.new(1, 0, 0, 40) 
    TopBar.Position = UDim2.new(0,0,0,0)
    TopBar.ZIndex = 10

    -- [ HEADER GAUCHE ]
    local LeftContainer = Instance.new("Frame")
    LeftContainer.Parent = TopBar
    LeftContainer.BackgroundTransparency = 1
    LeftContainer.Position = UDim2.new(0, 10, 0, 0)
    LeftContainer.Size = UDim2.new(0.4, 0, 1, 0)
    
    local LeftLayout = Instance.new("UIListLayout")
    LeftLayout.Parent = LeftContainer
    LeftLayout.FillDirection = Enum.FillDirection.Horizontal
    LeftLayout.SortOrder = Enum.SortOrder.LayoutOrder
    LeftLayout.Padding = UDim.new(0, 8)
    LeftLayout.VerticalAlignment = Enum.VerticalAlignment.Center

    if BrandLogoId ~= "" then
        local BrandLogo = Instance.new("ImageLabel")
        BrandLogo.Parent = LeftContainer
        BrandLogo.Size = UDim2.new(0, 32, 0, 32)
        BrandLogo.BackgroundTransparency = 1
        BrandLogo.Image = "rbxassetid://" .. BrandLogoId
        BrandLogo.LayoutOrder = 1
        BrandLogo.ZIndex = 100 
    end

    local TextVerticalContainer = Instance.new("Frame")
    TextVerticalContainer.Parent = LeftContainer
    TextVerticalContainer.BackgroundTransparency = 1
    TextVerticalContainer.Size = UDim2.new(0, 200, 0, 38)
    TextVerticalContainer.LayoutOrder = 2

	local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Parent = TextVerticalContainer
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.Size = UDim2.new(1, 0, 0.6, 0)
	TitleLabel.Font = Enum.Font.FredokaOne
	TitleLabel.Text = TitleName
	TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	TitleLabel.TextSize = 18
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local GameLabel = Instance.new("TextLabel")
    GameLabel.Parent = TextVerticalContainer
    GameLabel.BackgroundTransparency = 1
    GameLabel.Position = UDim2.new(0,0,0.6,0)
    GameLabel.Size = UDim2.new(1, 0, 0.4, 0)
    GameLabel.Font = Enum.Font.SourceSans
    GameLabel.Text = GameNameText 
    GameLabel.TextColor3 = Settings.AccentColor
    GameLabel.TextSize = 13
    GameLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    task.spawn(function() 
        while GameNameText == "Détection..." do wait(0.1) end
        GameLabel.Text = GameNameText 
    end)

    -- [ HEADER DROITE ]
    local RightContainer = Instance.new("Frame")
    RightContainer.Parent = TopBar
    RightContainer.BackgroundTransparency = 1
    RightContainer.AnchorPoint = Vector2.new(1, 0)
    RightContainer.Position = UDim2.new(1, -110, 0, 0) -- On laisse de la place pour les boutons
    RightContainer.Size = UDim2.new(0.5, 0, 1, 0)

    local RightLayout = Instance.new("UIListLayout")
    RightLayout.Parent = RightContainer
    RightLayout.FillDirection = Enum.FillDirection.Horizontal
    RightLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    RightLayout.SortOrder = Enum.SortOrder.LayoutOrder
    RightLayout.Padding = UDim.new(0, 6)
    RightLayout.VerticalAlignment = Enum.VerticalAlignment.Center

    local function CreateStatBadge(Text, Color, Order)
        local Badge = Instance.new("Frame")
        Badge.Parent = RightContainer
        Badge.BackgroundColor3 = Color or Settings.StatsColor
        Badge.Size = UDim2.new(0, 0, 0, 24)
        Badge.AutomaticSize = Enum.AutomaticSize.X
        Badge.LayoutOrder = Order
        Instance.new("UICorner", Badge).CornerRadius = UDim.new(0, 6)
        
        local Lbl = Instance.new("TextLabel")
        Lbl.Parent = Badge
        Lbl.BackgroundTransparency = 1
        Lbl.Size = UDim2.new(1, 0, 1, 0)
        Lbl.Font = Enum.Font.GothamBold
        Lbl.Text = "  " .. Text .. "  "
        Lbl.TextColor3 = Settings.TextColor
        Lbl.TextSize = 11
        return Lbl
    end

    if ShowDevice then
        local DeviceTxt = "PC"
        if UserInputService.TouchEnabled and not UserInputService.MouseEnabled then 
            DeviceTxt = "Mobile" 
        elseif UserInputService.GamepadEnabled then 
            DeviceTxt = "Console" 
        end
        CreateStatBadge(DeviceTxt, Color3.fromRGB(100, 60, 255), 1)
    end

    if VersionTagText ~= "" then
        CreateStatBadge(VersionTagText, Settings.AccentColor, 2)
    end

    if ShowFPS then
        local FpsLbl = CreateStatBadge("FPS: 60", Color3.fromRGB(255, 170, 0), 3)
        task.spawn(function()
            local lastTime = tick()
            local frameCount = 0
            RunService.RenderStepped:Connect(function()
                frameCount = frameCount + 1
                if tick() - lastTime >= 1 then
                    FpsLbl.Text = "FPS: " .. frameCount
                    frameCount = 0
                    lastTime = tick()
                end
            end)
        end)
    end

    if ShowPing then
        local PingLbl = CreateStatBadge("Ping: 0ms", Color3.fromRGB(0, 200, 80), 4)
        task.spawn(function()
            while true do
                if StatsService.Network:FindFirstChild("ServerStatsItem") then
                    local ping = math.floor(StatsService.Network.ServerStatsItem["Data Ping"]:GetValue())
                    PingLbl.Text = "Ping: " .. ping .. "ms"
                end
                wait(1)
            end
        end)
    end

    -- [ BOUTONS TOPBAR AVEC NOUVEL ID RECHERCHE ] --
    local ButtonsContainer = Instance.new("Frame")
    ButtonsContainer.Name = "ButtonsContainer"
    ButtonsContainer.Parent = TopBar
    ButtonsContainer.BackgroundTransparency = 1
    ButtonsContainer.AnchorPoint = Vector2.new(1, 0)
    ButtonsContainer.Position = UDim2.new(1, -10, 0, 0)
    ButtonsContainer.Size = UDim2.new(0, 100, 1, 0) -- Zone réservée aux boutons

    local SearchBtn = Instance.new("ImageButton")
    SearchBtn.Name = "SearchButton"
    SearchBtn.Parent = ButtonsContainer
    SearchBtn.BackgroundTransparency = 1
    SearchBtn.Position = UDim2.new(0, 0, 0, 5)
    SearchBtn.Size = UDim2.new(0, 30, 0, 30)
    SearchBtn.Image = "rbxassetid://84854196643814" -- [NOUVEL ID]
    SearchBtn.ImageColor3 = Color3.new(1,1,1) -- [BLANC]
    SearchBtn.ZIndex = 100 -- [FORCE AU PREMIER PLAN]

	local MinBtn = Instance.new("TextButton")
    MinBtn.Parent = ButtonsContainer
	MinBtn.Name = "Minimize"
	MinBtn.BackgroundTransparency = 1
	MinBtn.Position = UDim2.new(0, 35, 0, 5)
	MinBtn.Size = UDim2.new(0, 30, 0, 30)
	MinBtn.Font = Enum.Font.SourceSansBold
	MinBtn.Text = "-"
	MinBtn.TextColor3 = Settings.SubTextColor
	MinBtn.TextSize = 24
    
	local CloseBtn = Instance.new("TextButton")
    CloseBtn.Parent = ButtonsContainer
	CloseBtn.Name = "Close"
	CloseBtn.BackgroundTransparency = 1
	CloseBtn.Position = UDim2.new(0, 70, 0, 5)
	CloseBtn.Size = UDim2.new(0, 30, 0, 30)
	CloseBtn.Font = Enum.Font.SourceSansBold
	CloseBtn.Text = "X"
	CloseBtn.TextColor3 = Settings.SubTextColor
	CloseBtn.TextSize = 20

    -- [ DRAGGING GLOBAL (CORRECTION FINALE) ] --
	local dragging, dragInput, dragStart, startPos
    
    local function StartDrag(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            -- On vérifie si la souris est sur le container des boutons
            -- On utilise les coordonnées absolues pour être précis
            local mousePos = input.Position
            local btnPos = ButtonsContainer.AbsolutePosition
            local btnSize = ButtonsContainer.AbsoluteSize
            
            local isOverButtons = (mousePos.X >= btnPos.X and mousePos.X <= btnPos.X + btnSize.X and mousePos.Y >= btnPos.Y and mousePos.Y <= btnPos.Y + btnSize.Y)
            
            if not isOverButtons then
                dragging = true
                dragStart = input.Position
                startPos = MainFrame.Position
            end
        end
    end

	TopBar.InputBegan:Connect(StartDrag)
	TopBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
	UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
	UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

	local IsHidden = false
    local isAnimating = false

    local function ToggleVisibility()
        if AlwaysVisible then return end
        if isAnimating then return end
        isAnimating = true
        IsHidden = not IsHidden
        
        if IsHidden then
            local closeT = TweenService:Create(MainFrame, TweenInfo.new(0.7, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0,0,0,0)})
            closeT:Play()
            closeT.Completed:Wait()
            MainFrame.Visible = false
            if IsMobile and MobileOpenBtn then 
                MobileOpenBtn.Visible = true 
            end
        else
            if IsMobile and MobileOpenBtn then 
                MobileOpenBtn.Visible = false 
            end
            MainFrame.Visible = true
            local openT = TweenService:Create(MainFrame, TweenInfo.new(0.7, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = TargetSize})
            openT:Play()
            openT.Completed:Wait()
        end
        isAnimating = false
    end

    -- Réaffiche immédiatement la fenêtre si elle était cachée (utilisé par le mode "Toujours visible")
    local function ForceShow()
        if not IsHidden then return end
        IsHidden = false
        if IsMobile and MobileOpenBtn then 
            MobileOpenBtn.Visible = false 
        end
        MainFrame.Visible = true
        TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = TargetSize}):Play()
    end

	MinBtn.MouseButton1Click:Connect(ToggleVisibility)
    if IsMobile and MobileOpenBtn then 
        MobileOpenBtn.MouseButton1Click:Connect(ToggleVisibility) 
    end
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not IsMobile and not gameProcessed and input.KeyCode == Settings.Keybind then 
            ToggleVisibility() 
        end
    end)

	CloseBtn.MouseButton1Click:Connect(function() 
        for _, ToggleData in pairs(ActiveToggles) do
            if ToggleData.Callback then
                ToggleData.Callback(false) 
            end
        end
        local CloseTween = TweenService:Create(MainFrame, TweenInfo.new(0.7, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Size = UDim2.new(0,0,0,0)})
        CloseTween:Play()
        CloseTween.Completed:Wait() 
        ScreenGui:Destroy() 
    end)

    -- [ BARRE DE RECHERCHE ] --
    local SearchBarFrame = Instance.new("Frame")
    SearchBarFrame.Name = "SearchBar"
    SearchBarFrame.Parent = MainFrame
    SearchBarFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    SearchBarFrame.BorderSizePixel = 0
    SearchBarFrame.Position = UDim2.new(0, 80, 0, 45)
    SearchBarFrame.Size = UDim2.new(1, -90, 0, 0)
    SearchBarFrame.Visible = false
    SearchBarFrame.ClipsDescendants = true
    SearchBarFrame.ZIndex = 5
    Instance.new("UICorner", SearchBarFrame).CornerRadius = UDim.new(0, 6)

    local SearchInput = Instance.new("TextBox")
    SearchInput.Parent = SearchBarFrame
    SearchInput.BackgroundTransparency = 1
    SearchInput.Position = UDim2.new(0, 10, 0, 0)
    SearchInput.Size = UDim2.new(1, -20, 1, 0)
    SearchInput.Font = Enum.Font.SourceSans
    SearchInput.PlaceholderText = "Rechercher..."
    SearchInput.Text = ""
    SearchInput.TextColor3 = Settings.TextColor
    SearchInput.TextSize = 16
    SearchInput.TextXAlignment = Enum.TextXAlignment.Left
    SearchInput.ZIndex = 6

    local SearchOpen = false
    local isSearchAnimating = false

    local function ToggleSearch()
        if isSearchAnimating then return end
        isSearchAnimating = true
        SearchOpen = not SearchOpen

        if SearchOpen then
            SearchBarFrame.Visible = true
            TweenService:Create(SearchBarFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, -90, 0, 30)}):Play()
            SearchInput:CaptureFocus()
        else
            local closeTween = TweenService:Create(SearchBarFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(1, -90, 0, 0)})
            closeTween:Play()
            closeTween.Completed:Wait()
            SearchBarFrame.Visible = false
            SearchInput.Text = "" 
        end
        isSearchAnimating = false
    end
    SearchBtn.MouseButton1Click:Connect(ToggleSearch)

    UserInputService.InputBegan:Connect(function(input)
        if SearchOpen and input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mousePos = UserInputService:GetMouseLocation()
            local sAbs = SearchBarFrame.AbsolutePosition
            local sSize = SearchBarFrame.AbsoluteSize
            local bAbs = SearchBtn.AbsolutePosition
            local bSize = SearchBtn.AbsoluteSize

            if not (mousePos.X >= sAbs.X and mousePos.X <= sAbs.X + sSize.X and mousePos.Y >= sAbs.Y - 36 and mousePos.Y <= sAbs.Y + sSize.Y) then
                 if not (mousePos.X >= bAbs.X and mousePos.X <= bAbs.X + bSize.X and mousePos.Y >= bAbs.Y - 36 and mousePos.Y <= bAbs.Y + bSize.Y) then
                    ToggleSearch()
                end
            end
        end
    end)

	local Sidebar = Instance.new("Frame")
	Sidebar.Parent = MainFrame
	Sidebar.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
	Sidebar.BackgroundTransparency = 0.5
	Sidebar.Position = UDim2.new(0, 10, 0, 50)
	Sidebar.Size = UDim2.new(0, 60, 1, -60) 
    Sidebar.ClipsDescendants = true 
	local SidebarCorner = Instance.new("UICorner")
	SidebarCorner.CornerRadius = UDim.new(0, 8)
	SidebarCorner.Parent = Sidebar
    
    local SidebarScroll = Instance.new("ScrollingFrame")
    SidebarScroll.Parent = Sidebar
    SidebarScroll.BackgroundTransparency = 1
    SidebarScroll.Position = UDim2.new(0, 0, 0, 0)
    SidebarScroll.Size = UDim2.new(1, 0, 1, -50) 
    SidebarScroll.ScrollBarThickness = 0
    SidebarScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    
	local SidebarLayout = Instance.new("UIListLayout")
	SidebarLayout.Parent = SidebarScroll
	SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
	SidebarLayout.Padding = UDim.new(0, 10)
	SidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    SidebarLayout.VerticalAlignment = Enum.VerticalAlignment.Top

	local ContentContainer = Instance.new("Frame")
	ContentContainer.Parent = MainFrame
	ContentContainer.BackgroundTransparency = 1
	ContentContainer.Position = UDim2.new(0, 80, 0, 50)
    if IsMobile then
        ContentContainer.Size = UDim2.new(0, 310, 0, 200)
    else
	    ContentContainer.Size = UDim2.new(0, 460, 0, 290)
    end
    ContentContainer.ClipsDescendants = true 

    -- [ FILTRAGE ] --
    local function FilterItems(searchText)
        searchText = string.lower(searchText)
        for _, page in pairs(ContentContainer:GetChildren()) do
            if page:IsA("ScrollingFrame") and page.Visible then
                for _, element in pairs(page:GetChildren()) do
                    if element:IsA("Frame") and element:GetAttribute("SearchName") then
                        local itemName = element:GetAttribute("SearchName")
                        if string.find(itemName, searchText) then
                            element.Visible = true
                        else
                            element.Visible = false
                        end
                    elseif element.Name == "IconCardGrid" then
                        -- Les IconCard vivent une étage plus bas (dans leur grille), on les filtre aussi
                        for _, card in pairs(element:GetChildren()) do
                            if card:IsA("Frame") and card:GetAttribute("SearchName") then
                                local cardName = card:GetAttribute("SearchName")
                                if string.find(cardName, searchText) then
                                    card.Visible = true
                                else
                                    card.Visible = false
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
        FilterItems(SearchInput.Text)
    end)

	local SettingsBtn = Instance.new("TextButton")
	SettingsBtn.Name = "Settings_Btn"
	SettingsBtn.Parent = Sidebar 
	SettingsBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	SettingsBtn.BackgroundTransparency = 0.5
    SettingsBtn.Position = UDim2.new(0.5, -22, 1, -50) 
    SettingsBtn.AnchorPoint = Vector2.new(0, 0) 
	SettingsBtn.Size = UDim2.new(0, 45, 0, 45)
	SettingsBtn.Text = ""
    SettingsBtn.ZIndex = 2 
    Instance.new("UICorner", SettingsBtn).CornerRadius = UDim.new(0, 8)
	local SettingsIcon = Instance.new("ImageLabel")
	SettingsIcon.Parent = SettingsBtn
	SettingsIcon.BackgroundTransparency = 1
	SettingsIcon.Position = UDim2.new(0, 5, 0, 5)
	SettingsIcon.Size = UDim2.new(0, 35, 0, 35)
	SettingsIcon.Image = "rbxassetid://74182569229556"
    SettingsIcon.ImageColor3 = Settings.SubTextColor

    local SettingsPage = Instance.new("ScrollingFrame")
    SettingsPage.Name = "Settings_Page"
    SettingsPage.Parent = ContentContainer
    SettingsPage.BackgroundTransparency = 1
    SettingsPage.Size = UDim2.new(1, 0, 1, 0)
    SettingsPage.ScrollBarThickness = 2 -- Scrollbar fine
    SettingsPage.Visible = false 
    SettingsPage.AutomaticCanvasSize = Enum.AutomaticSize.Y
    SettingsPage.CanvasSize = UDim2.new(0,0,0,0)

    local SettingsLayout = Instance.new("UIListLayout")
    SettingsLayout.Parent = SettingsPage
    SettingsLayout.Padding = UDim.new(0, 8)
    SettingsLayout.SortOrder = Enum.SortOrder.LayoutOrder

    SettingsBtn.MouseButton1Click:Connect(function()
        if SearchOpen then ToggleSearch() end
        for _, v in pairs(ContentContainer:GetChildren()) do v.Visible = false end
        SettingsPage.Visible = true
        for _, btn in pairs(SidebarScroll:GetChildren()) do
            if btn:IsA("TextButton") then TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0,0,0)}):Play() end
        end
        TweenService:Create(SettingsBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40,40,40)}):Play()
    end)

    -- ============================================================
    -- CONTEXTE PARTAGÉ pour les modules GitHub
    -- Toutes les variables locales nécessaires sont disponibles ici
    -- ============================================================
    ModuleCtx = {
        Settings        = Settings,
        TweenService    = TweenService,
        UserInputService = UserInputService,
        ApplyLock       = ApplyLock,
        ActiveToggles   = ActiveToggles,
        -- Settings page
        SettingsPage    = SettingsPage,
        IsMobile        = IsMobile,
        MainFrame       = MainFrame,
        MainCorner      = MainCorner,
        MainStroke      = MainStroke,
        AlwaysVisible   = AlwaysVisibleRef,
        antiAfkActive   = antiAfkRef,
        TargetSize      = TargetSize,
        ForceShow       = ForceShow,
        StartMulticolor = StartMulticolor,
        StopMulticolor  = StopMulticolor,
        CreateElement   = nil, -- rempli après la définition de CreateElement (ci-dessous)
    }

	local WindowFunctions = {}
	local FirstTab = true

    -- [ FONCTIONS DE CRÉATION D'ÉLÉMENTS ] --
    -- Construit le contexte partagé pour tous les modules
    local ModuleCtx  -- défini après MainStroke (plus bas), mais utilisé dans les modules
    local ButtonRegistry  -- rempli après la définition du contexte
    local IconCardFn

    -- Proxy de création : cherche dans ButtonRegistry, puis dans IconCardFn
    local function CreateElement(Page, Type, Config)
        Config = Config or {}
        -- Chargement paresseux du registre (une seule fois)
        if not ButtonRegistry then
            local ok, res = pcall(function()
                return loadstring(game:HttpGet(BUTTONS_URL))()(ModuleCtx)
            end)
            if ok then
                ButtonRegistry = res
            else
                -- Fallback intégré si GitHub inaccessible
                ButtonRegistry = {}
                warn("[SoroniceLib] Impossible de charger Buttons depuis GitHub : " .. tostring(res))
            end
        end
        if not IconCardFn then
            local ok, res = pcall(function()
                return loadstring(game:HttpGet(ICONCARD_URL))()(ModuleCtx)
            end)
            if ok then
                IconCardFn = res
            else
                IconCardFn = function() return {} end
                warn("[SoroniceLib] Impossible de charger IconCard depuis GitHub : " .. tostring(res))
            end
        end

        local ReturnedTable = {}
        if Type == "IconCard" then
            ReturnedTable = IconCardFn(Page, Config) or {}
        elseif ButtonRegistry[Type] then
            ReturnedTable = ButtonRegistry[Type](Page, Config) or {}
        end
        return ReturnedTable
    end
    -- Rend CreateElement disponible au module Settings
    ModuleCtx.CreateElement = CreateElement

    -- ============================================================
    -- CHARGEMENT DU MODULE SETTINGS depuis GitHub
    -- Si inaccessible, fallback sur le bloc Settings intégré
    -- ============================================================
    do
        local ok, SettingsSetup = pcall(function()
            return loadstring(game:HttpGet(SETTINGS_URL))()(ModuleCtx)
        end)
        if not ok then
            warn("[SoroniceLib] Module Settings GitHub inaccessible — fallback intégré : " .. tostring(SettingsSetup))
            -- Fallback : éléments Settings directement ici
            CreateElement(SettingsPage, "Toggle", {
                Name = "💤 Mode AFK (Anti-Kick)",
                CurrentValue = false,
                Callback = function(Value)
                    antiAfkRef.value = Value
                    if Value then game.StarterGui:SetCore("SendNotification", {Title="Anti-AFK", Text="Activé.", Duration=3}) end
                end
            })
            if not IsMobile then
                CreateElement(SettingsPage, "Keybind", {Name = "Touche pour Cacher/Montrer", Callback = function() end})
            end
        end
    end



	function WindowFunctions:CreateTab(TabName, TabImageId, LockConfig) 
		local TabBtn = Instance.new("TextButton")
        TabBtn.Parent = SidebarScroll
		TabBtn.BackgroundColor3 = Color3.new(0,0,0)
        TabBtn.BackgroundTransparency=0.5
        TabBtn.Size=UDim2.new(0,45,0,45)
        TabBtn.Text=""
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0,8)
		if TabImageId and TabImageId ~= 0 then
			local Icon = Instance.new("ImageLabel")
            Icon.Parent = TabBtn
            Icon.BackgroundTransparency=1
            Icon.Position=UDim2.new(0,5,0,5)
            Icon.Size=UDim2.new(0,35,0,35)
            Icon.Image="rbxassetid://"..tostring(TabImageId)
		else
			TabBtn.Text = string.sub(TabName, 1, 1)
            TabBtn.TextColor3 = Color3.new(0.8,0.8,0.8)
            TabBtn.TextSize=20
            TabBtn.Font=Enum.Font.SourceSansBold
		end

        local IsButtonLocked = false
        if LockConfig and LockConfig.Locked then
             if LockConfig.LockMode ~= "Frame" then 
                 IsButtonLocked = ApplyLock(TabBtn, LockConfig) 
             end
        end

		local Page = Instance.new("ScrollingFrame")
        Page.Parent = ContentContainer
        Page.BackgroundTransparency=1
        Page.Size=UDim2.new(1,0,1,0)
        Page.ScrollBarThickness=6
        Page.Visible=FirstTab
        Page.AutomaticCanvasSize = Enum.AutomaticSize.Y 
        Page.CanvasSize = UDim2.new(0,0,0,0)
        Page.VerticalScrollBarInset = Enum.ScrollBarInset.None

        local PageLayout = Instance.new("UIListLayout")
        PageLayout.Parent = Page
        PageLayout.Padding = UDim.new(0,8)
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder

        if LockConfig and LockConfig.Locked and LockConfig.LockMode == "Frame" then 
            ApplyLock(Page, LockConfig) 
        end

		TabBtn.MouseButton1Click:Connect(function()
            if IsButtonLocked then return end
            if SearchOpen then ToggleSearch() end
			for _,v in pairs(ContentContainer:GetChildren()) do v.Visible=false end
			Page.Visible=true
            TweenService:Create(SettingsBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0,0,0)}):Play()
		end)
		FirstTab = false

		local TabFunctions = {}
		function TabFunctions:CreateButton(Config) return CreateElement(Page, "Button", Config) end
        function TabFunctions:CreateToggle(Config) return CreateElement(Page, "Toggle", Config) end
        function TabFunctions:CreateColorPicker(Config) return CreateElement(Page, "ColorPicker", Config) end 
        function TabFunctions:CreateSection(Text) return CreateElement(Page, "Section", {Text=Text}) end
        function TabFunctions:CreateLabel(Text) return CreateElement(Page, "Label", {Text=Text}) end
        function TabFunctions:CreateDropdown(Config) return CreateElement(Page, "Dropdown", Config) end
        function TabFunctions:CreateInput(Config) return CreateElement(Page, "Input", Config) end 
        function TabFunctions:CreateParagraph(Config) return CreateElement(Page, "Paragraph", Config) end 
        function TabFunctions:CreateDivider() return CreateElement(Page, "Divider", {}) end 
        function TabFunctions:CreateIconCard(Config) return CreateElement(Page, "IconCard", Config) end 
        
        function TabFunctions:CreateSlider(Config)
             local SliderFrame = Instance.new("Frame")
             SliderFrame.Parent = Page
             SliderFrame.BackgroundTransparency=1
             SliderFrame.Size=UDim2.new(1,-10,0,50)
             SliderFrame:SetAttribute("SearchName", string.lower(Config.Name))
             
             local Locked = ApplyLock(SliderFrame, Config)
             local Label = Instance.new("TextLabel")
             Label.Parent = SliderFrame
             Label.BackgroundTransparency=1
             Label.Position=UDim2.new(0,10,0,0)
             Label.Size=UDim2.new(1,0,0,20)
             Label.Text=Config.Name
             Label.TextColor3=Color3.new(1,1,1)
             Label.TextXAlignment=Enum.TextXAlignment.Left
             Label.Font=Enum.Font.SourceSans
             Label.TextSize=16

             local ValLabel = Instance.new("TextLabel")
             ValLabel.Parent = SliderFrame
             ValLabel.BackgroundTransparency=1
             ValLabel.Position=UDim2.new(1,-60,0,0)
             ValLabel.Size=UDim2.new(0,50,0,20)
             ValLabel.TextColor3=Color3.new(1,1,1)
             ValLabel.TextXAlignment=Enum.TextXAlignment.Right
             ValLabel.Font=Enum.Font.SourceSansBold
             ValLabel.TextSize=16

             local Bar = Instance.new("Frame")
             Bar.Parent = SliderFrame
             Bar.BackgroundColor3=Color3.fromRGB(10,10,10)
             Bar.Position=UDim2.new(0,10,0,25)
             Bar.Size=UDim2.new(1,-20,0,10)
             Instance.new("UICorner", Bar).CornerRadius=UDim.new(1,0)

             local Knob = Instance.new("TextButton")
             Knob.Parent = Bar
             Knob.BackgroundColor3=Settings.AccentColor
             Knob.Size=UDim2.new(0,20,0,20)
             Knob.AnchorPoint=Vector2.new(0.5,0.5)
             Knob.Position=UDim2.new(0,0,0.5,0)
             Knob.Text=""
             Instance.new("UICorner", Knob).CornerRadius=UDim.new(1,0)

             local Min, Max = Config.Range[1] or 0, Config.Range[2] or 100
             local Default = Config.CurrentValue or Min
             ValLabel.Text = tostring(Default).."%"
             Knob.Position = UDim2.new((Default-Min)/(Max-Min), 0, 0.5, 0)
             
             if not Locked then
                 local dragging = false
                 Knob.InputBegan:Connect(function(input) 
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true end 
                 end)
                 UserInputService.InputEnded:Connect(function(input) 
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end 
                 end)
                 UserInputService.InputChanged:Connect(function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        local Percent = math.clamp((input.Position.X - Bar.AbsolutePosition.X)/Bar.AbsoluteSize.X, 0, 1)
                        Knob.Position = UDim2.new(Percent, 0, 0.5, 0)
                        local Val = math.floor(Min + (Max-Min)*Percent)
                        ValLabel.Text = tostring(Val).."%"
                        if Config.Callback then Config.Callback(Val) end
                    end
                 end)
            else
                Knob.Active = false 
            end
            
            local SliderObj = {}
            function SliderObj:Set(Value)
                 local Percent = (Value - Min) / (Max - Min)
                 Knob.Position = UDim2.new(Percent, 0, 0.5, 0)
                 ValLabel.Text = tostring(Value).."%"
                 if Config.Callback then Config.Callback(Value) end
            end
            return SliderObj
        end
		return TabFunctions
	end
	return WindowFunctions
end
return SoroniceLib
