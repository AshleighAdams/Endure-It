require("glon")

if SERVER then
	AddCSLuaFile()
	_R.Player.SaveInventory = function(self)
		if CLIENT then return end
		local savetbl = {}
		
		for k,v in pairs(self.Inventory) do
			table.insert(savetbl, {Class = v:GetClass(), State = v:GetState()})
		end
		
		local contents = glon.encode(savetbl)
		file.Write(string.Replace(self:SteamID(), ":", "_"), "DATA", contents)
	end
	
	_R.Player.LoadInventory = function(self)
		if CLIENT then return end
		
		local contents = file.Read(string.Replace(self:SteamID(), ":", "_"), "DATA")
		local dec = glon.decode(contents) or {}
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
				end
			end
		end
		
		self:InventoryChange()
	end
	
	util.AddNetworkString("inventory_change")
	
	
	_R.Player.InventoryChange = function(self)
		net.Start("inventory_change")
			net.WriteEntity(self)
			net.WriteTable(self:GetInventory())
		net.Send(self)
	end
	
	_R.Player.CanHold = function(self, v)
		local slots = 11
		for k,v in pairs((self:GetInventory().Generic or {})) do
			slots = slots - v:GetSize()
		end
		
		return slots >= v:GetSize()
	end
	
	_R.Player.InvPickup = function(self, itm)
		if not self:CanHold(itm) then return end
		self:GetInventory().Generic = self:GetInventory().Generic or {}
		table.insert(self:GetInventory().Generic, itm)
		itm:PickUp(self)
		
		self:InventoryChange()
	end
	
	net.Receive("inventory_drop", function(len, pl)
		local ent = net.ReadEntity()
		print(ent)
		if ent.Owner != pl then return end
		
		pl:InvDrop(ent)
	end)
else
	net.Receive("inventory_change", function(len)
		net.ReadEntity():InventoryChange(net.ReadTable())
	end)
end

if SERVER then
	util.AddNetworkString("inventory_drop")
	
end

_R.Player.InvDrop = function(self, itm)
	if SERVER then
		for k,v in pairs((self:GetInventory().Generic or {})) do
			if v == itm then
				table.remove(self:GetInventory().Generic, k)
			end
		end
		
		for k,v in pairs((self:GetInventory().Generic or {})) do
			if v == itm then
				table.remove(self:GetInventory().Generic, k)
			end
		end
		
		for k,v in pairs((self:GetInventory().ToolBelt or {})) do
			if v == itm then
				table.remove(self:GetInventory().ToolBelt, k)
			end
		end
		
		for k,v in pairs((self:GetInventory().BackPack or {})) do
			if v == itm then
				table.remove(self:GetInventory().BackPack, k)
			end
		end
				
		itm:Drop(self)
		self:InventoryChange()
	else
		net.Start("inventory_drop")
			net.WriteEntity(itm)
		net.SendToServer()
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
		
	return self.Inventory or {}
end
