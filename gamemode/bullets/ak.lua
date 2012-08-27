
AKBullet = {}

-- Bullet shit
AKBullet.Velocity = 2350 * 12 -- 2350 feet per second
AKBullet.Damage = 35
AKBullet.GravityModifier = 1
AKBullet.Name = "AKBullet"

AKBullet.DecalMats = {}
AKBullet.DecalMats[MAT_ANTLION] = "Impact.Antlion"
AKBullet.DecalMats[MAT_BLOODYFLESH] = "Impact.BloodyFlesh"
AKBullet.DecalMats[MAT_CONCRETE] = "Impact.Concrete"
AKBullet.DecalMats[MAT_GLASS] = "Impact.Glass"
AKBullet.DecalMats[MAT_METAL] = "Impact.Metal"
AKBullet.DecalMats[MAT_DIRT] = "Impact.Concrete"
AKBullet.DecalMats[MAT_SAND] = "Impact.Sand"
AKBullet.DecalMats[MAT_WOOD] = "Impact.Wood"

if CLIENT then
	AKBullet.DecalEffects = {}

	AKBullet.Emitter = ParticleEmitter(Vector())
	AKBullet.Scale = 1

	AKBullet.DecalEffects[MAT_CONCRETE] = function(pos, norm, mat)
		
		for i=0, 10 * AKBullet.Scale do
		
			local Smoke = AKBullet.Emitter:Add( "particle/smokesprites_000"..math.random(1,9), pos )
			if (Smoke) then
				Smoke:SetVelocity( norm * math.random( 20,40*AKBullet.Scale) + VectorRand() * math.random( 25,50*AKBullet.Scale) )
				Smoke:SetLifeTime( math.Rand( 0 , 1 ) )
				Smoke:SetDieTime( math.Rand( 1 , 2 )*AKBullet.Scale * 2  )
				Smoke:SetStartAlpha( math.Rand( 10, 25 ) )
				Smoke:SetEndAlpha( 0 )
				Smoke:SetStartSize( 10*AKBullet.Scale )
				Smoke:SetEndSize( 2*AKBullet.Scale )
				Smoke:SetRoll( math.Rand(150, 360) )
				Smoke:SetRollDelta( math.Rand(-0.2, 0.2) )			
				Smoke:SetAirResistance( 50 ) 			 
				Smoke:SetGravity( Vector(0, 0, -600) ) 			
				Smoke:SetColor( 90,90,90 )
			end
		
		end
		WorldSound("Default.BulletImpact", pos, 50)
	end
	
	
	AKBullet.DecalEffects[MAT_WOOD] = AKBullet.DecalEffects[MAT_CONCRETE]
	AKBullet.DecalEffects[MAT_SAND] = AKBullet.DecalEffects[MAT_CONCRETE]
	AKBullet.DecalEffects[MAT_DIRT] = AKBullet.DecalEffects[MAT_CONCRETE]
	AKBullet.DecalEffects[MAT_GLASS] = AKBullet.DecalEffects[MAT_CONCRETE]
	AKBullet.DecalEffects[MAT_BLOODYFLESH] = AKBullet.DecalEffects[MAT_CONCRETE]
	AKBullet.DecalEffects[MAT_ANTLION] = AKBullet.DecalEffects[MAT_CONCRETE]

	AKBullet.DecalEffects[MAT_METAL] = function(pos, norm, mat)
		local Sparks = EffectData()
			Sparks:SetOrigin( pos )
			Sparks:SetNormal( norm )
			Sparks:SetMagnitude( AKBullet.Scale )
			Sparks:SetScale( AKBullet.Scale )
			Sparks:SetRadius( AKBullet.Scale )
		util.Effect( "Sparks", Sparks )
		WorldSound("Metal_Barrel.BulletImpact", pos, 50)
	end

	AKBullet.Decal = function(umsg, b, tbl)
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
		
		local func = AKBullet.DecalEffects[mat]
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
		
		util.Decal(AKBullet.DecalMats[mat] or "Impact.Concrete", hit + norm, hit - norm)
	end
end

AKBullet.ReceiveHit = function(len, cl, tbl)
	if SERVER then
		local vel = net.ReadVector()
		local hitpos = net.ReadVector()
		local norm = net.ReadVector()
		local start = net.ReadVector()
		local ent = net.ReadEntity()
		local mat = net.ReadUInt(32)
				
		
		if ent and ValidEntity(ent) then
			local dmginfo = DamageInfo()
			dmginfo:SetDamage( (vel:Length() / AKBullet.Velocity) * AKBullet.Damage )
			dmginfo:SetDamageType(DMG_BULLET) --Bullet damage
			dmginfo:SetAttacker(cl)
			dmginfo:SetDamageForce(vel:GetNormal() * 50)
			ent:TakeDamageInfo(dmginfo)
		else
			local RS = RecipientFilter()
			RS:AddAllPlayers()
			RS:RemovePlayer(cl)
			umsg.Start(AKBullet.Name .. "_Decal", RS)
				umsg.Vector(hitpos)
				umsg.Vector(norm)
				umsg.Long(mat)
				umsg.Entity(ent)
			umsg.End()
		end
	else
		AKBullet.Decal(nil, nil, tbl)
	end
end

AKBullet.ReceiveShoot = function(umsgr, cl)
	if SERVER then -- Just echo the message to other clients, but not our self
		local pos = net.ReadVector()
		local vel = net.ReadVector()
		local plys = net.ReadTable()
		local mask = net.ReadUInt(32)
		local seed = net.ReadFloat()
		
		local RS = RecipientFilter()
		RS:AddAllPlayers()
		RS:RemovePlayer(cl)
		
		umsg.Start("Shoot_Bullet_" .. AKBullet.Name, RS)
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
		bul.Bullet = AKBullet
		bul.TraceIgnore = plys
		bul.TraceMask = mask
		bul.RandSeed = seed
		
		table.insert(bullets, bul)
	end
end

-- return true to mark bullet as done
local GRAVITY = Vector(0, 0, 600)
AKBullet.Simulate = function(self, t) -- t is time passed in seconds
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
		
		AKBullet.Decal(nil, nil, res)		
	elseif res.Hit then
		
		if res.HitSky then
			return true
		end
		
		
		if self.Mine then -- if the bullet is our own, tell the server what we hit
			AKBullet.ReceiveHit(nil, nil, res)
			
			net.Start("Shoot_Bullet_Hit_" .. AKBullet.Name)
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

RegisterBullet(AKBullet)
