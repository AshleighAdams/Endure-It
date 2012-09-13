include( 'shared.lua' )

include("cl_inventory.lua")
// Clientside only stuff goes here
include( "cl_weapon_drawing.lua" )
include( "cl_legs.lua" )

hook.Add( "PreDrawHalos", "ShowItems", function()
    for _, ent in pairs(ents.GetAll()) do
		local add = false
		
		local lp = LocalPlayer()
		
		if not ValidEntity(ent) or not ValidEntity(lp) then return end
		
		if ent:GetPos():Distance(LocalPlayer():GetShootPos()) > 500 then continue end
		if lp:GetAimVector():Dot( (ent:GetPos() - lp:GetShootPos()):GetNormal() ) > 0.2 then continue end
		
		local base = ent.BaseClass
		while base != nil do
			if base.ClassName == "sent_base_item" then
				add = true
				break
			end
			base = base.BaseClass
		end
		
		if add or true then
			halo.Add({ent}, Color( 255, 0, 0 )) --, 5, 5, 2)
		end
    end
end )