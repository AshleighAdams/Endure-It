if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
end

if ( CLIENT ) then

	SWEP.PrintName			= "Steyr TMP"			
	SWEP.Author				= "victormeriqui & C0BRA"
	SWEP.Slot				= 2
	SWEP.SlotPos			= 3
	SWEP.IconLetter			= "d"
	
	killicon.AddFont( "smg_tmp", "CSKillIcons", SWEP.IconLetter, Color( 255, 80, 0, 255 ) )
	
end

SWEP.HoldType			= "ar2"
SWEP.Base				= "weapon_cs_base"
SWEP.Category			= "Endure-It"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/v_smg_tmp.mdl"
SWEP.WorldModel			= "models/weapons/w_smg_tmp.mdl"

SWEP.Weight				= 6
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Primary.Sound			= Sound( "Weapon_tmp.Single" )
SWEP.Primary.Recoil			= 0.4
SWEP.Primary.Damage			= 30
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.04
SWEP.Primary.ClipSize		= 21
SWEP.Primary.Delay			= 0.05
SWEP.Primary.DefaultClip	= 20
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "smg1"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.ZoomScale = 70;
SWEP.ZoomSpeed = 0.2;
SWEP.IronMoveSpeed = 0.02;

SWEP.IronSightsPos = Vector (2, 0, 2.6366)
SWEP.IronSightsAng = Vector (0, 0, 0)

SWEP.OverridePos = Vector (1.2711, 0, -2)
SWEP.OverrideAng = Vector (0, 0, 0)



