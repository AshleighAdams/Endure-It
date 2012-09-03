AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");
include('shared.lua');


function ENT:SpawnFunction(ply, tr)

	if (!tr.Hit) then 
		return; 
	end
	
	local spawn = tr.HitPos + Vector(0, 0, 15);
	
	local ent = ents.Create("sent_sentry");
	ent:SetPos(spawn);
	ent:Spawn();

	return ent;

end


function ENT:Initialize()

	local ent = self.Entity;
	ent:SetModel("models/Combine_turrets/ground_turret.mdl");
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
	
	local HasFiredThisIt = false;
	for k,v in pairs(ents.FindInSphere(ent:GetPos(), 1000)) do
		
		if( string.sub(v:GetClass(), 0, 3) == "npc" && v:Health() > 0 && ent:VisibleVec(v:GetPos())) then 
			
			local ang = (v:EyePos() - pos):Angle();

			bullet = {};
			bullet.Num = 1;
			bullet.Src = ent:GetPos();
			bullet.Dir = ent:GetAngles():Forward();
			bullet.Spread = Vector(0, 0, 0);
			bullet.Tracer = 1;	
			bullet.Force = 2;
			bullet.Attacker = ent:GetOwner();
			bullet.Inflictor = ent;
			bullet.Damage = 1;
			 
			if(!HasFiredThisIt) then
				HasFiredThisIt = true;
				ent:SetAngles(ang);
				WorldSound("npc/strider/strider_minigun.wav", pos, 160, 200);
				ent:FireBullets(bullet);
			end
		end
	end

end


