local bullets = {}

Weather = {}
Weather.AirDensity = 1.2 -- kg m-3
Weather.Wind = Vector(207, 0, 0) -- 19kph, kph * 10.96 = inches/s

DefaultBullet = DefaultBullet or {}

-- Bullet shit
DefaultBullet.Velocity = 1500 * 12 -- 2000 feet per second
DefaultBullet.Damage = 20
DefaultBullet.GravityModifier = 1
DefaultBullet.Name = "Default"
DefaultBullet.TracerChance = 1

DefaultBullet.Mass = 0.008
DefaultBullet.DragCoefficient = 0.295 / (DefaultBullet.Mass * 1000)

print("cr", DefaultBullet.DragCoefficient)

DefaultBullet.DecalMats = {}
DefaultBullet.DecalMats[MAT_ANTLION] = "Impact.Antlion"
DefaultBullet.DecalMats[MAT_BLOODYFLESH] = "Impact.BloodyFlesh"
DefaultBullet.DecalMats[MAT_CONCRETE] = "Impact.Concrete"
DefaultBullet.DecalMats[MAT_GLASS] = "Impact.Glass"
DefaultBullet.DecalMats[MAT_METAL] = "Impact.Metal"
DefaultBullet.DecalMats[MAT_DIRT] = "Impact.Concrete"
DefaultBullet.DecalMats[MAT_SAND] = "Impact.Sand"
DefaultBullet.DecalMats[MAT_WOOD] = "Impact.Wood"

BulletHitSounds = {}
BulletHitSounds[MAT_GLASS] = "Glass"
BulletHitSounds[MAT_DIRT] = "Dirt"
BulletHitSounds[MAT_FLESH] = "Flesh"
BulletHitSounds[MAT_CONCRETE] = "BulletImpact"
BulletHitSounds[MAT_TILE] = "Tile"
BulletHitSounds[MAT_SAND] = "Sand"
BulletHitSounds[MAT_WOOD] = "Wood"

