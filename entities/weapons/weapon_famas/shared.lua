if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
end

if ( CLIENT ) then

	SWEP.PrintName			= "MAS FAMAS G2"			
	SWEP.Author				= "victormeriqui & C0BRA"
	SWEP.Slot				= 3
	SWEP.SlotPos			= 1
	SWEP.IconLetter			= "t"
	SWEP.MagBone 			= "ValveBiped.weapon_bone_Clip"
	
	killicon.AddFont( "rifle_ak47", "CSKillIcons", SWEP.IconLetter, Color( 255, 80, 0, 255 ) )
	
end

SWEP.HoldType			= "ar2"
SWEP.Base				= "weapon_cs_base"
SWEP.Category			= "Endure-It"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/v_rif_famas.mdl"
SWEP.WorldModel			= "models/weapons/w_rif_famas.mdl"

SWEP.Weight				= 9
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false
SWEP.ViewModelFlip 		= false;

SWEP.Primary.Sound			= Sound( "Weapon_Famas.Single" )
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
	return mag:GetClass():StartWith("sent_mag_stanag")
end

SWEP.ZoomScale = 55;
SWEP.ZoomSpeed = 0.1;
SWEP.IronMoveSpeed = 0.02;

SWEP.IronSightsPos = Vector (-2.3634, 0, 2.3029)
SWEP.IronSightsAng = Vector (0, 0, 0)
