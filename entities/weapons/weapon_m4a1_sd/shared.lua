if ( SERVER ) then

	AddCSLuaFile( "shared.lua" )
	
end

if ( CLIENT ) then

	SWEP.PrintName			= "M16 Silenced"			
	SWEP.Author				= "Counter-Strike"
	SWEP.Slot				= 3
	SWEP.SlotPos			= 1
	SWEP.IconLetter			= "w"
	SWEP.MagBone 			= "v_weapon.m4_Clip"
	
	killicon.AddFont( "rifle_m4", "CSKillIcons", SWEP.IconLetter, Color( 255, 80, 0, 255 ) )
	
end

SWEP.HoldType			= "smg" -- "ar2" -- smg doesn't bug out for now TODO: put back
SWEP.Base				= "weapon_cs_base"
SWEP.Category			= "Counter-Strike"
SWEP.Suppressed = true

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/v_rif_m4a1.mdl"
SWEP.WorldModel			= "models/weapons/w_rif_m4a1.mdl" --_silencer.mdl"
SWEP.PostWorldModel		= "models/weapons/w_rif_m4a1_silencer.mdl"

--SWEP.AnimPrefix         = "ar2"

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Primary.Sound			= Sound( "Weapon_M4A1.Silenced" )
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

SWEP.ZoomScale = 30;
SWEP.ZoomSpeed = 1;

function SWEP:Special()
	self:EmitSound(Sound("Weapon_Glock.Slideback"));
	self.Primary.Automatic = !self.Primary.Automatic;
end

SWEP.OverridePos = Vector (1.0621, 0, -2)
SWEP.OverrideAng = Vector (0.5698, 2.4502, 0)


SWEP.IronSightsPos = Vector (3.6317, -3.6443, 2.7934)
SWEP.IronSightsAng = Vector (0, 0, 0)
SWEP.IronMoveSpeed = 0.02;

function SWEP:CanTakeMagazine(mag)
	return mag:GetClass():StartWith("sent_mag_stanag")
end