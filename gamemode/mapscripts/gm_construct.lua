Weather.Wind = Vector(50, 0, 0)

-- Spawn ents here, and things

concommand.Add("mag", function(pl)
	local lst = scripted_ents.GetList()
	
	for k,v in pairs(lst) do
		if v.Base != "sent_item_basemagazine" then continue end
		local ent = ents.Create(k)
		ent:SetPos(pl:GetEyeTrace().HitPos)
		ent:Spawn()
	end
end)