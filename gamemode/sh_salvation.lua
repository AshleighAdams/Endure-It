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
stanima.MaxBlood = 1200

-- Player functions

function Player:GetBlood()
	return self:Health()
end

function Player:SetBlood(Value)
	self:SetHealth(Value)
end

function Player:Bleed(dmginfo)
	self.Bleeders = self.Bleeders or {}
	table.insert(self.Bleeders, {dmginfo, dmginfo:GetDamage() / 120})
end

function Player:GetStanima()
	if CLIENT then
		return self:GetNWFloat("Stanima", 100)
	else
		return self:GetPData("Stanima", 100)
	end
end

function Player:SetStanima(Value)
	Value = math.Clamp(Value, 0, 100)
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

function Player:ResetStanima()
	self.StanimaTransforms = {}
	self.StanimaEffects = {}
	self.Bleeders = {}
	self:SetStanima(100)
end

function Player:StanimaThink(time)
	for k, v in pairs(self.Bleeders) do
		v[1]:SetDamage(v[2] * time)
		self:TakeDamageInfo(v[1])
		v[2] = v[2] - 1 * time -- Slow the bleeding down a bit
	end

	local transform = 0
	for k, trans in pairs(self.StanimaTransforms or {}) do
		local ret = trans(self, time)
		if ret == nil then
			table.remove(self.StanimaTransforms, k)
			continue
		end
		
		transform = transform + ret
	end
	
	transform = transform * time
	
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

function stanima.PlayerSlowdown(pl) /* Used to set the players speed based upon stanima */
	local max_runspeed = 20 * 17.6 * 0.75
	local walk_speed = pl:GetWalkSpeed()
	
	local newspeed = pl:GetStanima() / 100 * (max_runspeed - walk_speed)
end

stanima.BreathSound = "player/breathe1.wav"

function stanima.Breath(pl)
	if SERVER then
		
		if pl.BreathSound == nil then
			pl.BreathSound = CreateSound(pl, stanima.BreathSound)
			pl.BreathSound:SetSoundLevel(30)
			
		end
		
		pl.BreathSound:ChangeVolume(1 - (pl:GetStanima() / 100))
		
		if not pl.BreathSound:IsPlaying() then
			pl.BreathSound:Play()
		end
		--player/breathe1.wav
		--ambient/creatures/town_scared_breathing[1-2].wav
	end
end

function stanima.PlayerStanimaIncrease(pl)
	local blood = pl:GetBlood() / stanima.MaxBlood
	return blood * 1 /* 1% per second, 100 seconds at full blood */
end

function stanima:PlayerSpawn(pl)
	pl:ResetStanima()
	pl:SetBlood(self.MaxBlood)
	pl:SetMaxHealth(self.MaxBlood)
	
	-- Default effects
	pl:AddStanimaEffect(self.PlayerSlowdown)
	pl:AddStanimaEffect(self.Breath)
	
	-- Default transforms
	pl:AddStanimaTransform(self.PlayerStanimaIncrease)
end

function stanima.ScalePlayerDamage(