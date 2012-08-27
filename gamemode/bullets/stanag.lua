
StanagBullet_556 = {}

-- Bullet shit
StanagBullet_556.Velocity = 3250 * 12 -- 2350 feet per second
StanagBullet_556.Damage = 25
StanagBullet_556.GravityModifier = 1
StanagBullet_556.Name = "StanagBullet_556"

StanagBullet_556.DecalMats = {}
StanagBullet_556.DecalMats[MAT_ANTLION] = "Impact.Antlion"
StanagBullet_556.DecalMats[MAT_BLOODYFLESH] = "Impact.BloodyFlesh"
StanagBullet_556.DecalMats[MAT_CONCRETE] = "Impact.Concrete"
StanagBullet_556.DecalMats[MAT_GLASS] = "Impact.Glass"
StanagBullet_556.DecalMats[MAT_METAL] = "Impact.Metal"
StanagBullet_556.DecalMats[MAT_DIRT] = "Impact.Concrete"
StanagBullet_556.DecalMats[MAT_SAND] = "Impact.Sand"
StanagBullet_556.DecalMats[MAT_WOOD] = "Impact.Wood"

if CLIENT then
	StanagBullet_556.DecalEffects = {}

	StanagBullet_556.Emitter = ParticleEmitter(Vector())
	StanagBullet_556.Scale = 1

	StanagBullet_556.DecalEffects[MAT_CONCRETE] = function(pos, norm, mat)
		
		for i=0, 10 * StanagBullet_556.Scale do
		
			local Smoke = StanagBullet_556.Emitter:Add( "particle/smokesprites_000"..math.random(1,9), pos )
			if (Smoke) then
				Smoke:SetVelocity( norm * math.random( 20,40*StanagBullet_556.Scale) + VectorRand() * math.random( 25,50*StanagBullet_556.Scale) )
				Smoke:SetLifeTime( math.Rand( 0 , 1 ) )
				Smoke:SetDieTime( math.Rand( 1 , 2 )*StanagBullet_556.Scale * 2  )
				Smoke:SetStartAlpha( math.Rand( 10, 25 ) )
				Smoke:SetEndAlpha( 0 )
				Smoke:SetStartSize( 10*StanagBullet_556.Scale )
				Smoke:SetEndSize( 2*StanagBullet_556.Scale )
				Smoke:SetRoll( math.Rand(150, 360) )
				Smoke:SetRollDelta( math.Rand(-0.2, 0.2) )			
				Smoke:SetAirResistance( 50 ) 			 
				Smoke:SetGravity( Vector(0, 0, -600) ) 			
				Smoke:SetColor( 90,90,90 )
			end
		
		end
		WorldSound("Default.BulletImpact", pos, 50)
	end
	
	
	StanagBullet_556.DecalEffects[MAT_WOOD] = StanagBullet_556.DecalEffects[MAT_CONCRETE]
	StanagBullet_556.DecalEffects[MAT_SAND] = StanagBullet_556.DecalEffects[MAT_CONCRETE]
	StanagBullet_556.DecalEffects[MAT_DIRT] = StanagBullet_556.DecalEffects[MAT_CONCRETE]
	StanagBullet_556.DecalEffects[MAT_GLASS] = StanagBullet_556.DecalEffects[MAT_CONCRETE]
	StanagBullet_556.DecalEffects[MAT_BLOODYFLESH] = StanagBullet_556.DecalEffects[MAT_CONCRETE]
	StanagBullet_556.DecalEffects[MAT_ANTLION] = StanagBullet_556.DecalEffects[MAT_CONCRETE]

	StanagBullet_556.DecalEffects[MAT_METAL] = function(pos, norm, mat)
		local Sparks = EffectData()
			Sparks:SetOrigin( pos )
			Sparks:SetNormal( norm )
			Sparks:SetMagnitude( StanagBullet_556.Scale )
			Sparks:SetScale( StanagBullet_556.Scale )
			Sparks:SetRadius( StanagBullet_556.Scale )
		util.Effect( "Sparks", Sparks )
		WorldSound("Metal_Barrel.BulletImpact", pos, 50)
	end

	StanagBullet_556.Decal = function(umsg, b, tbl)
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
		
		local func = StanagBullet_556.DecalEffects[mat]
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
		
		util.Decal(StanagBullet_556.DecalMats[mat] or "Impact.Concrete", hit + norm, hit - norm)
	end
end

StanagBullet_556.ReceiveHit = function(len, cl, tbl)
	if SERVER then
		local vel = net.ReadVector()
		local hitpos = net.ReadVector()
		local norm = net.ReadVector()
		local start = net.ReadVector()
		local ent = net.ReadEntity()
		local mat = net.ReadUInt(32)
				
		
		if ent and ValidEntity(ent) then
			local dmginfo = DamageInfo()
			dmginfo:SetDamage( (vel:Length() / StanagBullet_556.Velocity) * StanagBullet_556.Damage )
			dmginfo:SetDamageType(DMG_BULLET) --Bullet damage
			dmginfo:SetAttacker(cl)
			dmginfo:SetDamageForce(vel:GetNormal() * 50)
			ent:TakeDamageInfo(dmginfo)
		else
			local RS = RecipientFilter()
			RS:AddAllPlayers()
			RS:RemovePlayer(cl)
			umsg.Start(StanagBullet_556.Name .. "_Decal", RS)
				umsg.Vector(hitpos)
				umsg.Vector(norm)
				umsg.Long(mat)
				umsg.Entity(ent)
			umsg.End()
		end
	else
		StanagBullet_556.Decal(nil, nil, tbl)
	end
end

StanagBullet_556.ReceiveShoot = function(umsgr, cl)
	if SERVER then -- Just echo the message to other clients, but not our self
		local pos = net.ReadVector()
		local vel = net.ReadVector()
		local plys = net.ReadTable()
		local mask = net.ReadUInt(32)
		local seed = net.ReadFloat()
		
		local RS = RecipientFilter()
		RS:AddAllPlayers()
		RS:RemovePlayer(cl)
		
		umsg.Start("Shoot_Bullet_" .. StanagBullet_556.Name, RS)
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
		bul.Bullet = StanagBullet_556
		bul.TraceIgnore = plys
		bul.TraceMask = mask
		bul.RandSeed = seed
		
		table.insert(bullets, bul)
	end
end

-- return true to mark bullet as done
local GRAVITY = Vector(0, 0, 600)
StanagBullet_556.Simulate = function(self, t) -- t is time passed in seconds
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
		
		StanagBullet_556.Decal(nil, nil, res)		
	elseif res.Hit then
		
		if res.HitSky then
			return true
		end
		
		
		if self.Mine then -- if the bullet is our own, tell the server what we hit
			StanagBullet_556.ReceiveHit(nil, nil, res)
			
			net.Start("Shoot_Bullet_Hit_" .. StanagBullet_556.Name)
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

RegisterBullet(StanagBullet_556)
