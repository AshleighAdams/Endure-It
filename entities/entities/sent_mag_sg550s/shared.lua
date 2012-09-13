ENT.Type 			= "anim"
ENT.Base 			= "sent_item_basemagazine"
ENT.PrintName		= "SG550s Mag"
ENT.Author			= "victormeriqui & C0BRA"
ENT.Information		= ""
ENT.Category		= "Endure It"

ENT.Spawnable			= false
ENT.AdminSpawnable		= true

ENT.Model = "models/wystan/weapons/sr-25magazine.mdl"

ENT.PreferedSlot = "ToolBelt"
ENT.IsMagazine = true
ENT.Rounds = 0
ENT.Capacity = 20
ENT.Bullet = "Nato_556_Sniper"


function ENT:CanTakeBullet(bul)
	if self.Rounds == self.Capacity then return false end
	
	if type(bul) == "table" then
		bul = bul.Name
	end
		
	return self.Bullet == bul || bul == "Nato_556"
end

function ENT:BulletChangedFunc(bul)
	self.Bullet = "Nato_556_Sniper"
end