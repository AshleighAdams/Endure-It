AddCSLuaFile()
local Player = _R.Player

--[[ 
		Stanima Section
	A players stanima is essenetially their short-term health; a low
	stanima prevents the player from re-generating blood as quickly, 
	and will find it more difficult to get around, their aim will be
	off and a few other things.  Eating foot will call 
	AddStanimaFactor with a value in which it will increase over time
--]]

stanima = stanima or {}

-- Player functions
function Player:GetStanima()
	if CLIENT then
		return self:GetNWFloat("Stanima", 1)
	else
		return self:GetPData("Stanima", 1)
	end
end

function Player:SetStanima(Value)
	if CLIENT then -- Usefull for prediction, we don't want to send the NWFloat every frame...
		self:SetNWFloat("Stanima", Value)
		return
		--error("Player:SetStanima is not to be called on the client!")
	end
	self:SetPData("Stanima", Value)
end

-- Used when calculating the decay rate of a players stanima, return nil and the factor will be removed
function Player:AddStanimaTransform(func)
	self.StanimaTransforms = self.StanimaTransforms or {}
	table.insert(self.StanimaTransforms, func)
end

function Player:AddStanimaEffect(effect)
	self.StanimaEffects = self.StanimaEffects or {}
	table.insert(self.StanimaEffects, effect)
end

function Player:StanimaThink(time)
	local transform = 0
	for k, trans in pairs(self.StanimaTransforms or {}) do
		local ret = trans(self, time)
		if ret == nil then
			table.remove(self.StanimaTransforms, k)
			continue
		end
		
		transform = transform + ret
	end
	
	self:SetStanima(self:GetStanima() + transform)
	
	for k,v in pairs(self.StanimaEffects or {}) do
		if v(self) then
			table.remove(self.StanimaEffects, k)
		end
	end
	
	-- Send it to the clients if needed (you really should add the stanima transform on the client to ensure that it is fluent and predicted)
	if SERVER and (self.NextStanimaSend == nil or CurTime() > self.NextStanimaSend) then
		self.NextStanimaSend = CurTime() + 1
		self:SetNWFloat(self:GetStanima())
	end
end

-- Stanima functions

function stanima:Think()
	if self.LastThink then
		local t = CurTime() - self.LastThink -- Time difference, so each call to StanimaThink is proportional
		
		for k, v in pairs(player.GetAll()) do
			if not ValidEntity(v) then continue end
			v:StanimaThink(t)
		end
	end
	self.LastThink = CurTime()
end
hook.Add("Think", "StanimaThink", function() stanima:Think() end)