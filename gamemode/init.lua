-- Sound
resource.AddFile("sound/arma2/bullet_by1.wav")
resource.AddFile("sound/arma2/bullet_by2.wav")
resource.AddFile("sound/arma2/bullet_by3.wav")
resource.AddFile("sound/arma2/bullet_by4.wav")
resource.AddFile("sound/arma2/bullet_by5.wav")
resource.AddFile("sound/arma2/bullet_by6.wav")
resource.AddFile("sound/arma2/sscrack1.wav")
resource.AddFile("sound/arma2/sscrack2.wav")

-- Models & textures
resource.AddFile("models/wystan/stanag_magazine.mdl")
resource.AddFile("models/wystan/weapons/ak47magazine.mdl")
resource.AddFile("models/wystan/weapons/m9magazine.mdl")
resource.AddFile("models/wystan/weapons/m249magazine.mdl")

resource.AddFile("materials/wystan/556.vmf")
resource.AddFile("materials/wystan/556_normal.vtf")
resource.AddFile("materials/wystan/weapons/AK47/47_mag.vmt")
resource.AddFile("materials/wystan/weapons/AK47/Magazine.vmt")
resource.AddFile("materials/wystan/weapons/M9/frame.vmt")
resource.AddFile("materials/wystan/weapons/M9/frame_normal.vtf")
resource.AddFile("materials/wystan/weapons/M249/boxmag.vmt")
resource.AddFile("materials/wystan/weapons/M249/bullet.vmt")


AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( 'shared.lua' )
include("sv_inventory.lua")

// Serverside only stuff goes here

/*---------------------------------------------------------
   Name: gamemode:PlayerLoadout( )
   Desc: Give the player the default spawning weapons/ammo
---------------------------------------------------------*/
function GM:PlayerLoadout( pl )
	pl:Give( "weapon_deagle" )
	pl:Give( "weapon_m4a1_sd" )
end