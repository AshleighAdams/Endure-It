if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
end

if ( CLIENT ) then

	SWEP.PrintName			= "M4A1"			
	SWEP.Author				= "victormeriqui & C0BRA"
	SWEP.Slot				= 3
	SWEP.SlotPos			= 1
	SWEP.IconLetter			= "w"
	
	killicon.AddFont( "rifle_m4", "CSKillIcons", SWEP.IconLetter, Color( 255, 80, 0, 255 ) )
	
end

SWEP.HoldType			= "ar2"
SWEP.Base				= "weapon_cs_base"
SWEP.Category			= "Endure-It"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/v_rif_m4a1.mdl"
SWEP.WorldModel			= "models/weapons/w_rif_m4a1.mdl"

SWEP.Weight				= 9
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Primary.Sound			= Sound( "Weapon_M4A1.Single" )
SWEP.Primary.Recoil			= 1
SWEP.Primary.Damage			= 30
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 4.3
SWEP.Primary.ClipSize		= -1
SWEP.Primary.Delay			= 0.1
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


SWEP.ZoomScale = 55;
SWEP.ZoomSpeed = 0.1;
SWEP.IronMoveSpeed = 0.02;

SWEP.OverridePos = Vector (1.0621, 0, -2)
SWEP.OverrideAng = Vector (0.5698, 2.4502, 0)

SWEP.IronSightsPos = Vector (3.5167, 0, 1.3197)
SWEP.IronSightsAng = Vector (2.8766, -0.5125, 3.4012)

function SWEP:CanTakeMagazine(mag)
	return mag:GetClass():StartWith("sent_mag_stanag")
end