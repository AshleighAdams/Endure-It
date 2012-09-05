AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");
include('shared.lua');


function ENT:SpawnFunction(ply, tr)

	if (!tr.Hit) then 
		return; 
	end
	
	local spawn = tr.HitPos + Vector(0, 0, 15);
	
	local ent = ents.Create("sent_spawner");
	ent:SetPos(spawn);
	ent:Spawn();

	return ent;

end


function ENT:Initialize()

	local ent = self.Entity;
	ent:SetModel("models/Gibs/HGIBS.mdl");
	ent:PhysicsInit(SOLID_VPHYSICS);
	ent:SetSolid(SOLID_VPHYSICS);
	ent:SetMoveType(MOVETYPE_VPHYSICS); 
	
	local phys = ent:GetPhysicsObject();
	if (phys:IsValid()) then
		phys:Wake();
	end
		
end

function ENT:OnTakeDamage(dmginfo)
	self.Entity:TakePhysicsDamage(dmginfo);
end



function ENT:Think()
	
	local ent = self.Entity;
	local pos = ent:GetPos();	
	
	local npcn = 0;
	for k,v in pairs(ents.FindInSphere(pos, 1000)) do
		
		if (v:GetClass() == "npc_zombie") then
			npcn = npcn + 1;
		end
		
	end
	
	for k,v in pairs(ents.FindInSphere(pos, 1000)) do
		
		if (v:IsPlayer() && npcn <= self.MaxNPC) then
			
			timer.Simple(math.random(1, 10), function()
				
				local zambiepos =  pos + Vector(math.random(10, 500), math.random(10, 500), 0);
				local zambie = ents.Create("npc_zombie");
				zambie:SetPos(zambiepos);
				zambie:Spawn();
				
				local effectdata = EffectData();
				effectdata:SetStart(zambiepos);
				effectdata:SetOrigin(zambiepos);
				effectdata:SetScale(10);
				util.Effect("BloodImpact", effectdata);	
				
			end)
			
		end
	end

end


