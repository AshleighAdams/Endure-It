if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
end

if ( CLIENT ) then

	SWEP.PrintName			= "SIG Sauer SG550 Sniper"			
	SWEP.Author				= "victormeriqui & C0BRA"

	SWEP.Slot				= 3
	SWEP.SlotPos			= 1
	SWEP.IconLetter			= "i"
	
	killicon.AddFont( "weapon_sg550s", "CSKillIcons", SWEP.IconLetter, Color( 255, 80, 0, 255 ) )

end

SWEP.HoldType			= "ar2"
SWEP.Base				= "weapon_cs_base"
SWEP.Category			= "Endure-It"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModelFlip		= true

SWEP.ViewModel			= "models/weapons/v_snip_sg550.mdl"
SWEP.WorldModel			= "models/weapons/w_snip_sg550.mdl"

SWEP.UseBullet = StanagBullet_556

SWEP.Weight				= 12
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Primary.Sound			= Sound( "Weapon_Sg550.Single" )
SWEP.Primary.Recoil			= 0
SWEP.Primary.Damage			= 95
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0
SWEP.Primary.ClipSize		= 21
SWEP.Primary.Delay			= 1.2
SWEP.Primary.DefaultClip	= 20
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "smg1"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.ZoomScale = 15;
SWEP.ZoomSpeed = 0.4;
SWEP.IronMoveSpeed = 0.02;

SWEP.IronSightsPos = Vector (5.6005, 0, 1.8803)
SWEP.IronSightsAng = Vector (0, 0, 0)


function SWEP:PrimaryAttack()
	
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	
	if ( !self:CanPrimaryAttack() ) then return end
	
	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	self.Weapon:EmitSound( self.Primary.Sound )
	
	self:CSShootBullet( self.Primary.Damage, self.Primary.Recoil, self.Primary.NumShots, cone )
	
	self:TakePrimaryAmmo( 1 )
	
	if ( (SinglePlayer() && SERVER) || CLIENT ) then
		self.Weapon:SetNetworkedFloat( "LastShootTime", CurTime() )
	end
		
end


function SWEP:Think()

	if self.IsZoomedIn then
		self.IronTime = self.IronTime + self.IronMoveSpeed
	else
		self.IronTime = self.IronTime - self.IronMoveSpeed
	end
	
	self.IronTime = math.Clamp(self.IronTime, 0, 1)
	
	if (self.Owner:KeyDown(IN_ATTACK2) && !self.Owner:KeyDown(IN_USE)) and not self.IsZoomedIn then
		self.SwayScale = 0.5;
		self.BobScale = 0.5;
		self.Owner:SetFOV(self.ZoomScale, self.ZoomSpeed)
		self.IsZoomedIn = true
		self:SetNWBool("zoomed", true)
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
	
	local time = self.Owner:GetViewModel():SequenceDuration();
	timer.Simple(time, function() 
		self.Owner:SetFOV(self.ZoomScale, self.ZoomSpeed);
	end);
	
	
end

if CLIENT then
	SWEP.ScopeRT = SWEP.ScopeRT or GetRenderTarget("ei_scope_", 1024, 1024, true)

	Material("models/weapons/v_models/snip_awp/v_awp_scope"):SetTexture("$basetexture", SWEP.ScopeRT)
	Material("models/weapons/v_models/snip_awp/v_awp_scope"):SetUndefined("$envmap")
	Material("models/weapons/v_models/snip_awp/v_awp_scope"):SetUndefined("$envmapmask")
	Material("models/weapons/v_models/snip_awp/v_awp_scope"):SetShader("UnlitGeneric")
	
end


local OffsetClicksY = {}
OffsetClicksY[1] = Angle(0.02, 0, 0)
OffsetClicksY[2] = Angle(0.05, 0, 0)
OffsetClicksY[3] = Angle(0.09, 0, 0)
OffsetClicksY[4] = Angle(0.13, 0, 0)
OffsetClicksY[5] = Angle(0.18, 0, 0)
OffsetClicksY[6] = Angle(0.25, 0, 0)
OffsetClicksY[7] = Angle(0.32, 0, 0)
OffsetClicksY[8] = Angle(0.4, 0, 0)
OffsetClicksY[9] = Angle(0.49, 0, 0)
OffsetClicksY[10] = Angle(0.59, 0, 0)

function SWEP:DrawHUD()
	local Cam = {}
	
	self.Zero.ClicksY = math.Clamp(self.Zero.ClicksY, 0, 10)
	
	self.LastClicksY = self.LastClicksY or 0
	if self.LastClicksY != self.Zero.ClicksY then
		self.LastClicksY = self.Zero.ClicksY
		chat.AddText("Zeroing at ", Color(255, 127, 0), tostring(self.Zero.ClicksY * 100), " meters")
	end
	
	self.Zero.ClicksY = self.Zero.ClicksY or 0
	self.Zero.ClicksX = self.Zero.ClicksX or 0
	
	Cam.angles = LocalPlayer():EyeAngles() + (OffsetClicksY[self.Zero.ClicksY] or Angle(0,0,0)) + Angle(0, self.Zero.ClicksX/300 * -1, 0)
    Cam.origin = LocalPlayer():GetShootPos()
    
	local sizex = 800
	local sizey = 800
	
	Cam.x = 0-- - sizex / 2;
    Cam.y = 0-- - sizey / 2;
    Cam.w = 1024;
    Cam.h = 1024;
	
	Cam.drawviewmodel = false;
	
	Cam.fov = 5;
	
	if self.IronTime == 1 then
		self.ViewModelFlip = false
	else
		self.ViewModelFlip = true
	end
	
	local oldrt = render.GetRenderTarget()
	render.SetRenderTarget(self.ScopeRT)
		local w, h = ScrW(), ScrH()
		render.SetViewPort(0, 0, 1024, 1024)
		render.RenderView(Cam)
		
		surface.SetDrawColor(0, 0, 0, 255)
		--surface.DrawLine(0, 512 + 25, 1024*2, 512+25)
		
		local cx = w / 2
		local cy = h / 2
		
		surface.DrawLine(cx, 0, cx, h)
		surface.DrawLine(0, cy, w, cy)
		
		for i = 0, 10 do
			local spacing = (1/Cam.fov * 170) * i --57 * i
			
			surface.DrawLine(cx - 6, cy + spacing, cx + 6, cy + spacing) // down
			surface.DrawLine(cx - 6, cy - spacing, cx + 6, cy - spacing) // up
			
			spacing = spacing *  (w / h)
			
			surface.DrawLine(cx - spacing, cy + 6, cx - spacing, cy - 6) // left
			surface.DrawLine(cx + spacing, cy + 6, cx + spacing, cy - 6) // right
		end
		
		--surface.DrawLine(512*1.875, 0, 512 * 1.875, 1024*2)
		
		surface.SetDrawColor(0, 0, 0, 255 - math.pow(self.IronTime, 6) * 255)
		surface.DrawRect(0, 0, w, h)
		
		render.SetViewPort(0, 0, w, h)
	render.SetRenderTarget(oldrt)


end

function SWEP:AdjustMouseSensitivity()
	if self.IsZoomedIn and self.IronTime == 1 then
		return 0.1
	end
	return 1
end


