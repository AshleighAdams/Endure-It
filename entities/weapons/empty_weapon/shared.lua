
AddCSLuaFile( "shared.lua" )

SWEP.Author			= ""
SWEP.Contact		= ""
SWEP.PrintName		= "Hands"
SWEP.Purpose		= ""
SWEP.Instructions	= ""


SWEP.DrawAmmo		= false
SWEP.DrawCrosshair	= false
SWEP.ViewModelFOV	= 62
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/weapons/v_pistol.mdl"
SWEP.WorldModel		= "models/weapons/w_357.mdl"

--SWEP.AnimPrefix		= "python"

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= false

SWEP.Primary.ClipSize		= -1					// Size of a clip
SWEP.Primary.DefaultClip	= -1				// Default number of bullets in a clip
SWEP.Primary.Automatic		= false				// Automatic/Semi Auto
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1				// Size of a clip
SWEP.Secondary.DefaultClip	= -1				// Default number of bullets in a clip
SWEP.Secondary.Automatic	= false				// Automatic/Semi Auto
SWEP.Secondary.Ammo			= "none"

SWEP.HoldType 				= "normal"

function SWEP:Initialize()
	self:SetWeaponHoldType( self.HoldType )
end

function SWEP:Deploy()
    self.Owner:DrawViewModel(false)
	self:SetNoDraw(true)
end

function SWEP:Reload()
end

function SWEP:Think()	
end

function SWEP:PrimaryAttack()	
end

function SWEP:SecondaryAttack()
end