if CLIENT then

	local Tube = Material("trails/tube")
	local Laser = Material( "cable/redlaser" )
	
	DefaultBullet.DrawTracers = function()
		for k,v in pairs(bullets) do
			if v.Bullet.DrawTracer != nil then
				v.Bullet:DrawTracer(v)
				continue
			end
			
			if not v.StartDraw then
				v.StartDraw = RealTime() + 0.05
				if v.IsTracer then
					v.StartDraw = RealTime() + 0.02
				end
			end
			if v.StartDraw > RealTime() and v.Mine then
				continue
			end
			
			local Vector1 = v.Position
			local Vector2 = (v.LastPos or v.Position)

			if v.Mine then
				Vector2 = Vector2 - Vector(0, 0, 3) // so you can see the tracers from behind
			end
			
			if v.IsTracer then
				local distance = (LocalPlayer():GetPos() - Vector2):Length()
				local size = distance / 500
				
				if distance < 100 then size = 0 end
				
				render.SetMaterial(Laser)	
				render.DrawBeam(Vector1, Vector2, size, 100, 100, Color(255, 0, 0, 255)) 
			else
				render.SetMaterial(Tube)	
				render.DrawBeam(Vector1, Vector2, 0.5, 100, 100, Color(255, 255, 255, 255)) 
			end
			
			
		end
	end
	hook.Add("PostDrawOpaqueRenderables", "DefaultBullet.DrawTracers", DefaultBullet.DrawTracers)


	DefaultBullet.DecalEffects = {}

	DefaultBullet.Emitter = ParticleEmitter(Vector())
	DefaultBullet.Scale = 1

	DefaultBullet.DecalEffects[MAT_CONCRETE] = function(self, pos, norm, mat)
		
		for i=0, 10 * self.Scale do
		
			local Smoke = self.Emitter:Add( "particle/smokesprites_000"..math.random(1,9), pos )
			if (Smoke) then
				Smoke:SetVelocity( norm * math.random( 20,40*self.Scale) + VectorRand() * math.random( 25,50*self.Scale) )
				Smoke:SetLifeTime( math.Rand( 0 , 1 ) )
				Smoke:SetDieTime( math.Rand( 1 , 2 )*self.Scale * 2  )
				Smoke:SetStartAlpha( math.Rand( 10, 25 ) )
				Smoke:SetEndAlpha( 0 )
				Smoke:SetStartSize( 10*self.Scale )
				Smoke:SetEndSize( 2*self.Scale )
				Smoke:SetRoll( math.Rand(150, 360) )
				Smoke:SetRollDelta( math.Rand(-0.2, 0.2) )			
				Smoke:SetAirResistance( 50 ) 			 
				Smoke:SetGravity( Vector(0, 0, -600) ) 			
				Smoke:SetColor( 90,90,90 )
			end
		
		end
		local type_prfx = BulletHitSounds[mat] or "Default"
		WorldSound( type_prfx.. ".BulletImpact", pos, 50 )
	end
	
	
	DefaultBullet.DecalEffects[MAT_WOOD] = DefaultBullet.DecalEffects[MAT_CONCRETE]
	DefaultBullet.DecalEffects[MAT_SAND] = DefaultBullet.DecalEffects[MAT_CONCRETE]
	DefaultBullet.DecalEffects[MAT_DIRT] = DefaultBullet.DecalEffects[MAT_CONCRETE]
	DefaultBullet.DecalEffects[MAT_GLASS] = DefaultBullet.DecalEffects[MAT_CONCRETE]
	DefaultBullet.DecalEffects[MAT_BLOODYFLESH] = DefaultBullet.DecalEffects[MAT_CONCRETE]
	DefaultBullet.DecalEffects[MAT_ANTLION] = DefaultBullet.DecalEffects[MAT_CONCRETE]

	DefaultBullet.DecalEffects[MAT_METAL] = function(self, pos, norm, mat)
		local Sparks = EffectData()
			Sparks:SetOrigin( pos )
			Sparks:SetNormal( norm )
			Sparks:SetMagnitude( self.Scale )
			Sparks:SetScale( self.Scale )
			Sparks:SetRadius( self.Scale )
		util.Effect( "Sparks", Sparks )
		WorldSound("Metal_Barrel.BulletImpact", pos, 50)
	end

	DefaultBullet.Decal = function(self, umsg, b, tbl)
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
		
		local func = self.DecalEffects[mat]
		if func then
			func(self, hit, norm, mat)
		end
		
		if ent and (ent:IsPlayer() or ent:IsNPC()) then
			local vPoint = hit
			local effectdata = EffectData()
			effectdata:SetStart( vPoint ) // not sure if we need a start and origin (endpoint) for this effect, but whatever
			effectdata:SetOrigin( vPoint )
			effectdata:SetScale( 1 )
			util.Effect( "BloodImpact", effectdata )	
		end
		
		util.Decal(self.DecalMats[mat] or "Impact.Concrete", hit + norm, hit - norm)
	end
end

DefaultBullet.ReceiveHit = function(self, len, cl, tbl)
	if SERVER then
		local vel = Vector(net.ReadFloat(), net.ReadFloat(), net.ReadFloat()) -- net.ReadVector()
		local hitpos = Vector(net.ReadFloat(), net.ReadFloat(), net.ReadFloat())
		local norm = Vector(net.ReadFloat(), net.ReadFloat(), net.ReadFloat())
		local start = Vector(net.ReadFloat(), net.ReadFloat(), net.ReadFloat())
		local ent = net.ReadEntity()
		local mat = net.ReadUInt(32)
		local hg = net.ReadUInt(8)
				
		if ent and ValidEntity(ent) and not ent:IsVehicle() then
			local dmginfo = DamageInfo()
			dmginfo:SetDamage( (vel:Length() / self.Velocity) * self.Damage )
			dmginfo:SetDamageType(DMG_BULLET) --Bullet damage
			dmginfo:SetAttacker(cl)
			dmginfo:SetDamagePosition(hitpos)
			dmginfo:SetDamageForce(vel:GetNormal() * 50)
			
			if ent:IsPlayer() then
				hook.Call("ScalePlayerDamage", (GM or GAMEMODE), ent, hg, dmginfo)
			elseif ent:IsNPC() then
				hook.Call("ScaleNPCDamage", (GM or GAMEMODE), ent, hg, dmginfo)
			elseif ent:Health() > 0 then
				ent:SetHealth(ent:Health() - dmginfo:GetDamage())
				if ent:Health() <= 0 then
					ent:Input("Break")
				end
			end
			
			
			ent:TakeDamageInfo(dmginfo)
		else
			local RS = RecipientFilter()
			RS:AddAllPlayers()
			RS:RemovePlayer(cl)
			umsg.Start(self.Name .. "_Decal", RS)
				umsg.Vector(hitpos)
				umsg.Vector(norm)
				umsg.Long(mat)
				umsg.Entity(ent)
			umsg.End()
		end
	else
		self:Decal(nil, nil, tbl)
	end
