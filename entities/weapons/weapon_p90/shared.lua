if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
end

if ( CLIENT ) then

	SWEP.PrintName			= "FN P90"			
	SWEP.Author				= "victormeriqui & C0BRA"
	SWEP.Slot				= 2
	SWEP.SlotPos			= 3
	SWEP.IconLetter			= "m"
	
	killicon.AddFont( "smg_mp5", "CSKillIcons", SWEP.IconLetter, Color( 255, 80, 0, 255 ) )
	
end

SWEP.HoldType			= "smg"
SWEP.Base				= "weapon_cs_base"
SWEP.Category			= "Endure-It"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/v_smg_p90.mdl"
SWEP.WorldModel			= "models/weapons/w_smg_p90.mdl"

SWEP.Weight				= 7
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Primary.Sound			= Sound( "Weapon_P90.Single" )
SWEP.Primary.Recoil			= 0.2
SWEP.Primary.Damage			= 20
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.01
SWEP.Primary.ClipSize		= -1
SWEP.Primary.Delay			= 0.07
SWEP.Primary.DefaultClip	= 0
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "smg1"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

function SWEP:Special()
	self:EmitSound(Sound("Weapon_Glock.Slideback"));
	self.Primary.Automatic = !self.Primary.Automatic;
end

function SWEP:Think()
	if self.IsZoomedIn then
		self.IronTime = self.IronTime + self.IronMoveSpeed
	else
		self.IronTime = self.IronTime - self.IronMoveSpeed
	end
	
	self.IronTime = math.Clamp(self.IronTime, 0, 1)
	
	if (self.Owner:KeyDown(IN_ATTACK2) && !self.Owner:KeyDown(IN_USE)) and not self.IsZoomedIn then
		self.SwayScale = 0.2;
		self.BobScale = 0.2;
		self.Owner:SetFOV(self.ZoomScale, self.ZoomSpeed)
		self.IsZoomedIn = true
	elseif not self.Owner:KeyDown(IN_ATTACK2) and self.IsZoomedIn then
		self.SwayScale = 2;
		self.BobScale = 2;
		self.Owner:SetFOV(0, self.ZoomSpeed)
		self.IsZoomedIn = false
	end	
	
	if self.Owner:KeyDown(IN_SPEED) and self.Owner:GetVelocity():Length() > self.Owner:GetRunSpeed() * 0.5 then
		self.Sprinting = true
	else
		self.Sprinting = false
	end
end	

SWEP.ZoomScale = 60;
SWEP.ZoomSpeed = 0.2;
SWEP.IronMoveSpeed = 0.0156761576307;--FUCKING PRECISE MOTHERFUCKER

SWEP.IronSightsPos = Vector (4.662, -9.6774, 2.0213)
SWEP.IronSightsAng = Vector (0, 0, 0)


function SWEP:CanTakeMagazine(mag)
	return mag:GetClass() == "sent_mag_mp5"
end