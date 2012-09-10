AddCSLuaFile()
local Player = _R.Player

--[[ 
		Stanima Section
	A players stanima is essenetially their short-term health; a low
	stanima prevents the player from re-generating blood as quickly, 
	and will find it more difficult to get around, their aim will be
	off and a few other things
--]]

function Player:GetStanima()
	if CLIENT then
		return self:GetNWFloat("Stanima", 1)
	else
		return self:GetPData("Stanima", 1)
	end
end

function Player:SetStanima(Value)
	if CLIENT then error("Player:SetStanima is not to be called on the client!") end
	self:SetPData("Stanima", Value)
end

-- Used when calculating the decay rate of a players stanima, return nil and the factor will be removed
function Player:AddStanimaFactor(func)
	self.StanimaFactors = self.StanimaFactors or {}
	table.insert(self.StanimaFactors, func)
end

function Player:StanimaThink()
	-- TODO: Logic here
end

local function Think()
	
end
hook.Add("Think", "StanimaThink", Think)