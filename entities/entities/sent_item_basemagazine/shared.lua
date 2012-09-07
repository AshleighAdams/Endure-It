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
ENT.Rounds = 0
ENT.Capacity = 30
ENT.Bullet = "Nato_556"

function ENT:CanTakeBullet(bul)
	if self.Rounds == self.Capacity then return false end
	
	if type(bul) == "table" then
		bul = bul.Name
	end
	return self.Bullet == bul
end

function ENT:GetPrintName(nonewlines)
	local nl = "\n"
	if nonewlines then
		nl = ": "
	end

	return self.PrintName .. nl .. tostring(self.Rounds)
end

function ENT:InvokeAction(id, gun)
	if id == "pip" then
		if CLIENT then
			gun = LocalPlayer():GetActiveWeapon()
			net.Start("action_item_stanag_1")
				net.WriteEntity(self)
				net.WriteEntity(gun)
				net.WriteString("pip")
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
	
	if id == "top" then
		if CLIENT then
			gun = LocalPlayer():GetActiveWeapon()
			net.Start("action_item_stanag_1")
				net.WriteEntity(self)
				net.WriteEntity(gun)
				net.WriteString("top")
			net.SendToServer()
		end
		if self.Inside then
			if self.Inside and ValidEntity(self.Inside) then
				self.Inside:SetMagazine(nil)
			end
			self.Inside = nil
		end
	end
end

function ENT:Move(newpos)
	
end

function ENT:GetActions()
	local ret = {}
	table.insert(ret, { Name = "Put in weapon", ID = "pip" })
	table.insert(ret, { Name = "Take out of weapon", ID = "top" })
	return ret
end

if SERVER then
	util.AddNetworkString("action_item_stanag_1")
	net.Receive("action_item_stanag_1", function(len, pl)
		local itm = net.ReadEntity()
		local gun = net.ReadEntity()
		local ivk = net.ReadString()
		
		if itm.Owner and itm.Owner == pl then
			itm:InvokeAction(ivk, gun)
		end
	end)
end

function ENT:OnDrop()
	if self.Inside != nil and ValidEntity(self.Inside) and self.Inside.SetMagazine then
		self.Inside:SetMagazine(nil)
		self.Inside = nil
	end
end