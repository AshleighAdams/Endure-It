require("glon")

if SERVER then
	AddCSLuaFile()
	
	_R.Player.SetInventory = function(self, inv)
		self.Inventory = inv
	end
	
	_R.Player.SaveInventory = function(self)
		
	end
	
	_R.Player.LoadInventory = function(self)
		local contents = file.Read(string.Replace(self:SteamID(), ":", "_"), "DATA")
		local dec = glon.decode(contents)
		self.Inventory = {}
		
		for k,v in pairs(dec) do
			local ent = ents.Create(v.Class)
			ent:Spawn()
			ent:RestoreState(v.State)
			ent:PickUp(self)
			table.insert(self.Inventory, ent)
		end
		
	end

end

_R.Player.GetInventory = function(self)
	if SERVER and not self.Inventory then
		self:LoadInventory()
	end
	
	return self.Inventory
end
