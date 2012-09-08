if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
end

if ( CLIENT ) then

	SWEP.PrintName			= "IMI Galil"			
	SWEP.Author				= "victormeriqui & C0BRA"
	SWEP.Slot				= 3
	SWEP.SlotPos			= 1
	SWEP.IconLetter			= "v"
	
	killicon.AddFont( "rifle_ak47", "CSKillIcons", SWEP.IconLetter, Color( 255, 80, 0, 255 ) )
	
end

--SWEP.HoldType			= "s"
SWEP.Base				= "weapon_cs_base"
SWEP.Category			= "Endure-It"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/v_rif_galil.mdl"
SWEP.WorldModel			= "models/weapons/w_rif_galil.mdl"

SWEP.Weight				= 9
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false
SWEP.ViewModelFlip 		= false;

SWEP.Primary.Sound			= Sound( "Weapon_Galil.Single" )
SWEP.Primary.Recoil			= 1.5
SWEP.Primary.Damage			= 40
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.02
SWEP.Primary.ClipSize		= -1
SWEP.Primary.Delay			= 0.1
SWEP.Primary.DefaultClip	= 0
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "smg1"

SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

function SWEP:Special()
	self:EmitSound(Sound("Weapon_Glock.Slideback"));
	self.Primary.Automatic = !self.Primary.Automatic;
end

function SWEP:CanTakeMagazine(mag)
	print("ABC123")
	return mag:GetClass():StartWith("sent_mag_galil")
end

SWEP.ZoomScale = 45;
SWEP.ZoomSpeed = 0.1;
SWEP.IronMoveSpeed = 0.017;

SWEP.IronSightsPos = Vector (-3.155, 0, 1.2)
SWEP.IronSightsAng = Vector (0, 0, 0)

SWEP.OverridePos = Vector (-2, 1, -3)
SWEP.OverrideAng = Vector (0, 0, 0)

