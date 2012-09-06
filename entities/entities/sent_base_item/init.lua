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
	ent:SetUseType(SIMPLE_USE)
	ent:SetAngle(Angle(0, math.random(0, 360), 0))
	local phys = ent:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
end

function ENT:OnTakeDamage(dmginfo)
	self.Entity:TakePhysicsDamage(dmginfo)
end

ENT.SendNextUpdate = 0
ENT.ToWhom = 3
SYNCSTATE_EVERYONE = 1
SYNCSTATE_PVS = 2
SYNCSTATE_OWNER = 3

local net_sends = {}
net_sends[SYNCSTATE_OWNER] = function(self)
	if not self.Owner or not ValidEntity(self.Owner) then
		net.Broadcast()
		return
	end
	net.Send(self.Owner)
end
net_sends[SYNCSTATE_PVS] = function(self)
	net.SendPVS((self.Owner or self):GetPos())
end
net_sends[SYNCSTATE_EVERYONE] = function(self)
	net.Broadcast()
end

function ENT:StateChanged(towhom, wait_time)
	if wait_time == nil then wait_time = -1 end -- send it right away
	if towhom == nil then towhom = SYNCSTATE_EVERYONE end
	if towhom < self.ToWhom then
		self.ToWhom = towhom
	end
	self.SendNextUpdate = CurTime() + wait_time
	print(self:GetClass() .. " will send state in " .. tostring(wait_time) .. " seconds")
end

function ENT:Think()
	if self.SendNextUpdate != 0 then
		if CurTime() > self.SendNextUpdate then
			self.SendNextUpdate = 0
			self:SendState(self.ToWhom)
			self.ToWhom = 3
			print(self:GetClass() .. " sent state")
		end
	end
end

function ENT:RestoreState(state)
end

function ENT:SendState(syncstate)
	net.Start("item_state_update")
		net.WriteEntity(self)
		net.WriteTable(self:GetState())
	net_sends[syncstate](self) -- send using the prefered method
end

function ENT:GetState()
	return {}
end

function ENT:OnDrop(pl)
end

function ENT:Drop(pl)
	self.Owner = nil
	self:SetPos(pl:GetShootPos() - Vector(0, 0, -5))
	self:SetAngles(Angle(math.random(0, 360), math.random(0, 360), math.random(0, 360)))
	self:SetSolid(SOLID_VPHYSICS)
	self:SetNoDraw(false)
	self:GetPhysicsObject():Wake()
	self:OnDrop(pl)
end

function ENT:PickUp(pl)
	self.Owner = pl
	--self:SetNWEntity("Owner", self.Owner)
	self:SetSolid(SOLID_NONE)
	self:SetNoDraw(true)
	self:StateChanged(SYNCSTATE_OWNER)
end

function ENT:Use(act, call)
	if not act:IsPlayer() then return end
	if self.Owner then return end
	
	local dist = (self:GetPos() - act:GetEyeTrace().HitPos):Length()
	if dist > 25 then return end
	--self:SetNWEntity("Owner", self.Owner)
	act:InvPickup(self)
end

util.AddNetworkString("item_state_update")