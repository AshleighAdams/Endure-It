
AddCSLuaFile("sh_bullets.lua")

include("sh_bullets.lua")

GM.Name 	= "Endure It"
GM.Author 	= "N/A"
GM.Email 	= "N/A"
GM.Website 	= "N/A"

function GM:Initialize()

	self.BaseClass.Initialize( self )
	
end


-- Make sure I'm last
local path = (GM or GAMEMODE).Folder .. "/gamemode/mapscripts/" .. game.GetMap() .. ".lua"
local files = file.Find(path, "MOD") or {}
if file.Exists(path, "MOD") then
	print("Including " .. path)
	include((GM or GAMEMODE).Folder:sub(11) .. "/gamemode/mapscripts/" .. game.GetMap() .. ".lua")
	if SERVER then
		AddCSLuaFile((GM or GAMEMODE).Folder:sub(11) .. "/gamemode/mapscripts/" .. game.GetMap() .. ".lua")
	end
else
	print("Map script does not exist: " ..  path)
end

