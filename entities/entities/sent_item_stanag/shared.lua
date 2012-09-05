ENT.Type 			= "anim"
ENT.Base 			= "sent_item_base"
ENT.PrintName		= "Base Item"
ENT.Author			= "victormeriqui & C0BRA"
ENT.Information		= ""
ENT.Category		= "Endure It"

ENT.Spawnable			= false
ENT.AdminSpawnable		= true

function ENT:InvokeAction(id, gun)
	if id == "pip" and CLIENT then
		net.Start("action_item_stanag_1")
			net.WriteEntity(self)
			net.WriteEntity(LocalPlayer():GetActiveWeapon())
		net.SendToServer()
		LocalPlayer():GetActiveWeapon():SetMagazine(self)
	elseif id == "pip" and SERVER then
		if gun.TakesMags != nil
			gun:SetMagazine(self)
		end
		/*
			TODO: !!!
		*/
	end
end

function ENT:Move(oldpos, newpos)
	
end

function ENT:GetActions()
	local ret = {}
	table.insert(ret, { Name = "Put in primary", ID = "pip" })
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