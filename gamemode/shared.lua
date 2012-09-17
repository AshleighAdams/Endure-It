
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

OldWorldSound = OldWorldSound or WorldSound
if SERVER then util.AddNetworkString("WRLD_SND") end
function WorldSound(name, pos, ...)
	if SERVER then
		net.Start("WRLD_SND")
			net.WriteTable({name, pos, ...})
		net.SendPAS(pos)
	else
		local sound_vel = Meters(340.29)
		local dist = (EyePos() - pos):Length()
		
		local t = dist / sound_vel
		local tbl = {...}
		
		print(name .. " will be emited in " .. tostring(t) .. " seconds")
		
		if t < 0.05 then
			OldWorldSound(name, pos, ...)
		else
			timer.Simple(t, function()
				OldWorldSound(name, pos, unpack(tbl))
			end)
		end
	end
end

if CLIENT then
	net.Receive("WRLD_SND", function()
		local tbl = net.ReadTable()
		WorldSound(unpack(tbl))
	end)
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
		if not IsFirstTimePredicted() then return end
		
		local sound_vel = Meters(340.29)
		local dist = (EyePos() - self:GetPos()):Length()
		
		local t = dist / sound_vel
		local tbl = {...}
		
		print(tbl[1] .. " will be emited in " .. tostring(t) .. " seconds")
		
		if t < 0.002 then -- Why bother?
			self:OldEmitSound(...)
		else
			timer.Simple(t, function()
				local snd = tbl[1]
				local lvl = tbl[2]
				local pit = tbl[3]
				local pos = self:GetPos()
				
				if snd:StartWith("Weapon_") and snd != "Weapon_Pistol.Empty" then
					local direction = (EyePos() - pos):GetNormal()
					
					local e = 1.6
					local maxdist = 2500 -- Brute forced, max audible distance of bullet shots
					local fakedist = maxdist - math.pow( e, -(dist/maxdist) ) * maxdist
					
					print(dist, fakedist)
					pos = EyePos() + direction * fakedist
				end
				
				OldWorldSound(snd, pos, lvl, pit) -- Can be used to simulate loudness, just having a direction
				--self:OldEmitSound(unpack(tbl)) -- This isn't directional on the client...
			end)
		end
	end
end

if CLIENT then
	net.Receive("EMIT_SND", function()
		local ent = net.ReadEntity()
		local tbl = net.ReadTable()
		if not ValidEntity(ent) then return end
		
		ent:EmitSound(unpack(tbl))
	end)
end

if CLIENT then
	concommand.Add("debug_sounds_helper", function()
		hook.Add("ShouldDrawLocalPlayer", "asd", function() return true end)
		hook.Add("CalcView", "asd", function() return {origin = Vector(0), angles = (LocalPlayer():GetPos() - Vector(0)):Angle()} end)
	end)
	concommand.Add("debug_sounds_helper_del", function()
		hook.Remove("ShouldDrawLocalPlayer", "asd")
		hook.Remove("CalcView", "asd")
	end)
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

