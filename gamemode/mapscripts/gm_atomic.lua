Weather.Wind = Vector(50, 0, 0)

-- Spawn ents here, and things

if CLIENT then return end

concommand.Add("mag", function(pl, cmd, arg)
	local lst = scripted_ents.GetList()
	
	arg = arg[1]
	if not arg then return end
	
	for k,v in pairs(lst) do
		if k == ("sent_mag_" .. arg) then
			local ent = ents.Create(k)
			ent:SetPos(pl:GetEyeTrace().HitPos + Vector(0, 0, ent:OBBCenter().z * 2))
			ent:Spawn()
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
			ent:SetPos(pl:GetEyeTrace().HitPos + Vector(0, 0, ent:OBBCenter().z * 2))
			ent:Spawn()
		end
	end
end)

concommand.Add("ammo", function(pl, cmd, arg)
	local lst = scripted_ents.GetList()
	
	arg = arg[1]
	if not arg then return end
	
	for k,v in pairs(lst) do
		if k == ("sent_ammo_" .. arg) then
			local ent = ents.Create(k)
			ent:SetPos(pl:GetEyeTrace().HitPos + Vector(0, 0, ent:OBBCenter().z * 2))
			ent:Spawn()
		end
	end
end)

concommand.Add("clip", function(pl, cmd, arg)	
	local ent = ents.Create("sent_item_clip")
	ent:SetPos(pl:GetEyeTrace().HitPos + Vector(0, 0, ent:OBBCenter().z * 2))
	ent:Spawn()
end)

function SetupCities()
	Station = Station or ents.Create("sent_city")
	Station:SetPos(Vector(3647.132080, 2414.435059, -12270.764648))
	Station.CitySize = 1000
	Station.InitialSpawnCount = 5
	Station.ClearAllTimeThreshold = 30
	Station:Spawn()
	
	BigTown = BigTown or ents.Create("sent_city")
	BigTown:SetPos(Vector(-8723.720703, -2342.315674, -12259.845703))
	BigTown.CitySize = 1500
	BigTown.InitialSpawnCount = 25
	BigTown.MaxZombies = 25
	BigTown.ClearAllTimeThreshold = 60
	BigTown.SpawnAdditionalEvery = 2
	BigTown:Spawn()
	
	Under = Under or ents.Create("sent_city")
	Under:SetPos(Vector(-9596.420898, -1401.117554, -12504.342773))
	Under.CitySize = 500
	Under.InitialSpawnCount = 10
	Under.MaxZombies = 10
	Under.ClearAllTimeThreshold = 20
	Under.SpawnAdditionalEvery = 2
	Under.NoLower = false
	Under:Spawn()
	
	Under2 = Under2 or ents.Create("sent_city")
	Under2:SetPos(Vector(-8055.672363, -1897.861816, -12639.968750))
	Under2.CitySize = 500
	Under2.InitialSpawnCount = 10
	Under2.MaxZombies = 10
	Under2.ClearAllTimeThreshold = 20
	Under2.SpawnAdditionalEvery = 2
	Under2.NoLower = false
	Under2:Spawn()

	
	// Populate them
	Controller = Controller or ents.Create("sent_spawner")
	Controller:SetPos(Vector(0, 0, 0))
	Controller:Spawn()
end

if Controller != nil then
	SetupCities()
end

hook.Add("InitPostEntity", "setup_cities", SetupCities)