end

DefaultBullet.ReceiveShoot = function(self, umsgr, cl)
	if SERVER then -- Just echo the message to other clients, but not our self
		local pos = net.ReadVector()
		local vel = Vector(net.ReadFloat(), net.ReadFloat(), net.ReadFloat())
		local plys = net.ReadTable()
		local mask = net.ReadUInt(32)
		local seed = net.ReadFloat()
		
		local RS = RecipientFilter()
		RS:AddAllPlayers()
		RS:RemovePlayer(cl)
		
		debugoverlay.Line(pos, pos + vel:GetNormal() * 50, 5, Color(0, 255, 0))
		
		umsg.Start("Shoot_Bullet_" .. self.Name, RS)
			umsg.Vector(pos)
			umsg.Float(vel.x)
			umsg.Float(vel.y)
			umsg.Float(vel.z)
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
		local vel = Vector(umsgr:ReadFloat(), umsgr:ReadFloat(), umsgr:ReadFloat()) -- umsgr:ReadVector()
		local plys = {}
		local count = umsgr:ReadLong()
		for i = 1, count do
			table.insert(plys, umsgr:ReadEntity())
		end
		local seed = umsgr:ReadFloat()
		
		bul.Direction = vel:GetNormal()
		bul.Velocity = vel
		bul.Position = pos
		bul.Bullet = self
		bul.TraceIgnore = plys
		bul.RandSeed = seed
		
		debugoverlay.Line(bul.Position, bul.Position + bul.Direction * 1000, 5, Color(0, 0, 255))
		
		if bul.Bullet.TracerChance != nil and bul.Bullet.TracerChance != 0 then
			math.randomseed(seed)
			bul.IsTracer = math.random(1, bul.Bullet.TracerChance) == 1
		end
		
		table.insert(bullets, bul)
	end
end

function Inches(units)
	return units * 1.33333333333333
end

function Feet(units)
	return units * 16 --* 0.75
end

function Yards(units)
	return Feet(units * 3)
end

function Meters(units)
	return units * 52.4934
end

DefaultBullet.GetTraceMask = function(self, bul)
	local speed = bul.Velocity:Length()
	local mask = MASK_SHOT
	
	if speed > Feet(800) then
		mask = mask - CONTENTS_WATER
	end
	
	return mask
end

local bullets_reg = {}

function GetBullet(name)
	return bullets_reg[name]
end

function RegisterBullet(bull, base)
	bullets_reg[bull.Name] = bull
	base = base or DefaultBullet
	
	local col = Color(255, 127, 0, 255)
	if SERVER then
		col = Color(100, 200, 255)
	end
	MsgC(col, "Registering bullet " .. bull.Name .. "\n")
	
	for k,v in pairs(base) do
		if bull[k] == nil then
			bull[k] = base[k]
			MsgC(col, "Bullet " .. bull.Name .. " is inheriting " .. tostring(k) .. " from " .. base.Name .. " \n")
		end
	end
	
	/*
	bull.Simulate = bull.Simulate or DefaultBullet.Simulate
	bull.ReceiveShoot = bull.ReceiveShoot or DefaultBullet.ReceiveShoot
	bull.ReceiveHit = bull.ReceiveHit or DefaultBullet.ReceiveHit
	bull.Velocity = bull.Velocity or DefaultBullet.Velocity
	bull.Damage = bull.Damage or DefaultBullet.Damage
	bull.GravityModifier = bull.GravityModifier or DefaultBullet.GravityModifier
	bull.Name = bull.Name or DefaultBullet.Name
	bull.DecalMats = bull.DecalMats or DefaultBullet.DecalMats
	bull.DecalEffects = bull.DecalEffects or DefaultBullet.DecalEffects
	bull.Emitter = bull.Emitter or DefaultBullet.Emitter
	bull.Scale = bull.Scale or DefaultBullet.Scale
	bull.Decal = bull.Decal or DefaultBullet.Decal
	*/
	
	if SERVER then
		util.AddNetworkString("Shoot_Bullet_" .. bull.Name)
		util.AddNetworkString("Shoot_Bullet_Hit_" .. bull.Name)
		util.AddNetworkString(bull.Name .. "_Decal")
		
		net.Receive("Shoot_Bullet_" .. bull.Name, function(...)
			bull:ReceiveShoot(...) 
		end)
		net.Receive("Shoot_Bullet_Hit_" .. bull.Name, function(...)
			bull:ReceiveHit(...)
		end)
	else
		usermessage.Hook(bull.Name .. "_Decal", function(...)
			bull:Decal(...)
		end)
		
		usermessage.Hook("Shoot_Bullet_" .. bull.Name, function(...)
			bull:ReceiveShoot(...)
		end)
		
		usermessage.Hook("Shoot_Bullet_Hit" .. bull.Name, function(...)
			bull:ReceiveHit(...)
		end)
	end
	print("Registered bullet ", bull.Name)
