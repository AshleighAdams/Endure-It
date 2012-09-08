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
ENT.SpawnRange = 12000 -- about 400m
ENT.m_NextThink = CurTime()
function ENT:Think()
	if self.m_NextThink > CurTime() then return end
	self.m_NextThink = CurTime() + 1
	
	local ent = self.Entity;
	local pos = ent:GetPos();
	
	for k, v in pairs(ents.FindByClass("sent_city")) do
		for _, pl in pairs(player.GetAll()) do
			if pl:GetPos():Distance(v:GetPos()) < self.SpawnRange then
				v:Populate(pl)
			else
				v:UnPopulate(pl)
			end
		end
		
	end
	

end


