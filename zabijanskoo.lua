-- Skrypt do automatycznego zabijania i podlatywania w Pixel Blade
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local isKilling = false
local isFlying = false

local function findNearestMonster()
    -- Logika do znajdowania najbliższego potwora
end

local function flyToTarget(target)
    -- Logika do podlatywania do celu
end

local function killTarget(target)
    -- Logika do zabijania celu
end

-- GUI i obsługa przycisków
-- ...

print("Skrypt załadowany.")