end

local function EmitWorldSound(name, pos, shush)
	-- We do it n times to make it loudder
	local to = 5
	if shush then
		to = 1
	end
	for i = 1, to do
		WorldSound(name, pos)
	end
	--te:EmitSound(name, pos, 100, 200)
end

local GRAVITY = Vector(0, 0, 600)
-- return true to mark bullet as done
local bubble_effect = "vortigaunt_beam" --"vortigaunt_beam" -- water_bubble_trail_1
PrecacheParticleSystem(bubble_effect)

DefaultBullet.Simulate = function(self, bul, t) -- t is time passed in seconds
	local PrePos = bul.Position -- Used to check for a hit
	bul.LastPos = bul.Position
	bul.Position = bul.Position + bul.Velocity * t
	bul.LastSplash = bul.LastSplash or 0
	
	// apply drag
	local speed = (bul.Velocity - Weather.Wind):Length()
	local coef = self.DragCoefficient / 1000 -- i don't know...
	
	local cont = util.PointContents(bul.Position)
	if cont == CONTENTS_WATER or cont == CONTENTS_TRANSLUCENT or cont == 268435488 then
		coef = coef * 40
		
		cont = util.PointContents(bul.LastPos)
		if CurTime() != bul.LastSplash and not (cont == CONTENTS_WATER or cont == CONTENTS_TRANSLUCENT or cont == 268435488) then
			local tr = {}
			tr.start = PrePos
			tr.endpos = bul.Position
			tr.filter = bul.TraceIgnore
			tr.mask = MASK_SHOT - CONTENTS_WATER
			
			local res = util.TraceLine(tr)
			
			local ed = EffectData()
			ed:SetStart(res.HitPos)
			ed:SetOrigin(res.HitPos)
			ed:SetNormal(res.HitNormal)
			ed:SetScale(8)
			util.Effect("gunshotsplash", ed)
			bul.LastSplash = CurTime()
			// Splash effect
		end
		
		// Bubbles!!!
		util.ParticleTracerEx(bubble_effect, bul.LastPos, bul.Position, false, 0, -1)
	end
	
	local x = ((math.sqrt(1 + 4 * speed * coef * t) - 1.0) / (2.0 * speed * coef * t))

	bul.Velocity = bul.Velocity * x
	
	// apply wind
	bul.Velocity = bul.Velocity + (Weather.Wind * self.DragCoefficient * 10 * t)
	
	// apply gravity
	bul.Velocity = bul.Velocity - (GRAVITY * t)
	
	bul.Direction = bul.Velocity:GetNormal()
	
	if self.ExtraSimulate then
		self:ExtraSimulate(bul, t)
	end
	
	if not bul.Cracked then
		local dist1 = (LocalPlayer():GetShootPos() - bul.Position):Length()
		local dist2 = (LocalPlayer():GetShootPos() - bul.LastPos):Length()
		
		if dist1 > dist2 then
			bul.Cracked = true
			
			local u = bul.Position - bul.LastPos
			local v = LocalPlayer():GetShootPos() - bul.LastPos
			
			u:Normalize()
			local dot = u:Dot(v)
			local pos = bul.LastPos + dot * u
			
			if pos:Distance(bul.Position) > bul.LastPos:Distance(bul.Position) then
				pos = bul.Position
			end
					
			debugoverlay.Line(LocalPlayer():GetShootPos() - Vector(0, 0, 10), pos, 5, Color(255, 0, 0))
			
			local tr = util.TraceLine({ startpos = pos, endpos = LocalPlayer():GetShootPos(), mask = MASK_SHOT})
						
			if (LocalPlayer():GetShootPos() - pos):Length() < 150 * 10 then
				if bul.Velocity:Length() > Feet(1120) then
					EmitWorldSound("arma2/sscrack" .. tostring(math.random(1, 2)) .. ".wav", pos, tr.HitWorld or bul.Mine)
				elseif not bul.Mine then
					EmitWorldSound("arma2/bullet_by" .. tostring(math.random(1, 5)) .. ".wav", pos, true)
				end
			end
		end
	else
		local dist1 = (LocalPlayer():GetShootPos() - bul.Position):Length()
		local dist2 = (LocalPlayer():GetShootPos() - bul.LastPos):Length()
		
		if dist1 < dist2 then
			self.Cracked = false
		end
	end
	
	if CLIENT then
		debugoverlay.Line(PrePos, bul.Position, 1)
	end
	
	local tr = {}
	tr.start = PrePos
	tr.endpos = bul.Position
	tr.filter = bul.TraceIgnore
	tr.mask = bul.Bullet:GetTraceMask(bul)
	
	local res = util.TraceLine(tr)
	local dot = -bul.Direction:Dot(res.HitNormal)
	
	local maxbounce = 0.5 /* About 45 deg */
	--CONTENTS_TRANSLUCENT
	if res.Hit then
		local cont = util.PointContents(res.HitPos - res.HitNormal)
		if cont == CONTENTS_WATER or cont == CONTENTS_TRANSLUCENT or cont == 268435488 then
			maxbounce = 0.2
			if bul.LastSplash != CurTime() then
				local scale = bul.Velocity:Length() / bul.Bullet.Velocity
				local ed = EffectData()
				ed:SetStart(res.HitPos)
				ed:SetOrigin(res.HitPos)
				ed:SetNormal(res.HitNormal)
				ed:SetScale(8 * scale)
				util.Effect("gunshotsplash", ed)
				bul.LastSplash = CurTime()
			end
		end
	end
	
	if not res.HitSky and res.HitWorld and (bul.Velocity:Length() > 100) and dot < maxbounce then
		
		local vellen = bul.Velocity:Length()
		
		bul.RandSeed = bul.RandSeed + 1
		math.randomseed(bul.RandSeed)
		
		
		math.randomseed(math.Rand(-99999, 99999))
		
		local rand1, rand2, rand3 = math.Rand(-1, 1), math.Rand(-1, 1), math.Rand(-1, 1)
		
		rand1 = rand1 * rand1
		rand2 = rand2 * rand2
		rand3 = rand3 * rand3
		
		local randomspread = Vector(
			rand1 * 0.1,
			rand2 * 0.1,
			rand3 * 0.1
		)
		
		local norm = res.HitNormal
		local vel_new = bul.Direction - 2 * (bul.Direction:Dot(norm)) * norm
		--bul.Velocity:Normalize() + (res.HitNormal * (1 - dot))
		
		bul.Velocity = ( randomspread + vel_new ) * vellen * (maxbounce - dot)
		bul.Position = res.HitPos + res.HitNormal
		
		self:Decal(nil, nil, res)	

	elseif res.Hit then
		
		if res.HitSky then
			return true
		end
		
		
		if bul.Mine then -- if the bullet is our own, tell the server what we hit
			self:ReceiveHit(nil, nil, res)
			
			net.Start("Shoot_Bullet_Hit_" .. self.Name)
				net.WriteFloat(bul.Velocity.x)
				net.WriteFloat(bul.Velocity.y)
				net.WriteFloat(bul.Velocity.z)
				net.WriteFloat(res.HitPos.x)
				net.WriteFloat(res.HitPos.y)
				net.WriteFloat(res.HitPos.z)
				net.WriteFloat(res.HitNormal.x)
				net.WriteFloat(res.HitNormal.y)
				net.WriteFloat(res.HitNormal.z)
				net.WriteFloat(tr.start.x) -- We might need this
				net.WriteFloat(tr.start.y)
				net.WriteFloat(tr.start.z)
				net.WriteEntity(res.Entity)
				net.WriteUInt(res.MatType, 32)
				net.WriteUInt(res.HitGroup, 8)
			net.SendToServer()
		end
		
		if not bul.Cracked then
			bul.Cracked = true
			local pos = bul.Position
					
			debugoverlay.Line(LocalPlayer():GetShootPos() - Vector(0, 0, 10), pos, 5, Color(255, 0, 0))
			local tr = util.TraceLine({ startpos = pos, endpos = LocalPlayer():GetShootPos(), mask = MASK_SHOT})
			
			if math.abs(dot) < 150 * 10 and (LocalPlayer():GetShootPos() - pos):Length() < 150 * 10 then
				if bul.Velocity:Length() > (1120 * 12 * 0.75) then
					EmitWorldSound("arma2/sscrack" .. tostring(math.random(1, 2)) .. ".wav", pos, tr.HitWorld or bul.Mine)
				elseif not bul.Mine then
					EmitWorldSound("arma2/bullet_by" .. tostring(math.random(1, 5)) .. ".wav", pos, true)
				end
			end
		end
		
		return true
	end
