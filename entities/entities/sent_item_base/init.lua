AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')


function ENT:SpawnFunction(ply, tr)
	if (!tr.Hit) then 
		return
	end
	local spawn = tr.HitPos + Vector(0, 0, 15)
	local ent = ents.Create("sent_item_base")
	ent:SetPos(spawn)
	ent:Spawn()
	return ent
end


function ENT:Initialize()
	local ent = self.Entity
	ent:SetModel("models/Combine_turrets/ground_turret.mdl")
	ent:PhysicsInit(SOLID_VPHYSICS)
	ent:SetSolid(SOLID_VPHYSICS)
	ent:SetMoveType(MOVETYPE_VPHYSICS) 
	ent:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	local phys = ent:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
end

function ENT:OnTakeDamage(dmginfo)
	self.Entity:TakePhysicsDamage(dmginfo)
end

function ENT:Think()
	
end

function ENT:RestoreState(state)
end

function ENT:SendState()
	net.Start(item_state_update)
		net.WriteEntity(self)
		net.WriteTable(self:GetState())
	net.Broadcast()
end

function ENT:GetState()
	return {}
end

function ENT:Drop(pl)
	self.Owner = nil
	self:SetPos(pl:GetPos() + Vector(0, 0, 10))
	self:SetSolid(SOLID_VPHYSICS)
	self:SetNoDraw(true)
end

function ENT:CanPlayerHold(pl)
	local slots = 11
	for k,v in pairs((pl:GetInventory().Generic or {})) do
		slots = slots - v:GetSize()
	end
	
	return slots >= self:GetSize()
end

function ENT:PickUp(pl)
	self.Owner = pl
	self:SetSolid(SOLID_NONE)
	self:SetNoDraw(true)
end

function ENT:Use(act, call)
	if not act:IsPlayer() then return end
	if self.Owner then return end
	if not self:CanPlayerHold(act) then return end
	act:GetInventory().Generic = act:GetInventory().Generic or {}
	self:PickUp(act)
	table.insert(act:GetInventory().Generic, self)
	act:InventoryChange()
end

util.AddNetworkString("item_state_update")