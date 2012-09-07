ENT.Type 			= "anim"
ENT.Base 			= "sent_base_item"
ENT.PrintName		= "Base Ammo"
ENT.Author			= "victormeriqui & C0BRA"
ENT.Information		= ""
ENT.Category		= "Endure It"

ENT.Model 			= "models/Items/357ammo.mdl"
ENT.Spawnable			= false
ENT.AdminSpawnable		= true

ENT.Count = 300
ENT.PreferedSlot = "ToolBelt"
ENT.Bullet = "Nato_556"

function ENT:GetPrintName()
	return self.PrintName .. "\n" .. self.Count
end

function ENT:InvokeAction(id)
	id = tostring(id)
	
	if CLIENT then
		net.Start("action_item_ammo_1")
			net.WriteEntity(self)
			net.WriteEntity(self:GetAllMags()[tonumber(id)])
		net.SendToServer()
	else
		local mag = id
		
		if mag == nil or not ValidEntity(mag) then return end
		
		mag.Bullet = self.Bullet
		mag.Rounds = mag.Rounds + 1
		mag.BulletChanged = true
		self.Count = self.Count - 1
		
		mag:StateChanged(SYNCSTATE_OWNER)
		self:StateChanged(SYNCSTATE_OWNER)
	end
end


if SERVER then
	util.AddNetworkString("action_item_ammo_1")
	net.Receive("action_item_ammo_1", function(len, pl)
		local itm = net.ReadEntity()
		local ac = net.ReadEntity()
		
		if itm.Owner and itm.Owner == pl then
			itm:InvokeAction(ac)
		end
	end)
end

function ENT:GetAllMags()
	local tbl = {}
	if not self.Owner then return tbl end
	
	for k, v in pairs(self.Owner:GetInventory()) do
		if type(v) == "table" then
			for kk,vv in pairs(v) do
				if vv.BaseClass.ClassName == "sent_item_basemag" then
					if vv:CanTakeBullet(self.Bullet) then
						table.insert(tbl, vv)
					end
				end
			end
		else
			if v.BaseClass.ClassName == "sent_item_basemag" then
				if v:CanTakeBullet(self.Bullet) then
					table.insert(tbl, v)
				end
			end
		end
	end
	
	return tbl
end

function ENT:GetActions()
	local ret = {}
	
	for k,v in pairs(self:GetAllMags()) do
		table.insert(ret, {Name = self:GetPrintName(), ID = tostring(k)})
	end
	
	--table.insert(ret, { Name = "Hello", ID = "hello" })
	return ret
end