end

RegisterBullet(DefaultBullet)

local path = (GM or GAMEMODE).Folder:sub(11) .. "/gamemode/bullets/*.lua", "gamemodes/"
local files = file.Find(path, LUA_PATH) or {}

print(path)
print("Files:")
PrintTable(files)

for k, v in pairs(files) do
	include("bullets/" .. v)
	--include((GM or GAMEMODE).Folder:sub(11) .. "/gamemode/bullets/" .. v)
	if SERVER then AddCSLuaFile((GM or GAMEMODE).Folder:sub(11) .. "/gamemode/bullets/" .. v) end
end

if SERVER then
	AddCSLuaFile("sh_bullets.lua")	
	return
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
		net.WriteFloat(bul.Velocity.x)
		net.WriteFloat(bul.Velocity.y)
		net.WriteFloat(bul.Velocity.z)
		net.WriteTable(bul.TraceIgnore)
		net.WriteFloat(bul.RandSeed) -- Used to predict the spread when it riches
	net.SendToServer()
	
	debugoverlay.Line(bul.Position, bul.Position + bul.Velocity:GetNormal() * 50, 5, Color(255, 0, 0))
		
	if bul.Bullet.TracerChance != nil and bul.Bullet.TracerChance != 0 then
		math.randomseed(bul.RandSeed)
		bul.IsTracer = math.random(1, bul.Bullet.TracerChance) == 1
	end
	
	table.insert(bullets, bul)
