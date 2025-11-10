-- Tworzenie GUI
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local KillButton = Instance.new("TextButton")
local FlyButton = Instance.new("TextButton")
local MinimizeButton = Instance.new("TextButton")
local isMinimized = false

ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
Frame.Parent = ScreenGui
Frame.Size = UDim2.new(0, 200, 0, 150)
Frame.Position = UDim2.new(0.5, -100, 0.5, -75)
Frame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)

-- Przycisk Auto Zabijania
KillButton.Parent = Frame
KillButton.Size = UDim2.new(1, 0, 0, 50)
KillButton.Position = UDim2.new(0, 0, 0, 0)
KillButton.Text = "Włącz Auto Zabijanie"
KillButton.BackgroundColor3 = Color3.new(0.2, 0.8, 0.2)

-- Przycisk Auto Podlatywania
FlyButton.Parent = Frame
FlyButton.Size = UDim2.new(1, 0, 0, 50)
FlyButton.Position = UDim2.new(0, 0, 0, 50)
FlyButton.Text = "Włącz Auto Podlatywanie"
FlyButton.BackgroundColor3 = Color3.new(0.2, 0.8, 0.2)

-- Przycisk Minimalizacji
MinimizeButton.Parent = Frame
MinimizeButton.Size = UDim2.new(1, 0, 0, 50)
MinimizeButton.Position = UDim2.new(0, 0, 0, 100)
MinimizeButton.Text = "Minimalizuj"
MinimizeButton.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)

-- Zmienne do śledzenia stanu
local isKilling = false
local isFlying = false

-- Konfiguracja (możesz dostosować)
local killDistance = 1000 -- Zasięg namierzania
local flySpeed = 100 -- Prędkość podlatywania

-- Zmienne wewnętrzne
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Funkcja do znajdowania najbliższego potwora
local function findNearestMonster()
    local nearestMonster = nil
    local minDistance = math.huge

    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj.Humanoid.Health > 0 and obj.Name ~= character.Name then
            local monsterHumanoidRootPart = obj:FindFirstChild("HumanoidRootPart")
            if monsterHumanoidRootPart then
                local distance = (character.HumanoidRootPart.Position - monsterHumanoidRootPart.Position).Magnitude
                if distance < minDistance and distance <= killDistance then
                    minDistance = distance
                    nearestMonster = obj
                end
            end
        end
    end
    return nearestMonster
end

-- Funkcja do podlatywania do celu
local function flyToTarget(target)
    if not target or not target.Parent then return end
    local targetRootPart = target:FindFirstChild("HumanoidRootPart")
    if targetRootPart then
        local direction = (targetRootPart.Position - character.HumanoidRootPart.Position).Unit
        humanoid.Velocity = direction * flySpeed
    end
end

-- Funkcja do zabijania celu
local function killTarget(target)
    if not target or not target.Parent then return end
    local mobHumanoid = target:FindFirstChild("Humanoid")
    if mobHumanoid and mobHumanoid.Health > 0 then
        mobHumanoid.Health = 0
        print("Zabito moba: " .. target.Name)
    end
end

-- Główna pętla Auto Zabijania
local function autoKillLoop()
    while isKilling do
        local target = findNearestMonster()
        if target then
            killTarget(target)
            wait(0.5) -- Opóźnienie między zabiciami
        else
            wait(0.5) -- Czekaj, aż pojawi się nowy cel
        end
    end
end

-- Główna pętla Auto Podlatywania
local function autoFlyLoop()
    while isFlying do
        local target = findNearestMonster()
        if target then
            flyToTarget(target)
        else
            humanoid.Velocity = Vector3.new(0, 0, 0) -- Zatrzymaj ruch, gdy nie ma celu
        end
        wait(0.1) -- Krótkie opóźnienie w pętli
    end
end

-- Obsługa przycisku Auto Zabijania
KillButton.MouseButton1Click:Connect(function()
    isKilling = not isKilling
    KillButton.Text = isKilling and "Wyłącz Auto Zabijanie" or "Włącz Auto Zabijanie"
    if isKilling then
        coroutine.wrap(autoKillLoop)() -- Uruchom pętlę w coroutine
    end
end)

-- Obsługa przycisku Auto Podlatywania
FlyButton.MouseButton1Click:Connect(function()
    isFlying = not isFlying
    FlyButton.Text = isFlying and "Wyłącz Auto Podlatywanie" or "Włącz Auto Podlatywanie"
    if isFlying then
        coroutine.wrap(autoFlyLoop)() -- Uruchom pętlę w coroutine
    else
        humanoid.Velocity = Vector3.new(0, 0, 0) -- Zatrzymaj ruch, gdy wyłączone
    end
end)

-- Obsługa przycisku Minimalizacji
MinimizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    Frame.Visible = not isMinimized
    MinimizeButton.Text = isMinimized and "Przywróć" or "Minimalizuj"
end)

-- Funkcja do przesuwania GUI
local dragging
local dragInput
local mousePos
local startPos

Frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        startPos = Frame.Position
        mousePos = input.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

Frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local delta = input.Position - mousePos
        Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

print("Skrypt Auto Zabijania i Podlatywania z GUI załadowany.")
