local bullets = {}


local DefaultBullet = {}

-- Bullet shit
DefaultBullet.Velocity = 10000 -- 2000 feet per second
DefaultBullet.Damage = 20
DefaultBullet.GravityModifier = 1
DefaultBullet.Name = "Default"

DefaultBullet.DecalMats = {}
DefaultBullet.DecalMats[MAT_ANTLION] = "Impact.Antlion"
DefaultBullet.DecalMats[MAT_BLOODYFLESH] = "Impact.BloodyFlesh"
DefaultBullet.DecalMats[MAT_CONCRETE] = "Impact.Concrete"
DefaultBullet.DecalMats[MAT_GLASS] = "Impact.Glass"
DefaultBullet.DecalMats[MAT_METAL] = "Impact.Metal"
DefaultBullet.DecalMats[MAT_DIRT] = "Impact.Concrete"
DefaultBullet.DecalMats[MAT_SAND] = "Impact.Sand"
DefaultBullet.DecalMats[MAT_WOOD] = "Impact.Wood"

if CLIENT then

	local Tube = Material("trails/tube")
	
	DefaultBullet.DrawTracers = function()
		for k,v in pairs(bullets) do
			if not v.StartDraw then
				v.StartDraw = RealTime() + 0.05
			end
			if v.StartDraw > RealTime() and v.Mine then
				continue
			end
			
			local Vector1 = v.Position
			local Vector2 = v.LastPos or v.Position
			 
			render.SetMaterial(Tube)
			render.DrawBeam(Vector1, Vector2, 0.5, 100, 100, Color(255, 255, 255, 255)) 
		end
	end
	hook.Add("PostDrawOpaqueRenderables", "DefaultBullet.DrawTracers", DefaultBullet.DrawTracers)


	DefaultBullet.DecalEffects = {}

	DefaultBullet.Emitter = ParticleEmitter(Vector())
	DefaultBullet.Scale = 1

	DefaultBullet.DecalEffects[MAT_CONCRETE] = function(pos, norm, mat)
		
		for i=0, 10 * DefaultBullet.Scale do
		
			local Smoke = DefaultBullet.Emitter:Add( "particle/smokesprites_000"..math.random(1,9), pos )
			if (Smoke) then
				Smoke:SetVelocity( norm * math.random( 20,40*DefaultBullet.Scale) + VectorRand() * math.random( 25,50*DefaultBullet.Scale) )
				Smoke:SetLifeTime( math.Rand( 0 , 1 ) )
				Smoke:SetDieTime( math.Rand( 1 , 2 )*DefaultBullet.Scale * 2  )
				Smoke:SetStartAlpha( math.Rand( 10, 25 ) )
				Smoke:SetEndAlpha( 0 )
				Smoke:SetStartSize( 10*DefaultBullet.Scale )
				Smoke:SetEndSize( 2*DefaultBullet.Scale )
				Smoke:SetRoll( math.Rand(150, 360) )
				Smoke:SetRollDelta( math.Rand(-0.2, 0.2) )			
				Smoke:SetAirResistance( 50 ) 			 
				Smoke:SetGravity( Vector(0, 0, -600) ) 			
				Smoke:SetColor( 90,90,90 )
			end
		
		end
		WorldSound("Default.BulletImpact", pos, 50)
	end
	
	
	DefaultBullet.DecalEffects[MAT_WOOD] = DefaultBullet.DecalEffects[MAT_CONCRETE]
	DefaultBullet.DecalEffects[MAT_SAND] = DefaultBullet.DecalEffects[MAT_CONCRETE]
	DefaultBullet.DecalEffects[MAT_DIRT] = DefaultBullet.DecalEffects[MAT_CONCRETE]
	DefaultBullet.DecalEffects[MAT_GLASS] = DefaultBullet.DecalEffects[MAT_CONCRETE]
	DefaultBullet.DecalEffects[MAT_BLOODYFLESH] = DefaultBullet.DecalEffects[MAT_CONCRETE]
	DefaultBullet.DecalEffects[MAT_ANTLION] = DefaultBullet.DecalEffects[MAT_CONCRETE]

	DefaultBullet.DecalEffects[MAT_METAL] = function(pos, norm, mat)
		local Sparks = EffectData()
			Sparks:SetOrigin( pos )
			Sparks:SetNormal( norm )
			Sparks:SetMagnitude( DefaultBullet.Scale )
			Sparks:SetScale( DefaultBullet.Scale )
			Sparks:SetRadius( DefaultBullet.Scale )
		util.Effect( "Sparks", Sparks )
		WorldSound("Metal_Barrel.BulletImpact", pos, 50)
	end

	DefaultBullet.Decal = function(umsg, b, tbl)
		local hit
		local norm
		local mat
		local ent
		if tbl != nil then
			hit = tbl.HitPos
			norm = tbl.HitNormal
			mat = tbl.MatType
			ent = tbl.Entity
		else
			hit = umsg:ReadVector()
			norm = umsg:ReadVector()
			mat = umsg:ReadLong()
			ent = umsg:ReadEntity()
		end
		
		local func = DefaultBullet.DecalEffects[mat]
		if func then
			func(hit, norm)
		end
		
		if ent and (ent:IsPlayer() or ent:IsNPC()) then
			local vPoint = hit
			local effectdata = EffectData()
			effectdata:SetStart( vPoint ) // not sure if we need a start and origin (endpoint) for this effect, but whatever
			effectdata:SetOrigin( vPoint )
			effectdata:SetScale( 1 )
			util.Effect( "BloodImpact", effectdata )	
		end
		
		util.Decal(DefaultBullet.DecalMats[mat] or "Impact.Concrete", hit + norm, hit - norm)
	end
