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
		
		if not IsValid(ent) or not IsValid(lp) then continue end
		if IsValid(ent:GetNWEntity("Owner", Entity(-1))) then continue end
		
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
	local lp = LocalPlayer()
	
	lp.TargetContrast = math.Clamp(LocalPlayer():Health() / 33, 0, 1)
	lp.CurrentContrast = lp.CurrentContrast or 1
	lp.CurrentContrast = math.Approach(lp.CurrentContrast, lp.TargetContrast, FrameTime() / 3)
	
	local tab = {}
	tab[ "$pp_colour_addr" ] = 0
	tab[ "$pp_colour_addg" ] = 0
	tab[ "$pp_colour_addb" ] = 0
	tab[ "$pp_colour_brightness" ] = 0
	tab[ "$pp_colour_contrast" ] = lp.CurrentContrast
	tab[ "$pp_colour_colour" ] = math.Clamp(LocalPlayer():Health() / 100, 0, 1)
	tab[ "$pp_colour_mulr" ] = 0
	tab[ "$pp_colour_mulg" ] = 0
	tab[ "$pp_colour_mulb" ] = 0
	
	if not LocalPlayer():Alive() or LocalPlayer():Health() <= 0 then
		tab[ "$pp_colour_contrast" ] = 0
		if LocalPlayer().ORIG_VOL == nil then
			print("Setting volume to 0")
			LocalPlayer().ORIG_VOL = GetConVar("volume"):GetFloat()
			RunConsoleCommand("volume", "0")
		end
	else
		if LocalPlayer().ORIG_VOL != nil then
			RunConsoleCommand("volume", tostring(LocalPlayer().ORIG_VOL))
			LocalPlayer().ORIG_VOL = nil
		end
	end
	
	DrawColorModify( tab )
end
hook.Add("RenderScreenspaceEffects", "BloodColour", ModifyBloodColor)

function HideThings( name )
    if (name == "CHudDamageIndicator" ) then
        return false
    end
end
hook.Add( "HUDShouldDraw", "HideThings", HideThings )

function PutFlashlights()
	for k,v in pairs(player.GetAll()) do
		local fl = v:GetNWEntity("Flashlight")
		
		
		if not IsValid(fl) then continue end
		
		fl:SetPos(v:GetShootPos() + v:GetAimVector() * 10 + v:GetAimVector():Angle():Right() * 3)
		fl:SetAngles(v:GetAimVector():Angle())
		v.FlashLerp = v.FlashLerp or 0
		
		if v:GetVelocity():Length() > v:GetWalkSpeed() * 1.2 then
			v.FlashLerp = v.FlashLerp + 0.15
		else
			v.FlashLerp = v.FlashLerp - 0.1
		end
		v.FlashLerp = math.Clamp(v.FlashLerp, 0, 1)
		
		// wobble
		local vel = v:GetVelocity()
		vel.z = 0
		local intensity = v.FlashLerp
		
		if intensity == 0 then
			v.FlashInc = 0 -- reset this
		end
		
		v.FlashInc = v.FlashInc or 0
		v.FlashInc = v.FlashInc + vel:Length() / 5000
		
		local rt = v.FlashInc
		local wob_yaw = math.sin(rt) * intensity * 5
		local wob_p = math.cos(rt * 2) * intensity * 2
		

		local lp = LocalPlayer()
		if v == lp and IsValid(lp:GetViewModel()) then
			local vm = lp:GetViewModel()
			
			local ang = vm:GetAngles() - lp:GetAimVector():Angle()
			if lp:GetActiveWeapon().ViewModelFlip then
				ang.y = -ang.y
			end
			ang = lp:GetAimVector():Angle() + ang
			
			fl:SetAngles(ang)
			fl:SetPos(lp:GetShootPos() + ang:Right() * 3 + ang:Forward() * 5 + ang:Up() * -3)
		else
			fl:SetAngles(v:GetAimVector():Angle() + Angle(20 * v.FlashLerp + wob_p, wob_yaw, 0))
		end
	end
end
hook.Add("Think", "PutFlashlights", PutFlashlights)