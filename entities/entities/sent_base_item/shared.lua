ENT.Type 			= "anim"
ENT.Base 			= "base_entity"
ENT.PrintName		= "Base Item"
ENT.Author			= "victormeriqui & C0BRA"
ENT.Information		= ""
ENT.Category		= "Endure It"

ENT.Spawnable			= false
ENT.AdminSpawnable		= true

ENT.PreferedSlot = "ToolBelt"

function ENT:GetPrintName()
	return self.PrintName
end

function ENT:GetSize() -- amount of slots taken
	return 1
end

function ENT:IsBackpack()
	return false
end

function ENT:IsPrimaryWeapon()
	return false
end

function ENT:IsSecondaryWeapon()
	return false
end

function ENT:IsSmall() -- Toolbelt
	return false
end

function ENT:InvokeAction(id)
	if id == "hello" and CLIENT then
		net.Start("action_item_base_1")
		net.SendToServer()
	end
end

function ENT:GetEquipSlot()
	return ""
end

function ENT:GetActions()
	local ret = {}
	--table.insert(ret, { Name = "Hello", ID = "hello" })
	return ret
end