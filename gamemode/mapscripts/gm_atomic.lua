Weather.Wind = Vector(50, 0, 0)

-- Spawn ents here, and things

concommand.Add("mag", function(pl, cmd, arg)
	local lst = scripted_ents.GetList()
	
	arg = arg[1]
	if not arg then return end
	
	for k,v in pairs(lst) do
		if k == ("sent_mag_" .. arg) then
			local ent = ents.Create(k)
			ent:SetPos(pl:GetEyeTrace().HitPos)
			ent:Spawn()
			ent.Rounds = ent.Capacity
		end
	end
end)

concommand.Add("gun", function(pl, cmd, arg)
	local lst = scripted_ents.GetList()
	
	arg = arg[1]
	if not arg then return end
	
	for k,v in pairs(lst) do
		if k == ("sent_weapon_" .. arg) then
			local ent = ents.Create(k)
			ent:SetPos(pl:GetEyeTrace().HitPos)
			ent:Spawn()
		end
	end
end)