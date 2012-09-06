ENT.Type 			= "anim"
ENT.Base 			= "sent_base_item"
ENT.PrintName		= "Stanag Magazine"
ENT.Author			= "victormeriqui & C0BRA"
ENT.Information		= ""
ENT.Category		= "Endure It"
ENT.Model 			= "models/wystan/stanag_magazine.mdl"

ENT.Spawnable			= false
ENT.AdminSpawnable		= true

ENT.PreferedSlot = "ToolBelt"
ENT.IsMagazine = true
ENT.Rounds = 30
ENT.Bullet = "Nato_556"

function ENT:GetPrintName()
	return self.PrintName .. "\n" .. tostring(self.Rounds)
end

function ENT:InvokeAction(id, gun)
	if id == "pip" then
		if CLIENT then
			gun = LocalPlayer():GetActiveWeapon()
			net.Start("action_item_stanag_1")
				net.WriteEntity(self)
				net.WriteEntity(gun)
			net.SendToServer()
		end
		if gun.SetMagazine != nil and gun.CanTakeMagazine and gun:CanTakeMagazine(self) then
			if self.Inside and ValidEntity(self.Inside) then
				self.Inside:SetMagazine(nil)
			end
			gun:SetMagazine(self)
			self.Inside = gun
		end
	end
end

function ENT:Move(oldpos, newpos)
	
end

function ENT:GetActions()
	local ret = {}
	table.insert(ret, { Name = "Put in weapon", ID = "pip" })
	return ret
end

if SERVER then
	util.AddNetworkString("action_item_stanag_1")
	net.Receive("action_item_stanag_1", function(len, pl)
		local itm = net.ReadEntity()
		local gun = net.ReadEntity()
		
		if itm.Owner and itm.Owner == pl then
			itm:InvokeAction("pip", gun)
		end
	end)
end

function ENT:OnDrop()
	if self.Inside != nil and ValidEntity(self.Inside) and self.Entity.SetMagazine then
		self.Inside:SetMagazine(nil)
		self.Inside = nil
	end
end