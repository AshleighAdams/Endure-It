Weather.Wind = Vector(50, 0, 0)

-- Spawn ents here, and things

concommand.Add("mag", function(pl)
	local ent = ents.Create("sent_item_stanag")
	ent:SetPos(pl:GetEyeTrace().HitPos)
	ent:Spawn()
end)