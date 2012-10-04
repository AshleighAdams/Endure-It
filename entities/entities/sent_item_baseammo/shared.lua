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

local function PlayerHasClip(ply)
	local inv = ply:GetInventory()
	local tool = inv.ToolBelt
	
	for k,v in pairs(tool) do
		if v:GetClass() == "sent_item_clip" then
			return true
		end
	end
	
	return false
end

function ENT:InvokeAction(id)
	if CLIENT then
		net.Start("action_item_ammo_1")
			net.WriteEntity(self)
			net.WriteEntity(self:GetAllMags()[tonumber(id)])
		net.SendToServer()
	else
		local mag = id
		
		if not self.Owner or not IsValid(self.Owner) then return end
		if mag == nil or not IsValid(mag) then return end
		if self.Count <= 0 then return end
		
		local maxrounds = 1
		if PlayerHasClip(self.Owner) then
			local to_full_clip = mag.Capacity - mag.Rounds
			to_full_clip = math.min(self.Count, to_full_clip)
			to_full_clip = math.min(10, to_full_clip)
			maxrounds = to_full_clip
		end
		
		if mag.Rounds + maxrounds > mag.Capacity then return end
		
		mag.Bullet = self.Bullet
		mag:BulletChangedFunc()
		
		mag.Rounds = mag.Rounds + maxrounds
		mag.BulletChanged = true
		self.Count = self.Count - maxrounds
		
		mag:StateChanged(SYNCSTATE_OWNER, nil, true)
		self:StateChanged(SYNCSTATE_OWNER, nil, true)
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
	if not self.Owner then self.Owner = LocalPlayer() end
	if not self.Owner then return tbl end
	
	for k, v in pairs(self.Owner:GetInventory()) do
		if type(v) == "table" then
			for kk,vv in pairs(v) do
				if vv.BaseClass.ClassName == "sent_item_basemagazine" and not vv.Inside then
					if vv:CanTakeBullet(self.Bullet) then
						table.insert(tbl, vv)
					end
				end
			end
		else
			if v.BaseClass.ClassName == "sent_item_basemagazine" and not vv.Inside  then
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
		table.insert(ret, {Name = v:GetPrintName(true), ID = tostring(k)})
	end
	
	--table.insert(ret, { Name = "Hello", ID = "hello" })
	return ret
end