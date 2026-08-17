--(Web đây nha xem đi: https://github.com/toilalode/scripttutao/blob/main/loader.lua)

--[[

  ____            _       _  _____     _____           
 / ___|  ___ _ __(_)_ __ | ||_   _|   |_   _|_ _  ___  
 \___ \ / __| '__| | '_ \| __|| || | | || |/ _` |/ _ \ 
  ___) | (__| |  | | |_) | |_ | || |_| || | (_| | (_) |
 |____/ \___|_|  |_| .__/ \__||_| \__,_||_|\__,_|\___/ 
                   |_|                                 

]]--
-- ============================================
-- BLOX FRUITS SCRIPT v2.0 COMPLETE - LOADER
-- Based on Uifluent + Enhanced Features
-- ============================================

print("=" .. string.rep("=", 50) .. "=")
print(" Blox Fruits Script")
print(" Toilalode")
print("=" .. string.rep("=", 50) .. "=")

-- Check if in game
local Players = game:GetService("Players")
local player = Players.LocalPlayer

if not player then
    warn("[-] Player not found! Please wait for the game to load...")
    return
end

print("[+] Player found: " .. player.Name)

-- Wait for character
if not player.Character then
    print("[*] Waiting for character to spawn...")
    player.CharacterAdded:Wait()
end

print("[+] Character loaded!")

-- Load main script
local success, result = pcall(function()
    -- Try to load from file
    local scriptPath = debug.getinfo(1).source:match("@(.+)$") or ""
    local scriptDir = scriptPath:match("(.+)/") or ""
    
    if scriptDir ~= "" then
        print("[+] Loading from: " .. scriptDir)
        return loadfile(scriptDir .. "/ItemFactory.lua")()
    else
        print("[-] Could not determine script directory")
        print("[*] Please load ItemFactory.lua directly")
        return false
    end
end)

if success then
    print("[+] Script loaded successfully!")
else
    warn("[-] Error loading script: " .. tostring(result))
end

print("=" .. string.rep("=", 50) .. "=")
