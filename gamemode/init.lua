
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

	pl:GiveAmmo( 255, "Pistol", true )
	pl:GiveAmmo( 255, "SMG1", true )
	
	pl:Give( "weapon_deagle" )
	pl:Give( "weapon_awp" )
	
end