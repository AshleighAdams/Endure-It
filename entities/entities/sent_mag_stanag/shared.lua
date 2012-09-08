ENT.Type 			= "anim"
ENT.Base 			= "sent_item_basemagazine"
ENT.PrintName		= "Stanag Mag"
ENT.Author			= "victormeriqui & C0BRA"
ENT.Information		= ""
ENT.Category		= "Endure It"

ENT.Spawnable			= false
ENT.AdminSpawnable		= true

ENT.Model = "models/wystan/stanag_magazine.mdl"

ENT.PreferedSlot = "ToolBelt"
ENT.IsMagazine = true
ENT.Rounds = 0
ENT.Capacity = 30
ENT.Bullet = "Nato_556"

function ENT:CanTakeBullet(bul)
	if self.Rounds == self.Capacity then return false end
	
	if type(bul) == "table" then
		bul = bul.Name
	end
	
	if self.Rounds == 0 then
		return bul:StartWith("Nato_556") -- It can take any Nato 5.56mm
	else
		return self.Bullet == bul
	end
end