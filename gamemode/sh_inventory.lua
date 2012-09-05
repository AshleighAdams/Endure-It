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
else
	net.Receive("inventory_change", function(len)
		net.ReadEntity():InventoryChange(net.ReadTable())
	end)
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