end

DefaultBullet.ReceiveHit = function(len, cl, tbl)
	if SERVER then
		local vel = net.ReadVector()
		local hitpos = net.ReadVector()
		local norm = net.ReadVector()
		local start = net.ReadVector()
		local ent = net.ReadEntity()
		local mat = net.ReadUInt(32)
				
		
		if ent and ValidEntity(ent) then
			local dmginfo = DamageInfo()
			dmginfo:SetDamage( (vel:Length() / DefaultBullet.Velocity) * DefaultBullet.Damage )
			dmginfo:SetDamageType(DMG_BULLET) --Bullet damage
			dmginfo:SetAttacker(cl)
			dmginfo:SetDamageForce(vel:GetNormal() * 50)
			ent:TakeDamageInfo(dmginfo)
		else
			local RS = RecipientFilter()
			RS:AddAllPlayers()
			RS:RemovePlayer(cl)
			umsg.Start(DefaultBullet.Name .. "_Decal", RS)
				umsg.Vector(hitpos)
				umsg.Vector(norm)
				umsg.Long(mat)
				umsg.Entity(ent)
			umsg.End()
		end
	else
		DefaultBullet.Decal(nil, nil, tbl)
	end
end

DefaultBullet.ReceiveShoot = function(umsgr, cl)
	if SERVER then -- Just echo the message to other clients, but not our self
		local pos = net.ReadVector()
		local vel = net.ReadVector()
		local plys = net.ReadTable()
		local mask = net.ReadUInt(32)
		local seed = net.ReadFloat()
		
		local RS = RecipientFilter()
		RS:AddAllPlayers()
		RS:RemovePlayer(cl)
		
		umsg.Start("Shoot_Bullet_" .. DefaultBullet.Name, RS)
			umsg.Vector(pos)
			umsg.Vector(vel)
			umsg.Long(table.Count(plys))
			for k,v in pairs(plys) do
				umsg.Entity(v)
			end
			umsg.Long(mask)
			umsg.Float(seed)
		umsg.End()
	else
		local bul = {}
		local pos = umsgr:ReadVector()
		local vel = umsgr:ReadVector()
		local plys = {}
		local count = umsgr:ReadLong()
		for i = 1, count do
			table.insert(plys, umsgr:ReadEntity())
		end
		local mask = umsgr:ReadLong()
		local seed = umsgr:ReadFloat()
		
		bul.Direction = vel:GetNormal()
		bul.Velocity = vel
		bul.Position = pos
		bul.Bullet = DefaultBullet
		bul.TraceIgnore = plys
		bul.TraceMask = mask
		bul.RandSeed = seed
		
		table.insert(bullets, bul)
	end
end

function RegisterBullet(bull)
	print("Registering bullet ", bull.Name)
	if SERVER then
		util.AddNetworkString("Shoot_Bullet_" .. bull.Name)
		util.AddNetworkString("Shoot_Bullet_Hit_" .. bull.Name)
		util.AddNetworkString(bull.Name .. "_Decal")
		
		net.Receive("Shoot_Bullet_" .. bull.Name, bull.ReceiveShoot)
		net.Receive("Shoot_Bullet_Hit_" .. bull.Name, bull.ReceiveHit)
	else
		usermessage.Hook(bull.Name .. "_Decal", bull.Decal)
		usermessage.Hook("Shoot_Bullet_" .. bull.Name, bull.ReceiveShoot)
		usermessage.Hook("Shoot_Bullet_Hit" .. bull.Name, bull.ReceiveHit)
	end
	print("Registered bullet ", bull.Name)
end

RegisterBullet(DefaultBullet)

local path = GM.Folder .. "/gamemode/bullets/*.lua", "gamemodes/"
local files = file.Find(path, "MOD") or {}

print(path)
print("Files:")
PrintTable(files)

for k, v in pairs(files) do
	include("bullets/" .. v)
	if SERVER then AddCSLuaFile("bullets/" .. v) end
