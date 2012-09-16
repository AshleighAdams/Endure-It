ENT.Type 			= "anim"
ENT.Base 			= "sent_base_item"
ENT.PrintName		= "Bandage"
ENT.Author			= "victormeriqui & C0BRA"
ENT.Information		= ""
ENT.Category		= "Endure It"

ENT.Model = "models/props/cs_office/paper_towels.mdl"
ENT.Spawnable			= false
ENT.AdminSpawnable		= true

ENT.PreferedSlot = "Generic"

if SERVER then util.AddNetworkString("action_item_bandage_1") end

function ENT:InvokeAction(id)
	if CLIENT then
		net.Start("action_item_bandage_1")
			net.WriteEntity(self)
		net.SendToServer()
	else
		if table.Count(self.Owner.Bleeders) == 0 then return end -- don't waste this one...
		self.Owner.Bleeders = {} // Nullify them
		self.Owner:EmitSound("npc/combine_soldier/zipline_clothing" .. tostring(math.random(1,2)) .. ".wav")
		
		self.Owner:InvDrop(self)
		self:Remove()
	end
end

function ENT:GetActions()
	local ret = {}
	table.insert(ret, { Name = "Heal Wounds", ID = "b" })
	return ret
end

net.Receive("action_item_bandage_1", function(l,pl)
	local ent = net.ReadEntity()
	
	if ent:GetClass() != "sent_item_bandage" then return end
	if ent.Owner != pl then return end
	
	ent:InvokeAction()
end)