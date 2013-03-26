--require("glon")
AddCSLuaFile()

local _R = {Player = FindMetaTable("Player")}

if SERVER then
	AddCSLuaFile()
	
	include("sv_von.lua")
	
	_R.Player.SaveInventory = function(self)
		if CLIENT then return end
		local savetbl = {}
		
		for k,v in pairs(self.Inventory) do
			table.insert(savetbl, {Class = v:GetClass(), State = v:GetState()})
		end
		
		local contents = von.serialize(savetbl)
		file.Write(string.Replace(self:SteamID(), ":", "_"), "DATA", contents)
	end
	
	_R.Player.LoadInventory = function(self)
		if CLIENT then return end
		
		local contents = file.Read(string.Replace(self:SteamID(), ":", "_"), "DATA") or ""
		local dec = von.deserialize(contents) or {}
		self.Inventory = {}
		
		for kk,tbl in pairs(dec) do
			for k,v in pairs(tbl) do
				if type(v) == "table" then
					local ent = ents.Create(v.Class)
					ent:Spawn()
					ent:RestoreState(v.State)
					ent:PickUp(self)
					self.Inventory[k] = self.Inventory[k] or {}
					table.insert(self.Inventory[k], ent)
					
					if ent:GetEquipSlot() == tostring(k) then -- Run equip codens!
						ent:Equip(true)
					end
				end
			end
		end
		
		self:InventoryChange()
	end
	
	_R.Player.InventoryChange = function(self)
		net.Start("inventory_change")
			net.WriteEntity(self)
			net.WriteTable(self:GetInventory())
		net.Send(self)
	end
	
	local SlotSizes = {
		ToolBelt = 11,
		Generic = 22
	}
	
	_R.Player.CanHold = function(self, v, slot)
		local slotpos = slot or v.PreferedSlot
		local slots = SlotSizes[slotpos] or 0
		
		if slotpos == "BackPack" then
			slots = self:GetBackPackSize()
		end
		
		for k,v in pairs((self:GetInventory()[slotpos] or {})) do
			slots = slots - v:GetSize()
		end
		
		if slots >= v:GetSize() then
			return slotpos
		end
		
		slots = SlotSizes["Generic"] or 0
		for k,v in pairs((self:GetInventory().Generic or {})) do
			slots = slots - v:GetSize()
		end
		
		if slots >= v:GetSize() then
			return "Generic"
		end
		
		return nil
	end
	
	_R.Player.InvPickup = function(self, itm)
		local canhold = self:CanHold(itm)
		if canhold == nil then return end
		self:GetInventory()[canhold] = self:GetInventory()[canhold] or {}
		table.insert(self:GetInventory()[canhold], itm)
		itm:PickUp(self)
		
		self:InventoryChange()
	end
	
	net.Receive("inventory_drop", function(len, pl)
		local ent = net.ReadEntity()
		print(ent)
		if ent.Owner != pl then return end
		
		pl:InvDrop(ent)
	end)
	
	net.Receive("inventory_change", function(len)
		net.ReadEntity():InventoryChange(net.ReadTable())
	end)
	
	net.Receive("inventory_move", function(len, pl)
		local itm = net.ReadEntity()
		local slot = net.ReadString()
		
		pl:InvMove(itm, slot)
	end)
	
	net.Receive("inventory_equip", function(len, pl)
		local itm = net.ReadEntity()
		
		pl:InvEquip(itm)
	end)
else
	net.Receive("inventory_change", function(len)
		net.ReadEntity():InventoryChange(net.ReadTable())
	end)
end

if SERVER then
	util.AddNetworkString("inventory_drop")
	util.AddNetworkString("inventory_change")
	util.AddNetworkString("inventory_move")
	util.AddNetworkString("inventory_equip")
end

_R.Player.GetBackPackSize = function(self) return 16 end

_R.Player.InvRemoveItem = function(self, item)
	
	for k,v in pairs(self:GetInventory()) do
		if type(v) == "table" then
			for kk, vv in pairs(v) do
				if vv == item then
					table.remove(v, kk)
				end
			end
		else
			if v == item then
				if type(k) == "string" then
					self:GetInventory()[k] = nil
				else
					table.remove(self:GetInventory(), k)
				end
			end
		end
	end
	
end

_R.Player.InvDrop = function(self, itm)
	if SERVER then
		self:InvRemoveItem(itm)
		itm:Drop(self)
		self:InventoryChange()
	else
		net.Start("inventory_drop")
			net.WriteEntity(itm)
		net.SendToServer()
	end
end

_R.Player.InvMove = function(self, itm, slot)
	if CLIENT then
		net.Start("inventory_move")
			net.WriteEntity(itm)
			net.WriteString(slot)
		net.SendToServer()
	else
		local slot_good = self:CanHold(itm, slot)
		if slot_good and slot_good == slot then
			self:InvRemoveItem(itm)
			
			self:GetInventory()[slot] = self:GetInventory()[slot] or {}
			table.insert(self:GetInventory()[slot], itm)
			itm:Move(slot)
			self:InventoryChange()
		end
	end
end

_R.Player.SetInventory = function(self, inv)
	self.Inventory = inv
	self:InventoryChange()
end

_R.Player.GetInventory = function(self)
	if SERVER and not self.Inventory then
		self:LoadInventory()
	end
	// Remove null entities
	for k,v in pairs(self.Inventory or {}) do
		if type(v) == "table" then
			for kk,vv in pairs(v) do
				if not IsValid(vv) then
					v[kk] = nil
				end
			end
		else
			if not IsValid(v) then
				self.Inventory[k] = nil
			end
		end
	end
	
	return self.Inventory or {}
end

_R.Player.InvEquip = function(self, itm)
	if CLIENT then
		net.Start("inventory_equip")
			net.WriteEntity(itm)
		net.SendToServer()
	else
		self:InvRemoveItem(itm)
	
		local place = itm:GetEquipSlot()
		if place == "" then return end
		
		if self.Inventory[place] != nil and IsValid(self.Inventory[place]) then
			self.Inventory[place]:Equip(false)
			self:InvDrop(self.Inventory[place])
			self.Inventory[place] = nil
		end
		
		self.Inventory[place] = itm
		itm:Equip(true)
		
		self:InventoryChange()
	end
end