end

if SERVER then
	AddCSLuaFile("sh_bullets.lua")	
	return
end

-- return true to mark bullet as done
local GRAVITY = Vector(0, 0, 600)
DefaultBullet.Simulate = function(self, t) -- t is time passed in seconds
	local PrePos = self.Position -- Used to check for a hit
	self.LastPos = self.Position
	self.Position = self.Position + self.Velocity * t
	self.Velocity = self.Velocity - (GRAVITY * t) -- take gravity away
	self.Direction = self.Velocity:GetNormal()
	
	local tr = {}
	tr.start = PrePos
	tr.endpos = self.Position
	tr.filter = self.TraceIgnore
	tr.mask = self.TraceMask or MASK_SHOT
	
	local res = util.TraceLine(tr)
	
	if CLIENT then
		debugoverlay.Line(PrePos, self.Position, 1)
	end
	
	local dot = -self.Direction:Dot(res.HitNormal)
	
	if not res.HitSky and res.HitWorld and (self.Velocity:Length() > 100) and dot < 0.5 then -- about 45 deg
		local vellen = self.Velocity:Length()
		
		self.RandSeed = self.RandSeed + 1
		math.randomseed(self.RandSeed)
		math.randomseed(math.Rand(-99999, 99999))
		
		local randomspread = Vector(
			math.Rand(-1, 1) * 0.1,
			math.Rand(-1, 1) * 0.1,
			math.Rand(-1, 1) * 0.1
		)
		
		local norm = res.HitNormal
		local vel_new = self.Direction - 2 * (self.Direction:Dot(norm)) * norm
		--self.Velocity:Normalize() + (res.HitNormal * (1 - dot))
		
		self.Velocity = ( randomspread + vel_new ) * vellen * (0.5 - dot)
		self.Position = res.HitPos + res.HitNormal
		
		DefaultBullet.Decal(nil, nil, res)		
	elseif res.Hit then
		
		if res.HitSky then
			return true
		end
		
		
		if self.Mine then -- if the bullet is our own, tell the server what we hit
			DefaultBullet.ReceiveHit(nil, nil, res)
			
			net.Start("Shoot_Bullet_Hit_" .. DefaultBullet.Name)
				net.WriteVector(self.Velocity)
				net.WriteVector(res.HitPos)
				net.WriteVector(res.HitNormal)
				net.WriteVector(tr.start) -- We might need this
				net.WriteEntity(res.Entity)
				net.WriteUInt(res.MatType, 32)
			net.SendToServer()
		end

		return true
	end
end



function ShootBullet(bul, modifyfunc) -- Ohhh, nooo, its client side...... I don't give a shit
	bul.Bullet = bul.Bullet or DefaultBullet
	bul.Position = bul.StartPos
	bul.Velocity = bul.Direction * bul.Bullet.Velocity
	bul.Mine = true
	
	if modifyfunc then
		modifyfunc(bul)
	end
	-- print("Shoot_Bullet_" .. bul.Bullet.Name)
	net.Start("Shoot_Bullet_" .. bul.Bullet.Name) -- Send the effect to everyone..
		net.WriteVector(bul.Position)
		net.WriteVector(bul.Velocity)
		net.WriteTable(bul.TraceIgnore)
		net.WriteUInt(bul.TraceMask, 32)
		net.WriteFloat(bul.RandSeed) -- Used to predict the spread when it riches
	net.SendToServer()
	
	table.insert(bullets, bul)
end

local LastTime = CurTime()
function SimulateBullets()
	local t = CurTime() - LastTime
	LastTime = CurTime()
	
	for k,v in pairs(bullets) do
		if v.Bullet.Simulate(v, t) then
			table.remove(bullets, k)
		end
	end
end
hook.Add("Tick", "ThinkSimulateBullets", SimulateBullets)

function MachineMode()
	--for i=0, 15 do
		local bul = {}
		local lp = LocalPlayer()
		bul.StartPos = lp:GetShootPos()
		bul.Direction = lp:GetAimVector()

		bul.Direction = bul.Direction + 
			Vector(
				math.Rand(-1, 1) * 0.0052, 
				math.Rand(-1, 1) * 0.0052, 
				math.Rand(-1, 1) * 0.0052
			)
		bul.Direction:Normalize()

		bul.TraceIgnore = {lp}
		bul.TraceMask = MASK_SHOT

		bul.RandSeed = math.Rand(-100000, 100000)
		
		bul.Bullet = DefaultBullet
		
		ShootBullet(bul, function(bullet)
			bullet.Velocity = bullet.Velocity + lp:GetVelocity()
		end)
	--end
end

concommand.Add("+firebul", function()
	timer.Create("pewpew", 0.1, 0, MachineMode)
	MachineMode()
end)

concommand.Add("-firebul", function()
	timer.Destroy("pewpew")
end)

