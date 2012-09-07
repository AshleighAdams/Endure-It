AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')


function ENT:Initialize()
	local ent = self.Entity
	ent:SetModel(self.Model)
	ent:PhysicsInit(SOLID_VPHYSICS)
	ent:SetSolid(SOLID_VPHYSICS)
	ent:SetMoveType(MOVETYPE_VPHYSICS) 
	ent:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	ent:SetUseType(SIMPLE_USE)
	ent:SetAngles(Angle(0, math.random(0, 360), 0))
	local phys = ent:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
end

function ENT:OnDrop(pl)
	self:Equip(false, pl)
end

function ENT:Equip(ison, pl)
	pl = self.Owner or pl
	if not pl then return end
	
	if ison then
		pl:Give(self.Weapon_Class)
	else
		pl:StripWeapon(self.Weapon_Class)
	end
end
