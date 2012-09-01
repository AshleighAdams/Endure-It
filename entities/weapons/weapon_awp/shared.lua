if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
end

if ( CLIENT ) then

	SWEP.PrintName			= "AI AWP"			
	SWEP.Author				= "victormeriqui & C0BRA"

	SWEP.Slot				= 1
	SWEP.SlotPos			= 1
	SWEP.IconLetter			= "f"
	
	killicon.AddFont( "sniper_awp", "CSKillIcons", SWEP.IconLetter, Color( 255, 80, 0, 255 ) )

end

SWEP.HoldType			= "ar2"
SWEP.Base				= "weapon_cs_base"
SWEP.Category			= "Endure-It"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/v_snip_awp.mdl"
SWEP.WorldModel			= "models/weapons/w_snip_awp.mdl"

SWEP.Weight				= 9
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false
SWEP.DontPrimaryAttackAnim = true

SWEP.Primary.Sound			= Sound( "Weapon_Awp.Single" )
SWEP.Primary.Recoil			= 2.5
SWEP.Primary.Damage			= 95
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0
SWEP.Primary.ClipSize		= 11
SWEP.Primary.Delay			= 1.2
SWEP.Primary.DefaultClip	= 10
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "smg1"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.ZoomScale = 35;
SWEP.ZoomSpeed = 0.4;
SWEP.IronMoveSpeed = 0.02;

SWEP.IronSightsPos = Vector (5.5862, -3.5, 2.0838)
SWEP.IronSightsAng = Vector (0, 0, 0)

function SWEP:PrimaryAttack()
	
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	
	if ( !self:CanPrimaryAttack() ) then return end
	
	// Play shoot sound
	self.Weapon:EmitSound( self.Primary.Sound )
	
	// Shoot the bullet
	local cone = self.Primary.Cone
	if not self.Zoomed then
		cone = 0.5
	end
	self:CSShootBullet( self.Primary.Damage, self.Primary.Recoil, self.Primary.NumShots, cone )
	
	// Remove 1 bullet from our clip
	self:TakePrimaryAmmo( 1 )
	
	if ( self.Owner:IsNPC() ) then return end
	
	// Punch the player's view
	self.Owner:ViewPunch( Angle( math.Rand(-0.2,-0.1) * self.Primary.Recoil, math.Rand(-0.1,0.1) *self.Primary.Recoil, 0 ) )
	
	// In singleplayer this function doesn't get called on the client, so we use a networked float
	// to send the last shoot time. In multiplayer this is predicted clientside so we don't need to 
	// send the float.
	if ( (SinglePlayer() && SERVER) || CLIENT ) then
		self.Weapon:SetNetworkedFloat( "LastShootTime", CurTime() )
	end
	/*
	self.Owner:SetFOV(0, 0);	
	self:SetNetworkedBool("Reloading", true);
	local time = self.Owner:GetViewModel():SequenceDuration();
	timer.Simple(time, function() 
		self.Owner:SetFOV(self.ZoomScale, self.ZoomSpeed);	
		self:SetNetworkedBool("Reloading", false); 
	end);
	*/
end


function SWEP:Think()
	if self.IsZoomedIn && !self:GetNetworkedBool("Reloading") then
		self.IronTime = self.IronTime + self.IronMoveSpeed
	else
		self.IronTime = self.IronTime - self.IronMoveSpeed
	end
	
	self.IronTime = math.Clamp(self.IronTime, 0, 1)
	
	if (self.Owner:KeyDown(IN_ATTACK2) && !self.Owner:KeyDown(IN_USE)) and not self.IsZoomedIn then
		self.SwayScale = 0;
		self.BobScale = 0;
		self.Owner:SetFOV(self.ZoomScale, self.ZoomSpeed)
		self.IsZoomedIn = true
	elseif not self.Owner:KeyDown(IN_ATTACK2) and self.IsZoomedIn then
		self.SwayScale = 2;
		self.BobScale = 2;
		self.Owner:SetFOV(0, self.ZoomSpeed)
		self.IsZoomedIn = false
	end	
end	


function SWEP:Reload()
	
	self.Weapon:DefaultReload( ACT_VM_RELOAD );
	self.Owner:SetFOV(0, 0);
	
	self:SetNetworkedBool("Reloading", true);
	local time = self.Owner:GetViewModel():SequenceDuration();
	timer.Simple(time, function() 
		self:SetNetworkedBool("Reloading", false)
		self.Owner:SetFOV(self.ZoomScale, self.ZoomSpeed)	
	end);
	
end

local sin, cos = math.sin, math.cos; --SPEED!
local function DrawCircle(x, y, rad, qual, color, xmod)
		
	local matrix = {};
	local vert = 1;
	for i = 0, math.pi*2, qual do
		
		matrix[vert] = {x = x + math.cos(i)*(rad+xmod), y = y + math.sin(i)*rad};
		vert = vert+1;

	end 
	
	surface.SetTexture()
	surface.SetDrawColor(color)	
	surface.DrawPoly(matrix)
		
end

function SWEP:DrawHUD()
	
    local Cam = {};
	
	Cam.angles = LocalPlayer():EyeAngles();
    Cam.origin = LocalPlayer():GetShootPos();
    
	local sizex = 800
	local sizey = 800
	
	Cam.x = ScrW()/2 - sizex / 2;
    Cam.y = ScrH()/2 - sizey / 2;
    Cam.w = sizex;
    Cam.h = sizey;
	
	Cam.drawviewmodel = false;
	Cam.fov = 3;
	
	if(self.IsZoomedIn && self.IronTime == 1 && !self:GetNetworkedBool("Reloading")) then
				
		render.RenderView(Cam);	
	
		render.ClearStencil()
		render.SetStencilEnable( true ) 

		render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_NEVER);
		render.SetStencilFailOperation(STENCILOPERATION_INCR);
		render.SetStencilPassOperation(STENCILOPERATION_KEEP); 

		DrawCircle(ScrW()/2, ScrH()/2, 300, 0.1, Color(255,255,255,255), 0);
		
		render.SetStencilPassOperation( STENCILOPERATION_DECR);

		DrawCircle(ScrW()/2, ScrH()/2, 200, 0.1, Color(255,255,255,255), 0);
		
		render.SetStencilReferenceValue(1);
		render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL);
		
		surface.SetDrawColor(0, 0, 0, 255);
		surface.DrawRect(0, 0, ScrW(), ScrH());
		
		
		render.SetStencilEnable(false);
	
	end
end

function SWEP:AdjustMouseSensitivity()
  return (self.Weapon:GetNetworkedBool( "Ironsights", false ) and 0.2) or nil
end


