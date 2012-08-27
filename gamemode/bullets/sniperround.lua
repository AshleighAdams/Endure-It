
SniperBullet = {}

-- Bullet shit
SniperBullet.Velocity = 24000 -- 2000 feet per second
SniperBullet.Damage = 95
SniperBullet.GravityModifier = 1
SniperBullet.Name = "Sniper"

SniperBullet.DecalMats = {}
SniperBullet.DecalMats[MAT_ANTLION] = "Impact.Antlion"
SniperBullet.DecalMats[MAT_BLOODYFLESH] = "Impact.BloodyFlesh"
SniperBullet.DecalMats[MAT_CONCRETE] = "Impact.Concrete"
SniperBullet.DecalMats[MAT_GLASS] = "Impact.Glass"
SniperBullet.DecalMats[MAT_METAL] = "Impact.Metal"
SniperBullet.DecalMats[MAT_DIRT] = "Impact.Concrete"
SniperBullet.DecalMats[MAT_SAND] = "Impact.Sand"
SniperBullet.DecalMats[MAT_WOOD] = "Impact.Wood"

if CLIENT then
	SniperBullet.DecalEffects = {}

	SniperBullet.Emitter = ParticleEmitter(Vector())
	SniperBullet.Scale = 1

	SniperBullet.DecalEffects[MAT_CONCRETE] = function(pos, norm, mat)
		
		for i=0, 10 * SniperBullet.Scale do
		
			local Smoke = SniperBullet.Emitter:Add( "particle/smokesprites_000"..math.random(1,9), pos )
			if (Smoke) then
				Smoke:SetVelocity( norm * math.random( 20,40*SniperBullet.Scale) + VectorRand() * math.random( 25,50*SniperBullet.Scale) )
				Smoke:SetLifeTime( math.Rand( 0 , 1 ) )
				Smoke:SetDieTime( math.Rand( 1 , 2 )*SniperBullet.Scale * 2  )
				Smoke:SetStartAlpha( math.Rand( 10, 25 ) )
				Smoke:SetEndAlpha( 0 )
				Smoke:SetStartSize( 10*SniperBullet.Scale )
				Smoke:SetEndSize( 2*SniperBullet.Scale )
				Smoke:SetRoll( math.Rand(150, 360) )
				Smoke:SetRollDelta( math.Rand(-0.2, 0.2) )			
				Smoke:SetAirResistance( 50 ) 			 
				Smoke:SetGravity( Vector(0, 0, -600) ) 			
				Smoke:SetColor( 90,90,90 )
			end
		
		end
		WorldSound("Default.BulletImpact", pos, 50)
	end
	
	
	SniperBullet.DecalEffects[MAT_WOOD] = SniperBullet.DecalEffects[MAT_CONCRETE]
	SniperBullet.DecalEffects[MAT_SAND] = SniperBullet.DecalEffects[MAT_CONCRETE]
	SniperBullet.DecalEffects[MAT_DIRT] = SniperBullet.DecalEffects[MAT_CONCRETE]
	SniperBullet.DecalEffects[MAT_GLASS] = SniperBullet.DecalEffects[MAT_CONCRETE]
	SniperBullet.DecalEffects[MAT_BLOODYFLESH] = SniperBullet.DecalEffects[MAT_CONCRETE]
	SniperBullet.DecalEffects[MAT_ANTLION] = SniperBullet.DecalEffects[MAT_CONCRETE]

	SniperBullet.DecalEffects[MAT_METAL] = function(pos, norm, mat)
		local Sparks = EffectData()
			Sparks:SetOrigin( pos )
			Sparks:SetNormal( norm )
			Sparks:SetMagnitude( SniperBullet.Scale )
			Sparks:SetScale( SniperBullet.Scale )
			Sparks:SetRadius( SniperBullet.Scale )
		util.Effect( "Sparks", Sparks )
		WorldSound("Metal_Barrel.BulletImpact", pos, 50)
	end

	SniperBullet.Decal = function(umsg, b, tbl)
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
		
		local func = SniperBullet.DecalEffects[mat]
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
		
		util.Decal(SniperBullet.DecalMats[mat] or "Impact.Concrete", hit + norm, hit - norm)
	end
end

SniperBullet.ReceiveHit = function(len, cl, tbl)
	if SERVER then
		local vel = net.ReadVector()
		local hitpos = net.ReadVector()
		local norm = net.ReadVector()
		local start = net.ReadVector()
		local ent = net.ReadEntity()
		local mat = net.ReadUInt(32)
				
		
		if ent and ValidEntity(ent) then
			local dmginfo = DamageInfo()
			dmginfo:SetDamage( (vel:Length() / SniperBullet.Velocity) * SniperBullet.Damage )
			dmginfo:SetDamageType(DMG_BULLET) --Bullet damage
			dmginfo:SetAttacker(cl)
			dmginfo:SetDamageForce(vel:GetNormal() * 50)
			ent:TakeDamageInfo(dmginfo)
		else
			local RS = RecipientFilter()
			RS:AddAllPlayers()
			RS:RemovePlayer(cl)
			umsg.Start(SniperBullet.Name .. "_Decal", RS)
				umsg.Vector(hitpos)
				umsg.Vector(norm)
				umsg.Long(mat)
				umsg.Entity(ent)
			umsg.End()
		end
	else
		SniperBullet.Decal(nil, nil, tbl)
	end
end

SniperBullet.ReceiveShoot = function(umsgr, cl)
	if SERVER then -- Just echo the message to other clients, but not our self
		local pos = net.ReadVector()
		local vel = net.ReadVector()
		local plys = net.ReadTable()
		local mask = net.ReadUInt(32)
		local seed = net.ReadFloat()
		
		local RS = RecipientFilter()
		RS:AddAllPlayers()
		RS:RemovePlayer(cl)
		
		umsg.Start("Shoot_Bullet_" .. SniperBullet.Name, RS)
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
		bul.Bullet = SniperBullet
		bul.TraceIgnore = plys
		bul.TraceMask = mask
		bul.RandSeed = seed
		
		table.insert(bullets, bul)
	end
end

-- return true to mark bullet as done
local GRAVITY = Vector(0, 0, 600)
SniperBullet.Simulate = function(self, t) -- t is time passed in seconds
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
		debugoverlay.Line(PrePos, self.Position, 2)
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
		
		SniperBullet.Decal(nil, nil, res)		
	elseif res.Hit then
		
		if res.HitSky then
			return true
		end
		
		
		if self.Mine then -- if the bullet is our own, tell the server what we hit
			SniperBullet.ReceiveHit(nil, nil, res)
			
			net.Start("Shoot_Bullet_Hit_" .. SniperBullet.Name)
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

RegisterBullet(SniperBullet)
