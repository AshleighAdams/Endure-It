include( 'shared.lua' )

include("cl_inventory.lua")
// Clientside only stuff goes here
include( "cl_weapon_drawing.lua" )
include( "cl_legs.lua" )

hook.Add( "PreDrawHalos", "ShowItems", function()
	local tbl_ents = {}
    for _, ent in pairs(ents.GetAll()) do
		local add = false
		
		local lp = LocalPlayer()
		
		if not ValidEntity(ent) or not ValidEntity(lp) then continue end
		if ValidEntity(ent:GetNWEntity("Owner", NullEntity())) then continue end
		
		if ent:GetPos():Distance(LocalPlayer():GetShootPos()) > 100 then continue end
		if lp:GetAimVector():Dot( (ent:GetPos() - lp:GetShootPos()):GetNormal() ) < 0.95 then continue end
		
		local base = ent.BaseClass
		while base != nil do
			if base.ClassName == "sent_base_item" then
				add = true
				break
			end
			base = base.BaseClass
		end
		
		if add then
			table.insert(tbl_ents, ent)
		end
    end
	
	halo.Add(tbl_ents, Color( 255, 0, 0 )) --, 5, 5, 2)
end )

function ModifyBloodColor()
	local tab = {}
	tab[ "$pp_colour_addr" ] = 0
	tab[ "$pp_colour_addg" ] = 0
	tab[ "$pp_colour_addb" ] = 0
	tab[ "$pp_colour_brightness" ] = 0
	tab[ "$pp_colour_contrast" ] = 1
	tab[ "$pp_colour_colour" ] = LocalPlayer():Health() / 100
	tab[ "$pp_colour_mulr" ] = 0
	tab[ "$pp_colour_mulg" ] = 0
	tab[ "$pp_colour_mulb" ] = 0
 
	DrawColorModify( tab )
end
hook.Add("RenderScreenspaceEffects", "BloodColour", ModifyBloodColor)