end

local LastTime = CurTime()
function SimulateBullets()
	local t = CurTime() - LastTime
	LastTime = CurTime()
	
	for k,v in pairs(bullets) do
		if v.Bullet.Simulate == nil or v.Bullet:Simulate(v, t) then
			table.remove(bullets, k)
		end
	end
end
hook.Add("Tick", "ThinkSimulateBullets", SimulateBullets)

function MachineMode()
	--for i=0, 15 do
		local bul = {}
		local lp = LocalPlayer()
		bul.StartPos = Vector(0, 0, 0)
		bul.Direction = -(LocalPlayer():GetShootPos():Angle() + Angle(0, 0, 0)):Forward()

		bul.Direction = bul.Direction + 
			Vector(
				math.Rand(-1, 1) * 0.0052, 
				math.Rand(-1, 1) * 0.0052, 
				math.Rand(-1, 1) * 0.0052
			)
		bul.Direction:Normalize()

		bul.TraceIgnore = {lp}

		bul.RandSeed = math.Rand(-100000, 100000)
		
		bul.Bullet = Nato_556
		
		ShootBullet(bul, function(bullet)
			bullet.Velocity = bullet.Velocity + lp:GetVelocity()
			bullet.Mine = false
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



local bulletcam = false

local FindBullet = function()
	for k,v in pairs(bullets) do
		if v.Mine then
			return v
		end
	end
end

local Cooldown = 0
local CooldownPos
local CooldownAng

local function BulletCam(ply, pos, angles, fov)
	if not bulletcam then return end
	
	local bul = FindBullet()
	if bul == nil then
		if Cooldown > RealTime() then
			local view = {}
			view.origin = CooldownPos
			view.angles = CooldownAng:Angle()
			view.fov = fov
		 
			return view
		end
		return
	end
	
	Cooldown = RealTime() + 0.75
	CooldownPos = bul.Position - bul.Direction * 100
	CooldownAng = bul.Direction
	
	local view = {}
    view.origin = bul.Position
    view.angles = bul.Direction:Angle()
    view.fov = fov
 
    return view
end
hook.Add("CalcView", "Bullets.BulletCam", BulletCam)

hook.Add("ShouldDrawLocalPlayer", "Bullets.BulletCamShouldDrawLocalPlayer", function(ply)
    if not bulletcam then return end
	
	if Cooldown > RealTime() then return true end
	
	return FindBullet() != nil
end)

concommand.Add("bulletcam_toggle", function()
	bulletcam = not bulletcam
	print("Bullet cam toggled!")
end)
