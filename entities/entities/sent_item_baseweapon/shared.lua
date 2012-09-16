ENT.Type 			= "anim"
ENT.Base 			= "sent_base_item"
ENT.PrintName		= "Base Weapon Pickup"
ENT.Author			= "victormeriqui & C0BRA"
ENT.Information		= ""
ENT.Category		= "Endure It"
ENT.Model = "models/weapons/w_rif_m4a1.mdl"
ENT.Weapon_Class = "weapon_m4a1"

ENT.Spawnable			= false
ENT.AdminSpawnable		= true

ENT.PreferedSlot = "Generic"
ENT.EquipSlot = "Primary"

function ENT:GetPrintName()
	return self.PrintName
end

function ENT:GetSize() -- amount of slots taken
	if self:IsPrimaryWeapon() then
		return 8
	end
	return 4
end

function ENT:IsPrimaryWeapon()
	return self:GetEquipSlot() == "Primary"
end

function ENT:IsSecondaryWeapon()
	return self:GetEquipSlot() == "Secondary"
end

function ENT:GetEquipSlot()
	return self.EquipSlot
end
