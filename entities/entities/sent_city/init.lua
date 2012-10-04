AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");
include('shared.lua');

function ENT:SpawnFunction(ply, tr)

	if (!tr.Hit) then 
		return; 
	end
	
	local spawn = tr.HitPos + Vector(0, 0, 15);
	
	local ent = ents.Create("sent_city");
	ent:SetPos(spawn);
	ent:Spawn();

	return ent;

end


function ENT:Initialize()

	local ent = self.Entity;
	ent:SetModel("models/Gibs/HGIBS.mdl");
	ent:SetNoDraw(true)
	ent:PhysicsInit(SOLID_NONE);
	ent:SetSolid(SOLID_NONE);
	ent:SetMoveType(MOVETYPE_NONE); 
	
end


function ENT:SuitibleHeight(x, y, ent) // later, we can impliment this better, but for now, a trace up/down from current height of the entity
	local ret = nil
		
	local height = ent:OBBMaxs().Z - ent:OBBMins().Z
	
	local starti, endi, stepdir = self.Steps, -self.Steps, -1
	
	if self.NoLower == false and math.random(1, 2) == 1 then
		starti, endi, stepdir = -self.Steps, self.Steps, 1
	end
	
	for i = starti, endi, stepdir do	 -- from sky down?
		local tracedata = {}
		tracedata.start = Vector(x, y, self:GetPos().z + i * self.StepSize)
		tracedata.endpos = tracedata.start + Vector(0, 0, height)
		tracedata.filter = ent
		tracedata.mins = ent:OBBMins()
		tracedata.maxs = ent:OBBMaxs()
		
		local trace = util.TraceHull(tracedata)
		
		if not util.IsInWorld(tracedata.start) or not util.IsInWorld(tracedata.endpos) then
			continue
		end
		
		if not trace.Hit then
			local z = self:GetPos().z + i * self.StepSize
			local tr = util.QuickTrace(Vector(x, y, z), Vector(0, 0, -1), {ent})
			z = tr.HitPos.z
			return z
		end -- If the hull trace didn't hit anything, we're good!
	end
	
	return nil
end

ENT.NPCs = {
	"npc_zombie",
	"npc_zombie",
	"npc_zombie",
	"npc_zombie",
	"npc_zombie",
	"npc_zombie",
	"npc_zombie",
	"npc_zombie",
	
	"npc_fastzombie",
	"npc_fastzombie",
	"npc_fastzombie",
	"npc_fastzombie",
	
	"npc_poisonzombie",
	
	"npc_zombine",
	
	"npc_headcrab",
	"npc_headcrab",
	"npc_headcrab",
	"npc_headcrab_fast",
	"npc_headcrab_poison"
	
}

function ENT:SpawnZombie()
	if self.CurrentZombies >= self.MaxZombies then return end
	
	local x = math.sin(math.random(0, 360))
	local y = math.sin(math.random(0, 360))

	x = x * self.CitySize
	y = y * self.CitySize
	
	x = x + self:GetPos().x
	y = y + self:GetPos().y
	
	local zombie = ents.Create( self.NPCs[math.random(1, #self.NPCs)] )
	local z = self:SuitibleHeight(x, y, zombie)
	
	if z == nil then
		zombie:Remove() -- Oh well, we failed to spawn him
		return nil
	end
	
	zombie:SetPos(Vector(x, y, z))
	zombie:SetAngles(Angle(0, math.random(0, 360), 0)) -- So they arn't all facing the same way...
	zombie:Spawn();
	
	zombie:DropToFloor()
	
	return zombie
end

ENT.PlayersInHotzone = {}

function ENT:UnPopulate(pl)
	self.PlayersInHotzone[pl] = nil
end

function ENT:Populate(pl)
	if not pl or not IsValid(pl) then return end
	
	if self.PlayersInHotzone[pl] then return end -- We're already in the zone, get lost!
	
	local ent = self.Entity;
	local epos = ent:GetPos();
	
	for i = 0, self.InitialSpawnCount do
		local zomb = self:SpawnZombie()
			
		if zomb == nil then continue end
		
		zomb.Spawner = self
		zomb.Invoker = pl
	
		print(tostring(pl:GetPos().z) .. " + " ..tostring(i) .. " " .. tostring(zomb:GetPos():Distance(pl:GetPos()))  )
	end
	
	self.PlayersInHotzone[pl] = true
end

ENT.NextSpawn = CurTime() + 10
ENT.CurrentZombies = 0
ENT.CleanUpTime = 0
function ENT:Think()
	
	if self.CleanUpTime != 0 and CurTime() > self.CleanUpTime then
		print("Cleaning zombies up")
		for k,v in pairs(ents.FindByClass("npc_*")) do
			if v.Spawner == self then
				v:Remove()
			end
		end
		self.CleanUpTime = 0
	end
	
	self.CurrentZombies = 0
	for k,v in pairs(ents.FindByClass("npc_*")) do
		if v.Spawner == self then
			self.CurrentZombies = self.CurrentZombies + 1
		end
	end
	
	local count = 0 -- Used for spawning when near
	for v,k in pairs(self.PlayersInHotzone) do
		if not k then continue end
		if not IsValid(v) then return end
		
		self.CleanUpTime =  CurTime() + self.ClearAllTimeThreshold -- Reset the counter.
		
		if v:GetPos():Distance(self:GetPos()) < self.CitySize then
			count = count + 1
		end
	end
	
	if count == 0 then return end
	
	if CurTime() > self.NextSpawn then
		self.NextSpawn = CurTime() + self.SpawnAdditionalEvery / count -- / count so that i spawn more often, but not in a batch
		local zomb = self:SpawnZombie()
		
		if zomb == nil then return end
		
		zomb.Spawner = self
		zomb.Invoker = pl
	end
end
