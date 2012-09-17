
AddCSLuaFile("sh_bullets.lua")
include("sh_bullets.lua")

AddCSLuaFile("sh_jetpack_controller.lua")
include("sh_jetpack_controller.lua")
include( "sh_salvation.lua" )


GM.Name 	= "Endure It"
GM.Author 	= "N/A"
GM.Email 	= "N/A"
GM.Website 	= "N/A"

function GM:Initialize()

	self.BaseClass.Initialize( self )
	
end

_R.Entity.OldEmitSound = _R.Entity.OldEmitSound or _R.Entity.EmitSound
if SERVER then util.AddNetworkString("EMIT_SND") end
function _R.Entity.EmitSound(self, ...)
	if SERVER then
		net.Start("EMIT_SND")
			net.WriteEntity(self)
			net.WriteTable({...})
		net.SendPAS(self:GetPos())
	else
		local sound_vel = Meters(340.29)
		local dist = (EyePos() - self:GetPos()):Length()
		if dist == 0 then
			dist = 0.0001 -- no div by 0
		end
		
		local t = dist / sound_vel
		local tbl = {...}
		
		if not IsFirstTimePredicted() then return end
		
		print(tbl[1] .. " will be emited in " .. tostring(t) .. " seconds")
		
		if t < 0.05 then -- Why bother?
			self:OldEmitSound(unpack(tbl))
		else
			timer.Simple(t, function()
				self:OldEmitSound(unpack(tbl))
			end)
		end
	end
end

net.Receive("EMIT_SND", function()
	local ent = net.ReadEntity()
	local tbl = net.ReadTable()
	if not ValidEntity(ent) then return end
	
	ent:EmitSound(unpack(tbl))
end)

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

