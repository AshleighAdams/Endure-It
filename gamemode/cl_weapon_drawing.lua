/*
    Jvs:this script will allow you to see your/others weapons directly on the body when in thirdperson
    every weapon needs a different bone/drawfunction/boneoffset,however,drawfunction can be nil
    boneoffsets will be retrieved from a custom table,so,if there's a pistol,it will draw it on the hips,heavy weapons on the back etc etc
    WARNING:drawfunction will NOT draw the model,it will draw an effect or whatever you want,the model is drawn before this function gets called
    i know,there's no gui/derma to modify the bones,i'm used to modify them directly in the .lua file,just look at the these hl2 weapons examples
*/
 
local holsteredgunsconvar = CreateConVar( "cl_holsteredguns", "1", { FCVAR_ARCHIVE, }, "Enable/Disable the rendering of the weapons on any player" )
 
local NEXT_WEAPONS_UPDATE=CurTime();
 
local physgunmat=Material("sprites/physg_glow1")
local physgunmat1=Material("sprites/physg_glow2")
 
local weaponsinfos={}
weaponsinfos["weapon_physcannon"]={}
weaponsinfos["weapon_physcannon"].Model="models/weapons/w_physics.mdl"
weaponsinfos["weapon_physcannon"].Bone="ValveBiped.Bip01_Spine1"
weaponsinfos["weapon_physcannon"].BoneOffset={Vector(6,15,0),Angle(90,180,0)}//offset,weapon angle
weaponsinfos["weapon_physcannon"].Priority="weapon_physgun" //this means that if the weapon_physgun can be drawn,we will not
 
weaponsinfos["weapon_physgun"]={}
weaponsinfos["weapon_physgun"].Model="models/weapons/w_physics.mdl"
weaponsinfos["weapon_physgun"].Bone="ValveBiped.Bip01_Spine1"
weaponsinfos["weapon_physgun"].DrawFunction=function(ent) end /* draw custom core to make it look like it's on */ 
weaponsinfos["weapon_physgun"].BoneOffset={Vector(6,15,0),Angle(90,180,0)}//offset,weapon angle
weaponsinfos["weapon_physgun"].Skin=1;  //we can set custom skin too,but only once,remember that
 
 
weaponsinfos["weapon_physgun"].DrawFunction=function(ent)
    local attachment=ent:GetAttachment( 1)
    local StartPos = attachment.Pos + attachment.Ang:Forward()*4
    render.SetMaterial(physgunmat)
    render.DrawSprite(attachment.Pos,20,20,Color(255,255,255,255));
    render.SetMaterial(physgunmat1)
    render.DrawSprite(StartPos,20,20,Color(255,255,255,255));   
end
 
 
weaponsinfos["weapon_pistol"]={}
weaponsinfos["weapon_pistol"].Model="models/weapons/W_pistol.mdl"
weaponsinfos["weapon_pistol"].Bone="ValveBiped.Bip01_Pelvis"
weaponsinfos["weapon_pistol"].BoneOffset={Vector(0,-8,0),Angle(0,90,0)}//offset,weapon angle
 
weaponsinfos["weapon_357"]={}
weaponsinfos["weapon_357"].Model="models/weapons/W_357.mdl"
weaponsinfos["weapon_357"].Bone="ValveBiped.Bip01_Pelvis"
weaponsinfos["weapon_357"].BoneOffset={Vector(-5,8,0),Angle(0,270,0)}//offset,weapon angle
weaponsinfos["weapon_357"].Priority="gmod_tool"
 
weaponsinfos["gmod_tool"]={}
weaponsinfos["gmod_tool"].Bone="ValveBiped.Bip01_Pelvis"
weaponsinfos["gmod_tool"].BoneOffset={Vector(-5,8,0),Angle(0,270,0)}//offset,weapon angle
 
 
weaponsinfos["weapon_frag"]={}
weaponsinfos["weapon_frag"].Model="models/Items/grenadeAmmo.mdl"
weaponsinfos["weapon_frag"].Bone="ValveBiped.Bip01_Pelvis"
weaponsinfos["weapon_frag"].BoneOffset={Vector(3,-5,6),Angle(-95,0,0)}//offset,weapon angle
 
weaponsinfos["weapon_slam"]={}
weaponsinfos["weapon_slam"].Model="models/weapons/w_slam.mdl"
weaponsinfos["weapon_slam"].Bone="ValveBiped.Bip01_Spine2"
weaponsinfos["weapon_slam"].BoneOffset={Vector(-9,0,-7),Angle(270,90,-25)}//offset,weapon angle
 
weaponsinfos["weapon_crowbar"]={}
weaponsinfos["weapon_crowbar"].Model="models/weapons/w_crowbar.mdl"
weaponsinfos["weapon_crowbar"].Bone="ValveBiped.Bip01_Spine1"
weaponsinfos["weapon_crowbar"].BoneOffset={Vector(3,0,0),Angle(0,0,45)}//offset,weapon angle
 
weaponsinfos["weapon_stunstick"]={}
weaponsinfos["weapon_stunstick"].Model="models/weapons/W_stunbaton.mdl"
weaponsinfos["weapon_stunstick"].Bone="ValveBiped.Bip01_Spine1"
weaponsinfos["weapon_stunstick"].BoneOffset={Vector(3,0,0),Angle(0,0,-45)}//offset,weapon angle
 
weaponsinfos["weapon_shotgun"]={}
weaponsinfos["weapon_shotgun"].Model="models/weapons/W_shotgun.mdl"
weaponsinfos["weapon_shotgun"].Bone="ValveBiped.Bip01_R_Clavicle"
weaponsinfos["weapon_shotgun"].BoneOffset={Vector(10,5,2),Angle(0,90,0)}//offset,weapon angle
 
weaponsinfos["weapon_rpg"]={}
weaponsinfos["weapon_rpg"].Model="models/weapons/w_rocket_launcher.mdl"
weaponsinfos["weapon_rpg"].Bone="ValveBiped.Bip01_L_Clavicle"
weaponsinfos["weapon_rpg"].BoneOffset={Vector(-16,5,0),Angle(90,90,90)}//offset,weapon angle
 
weaponsinfos["weapon_smg1"]={}
weaponsinfos["weapon_smg1"].Model="models/weapons/w_smg1.mdl"
weaponsinfos["weapon_smg1"].Bone="ValveBiped.Bip01_Spine1"
weaponsinfos["weapon_smg1"].BoneOffset={Vector(5,0,-5),Angle(0,0,230)}//offset,weapon angle
 
weaponsinfos["weapon_ar2"]={}
weaponsinfos["weapon_ar2"].Model="models/weapons/W_irifle.mdl"
weaponsinfos["weapon_ar2"].Bone="ValveBiped.Bip01_R_Clavicle"
weaponsinfos["weapon_ar2"].BoneOffset={Vector(-5,0,7),Angle(0,270,0)}//offset,weapon angle
 
weaponsinfos["weapon_crossbow"]={}
weaponsinfos["weapon_crossbow"].Model="models/weapons/W_crossbow.mdl"
weaponsinfos["weapon_crossbow"].Bone="ValveBiped.Bip01_L_Clavicle"
weaponsinfos["weapon_crossbow"].BoneOffset={Vector(0,5,-5),Angle(180,90,0)}//offset,weapon angle

local function LoadOthers()
	for k,v in pairs(weapons.GetList()) do
		if not v.HoldType then continue end
		if v.HoldType == "ar2" or v.HoldType == "smg" then
			weaponsinfos[v.ClassName] = table.Copy(weaponsinfos["weapon_ar2"])
			weaponsinfos[v.ClassName].Model = v.WorldModel
			weaponsinfos[v.ClassName].BoneOffset[1] = Vector(20,5,5)
			weaponsinfos[v.ClassName].BoneOffset[2] = Angle(97,180,270)
		elseif v.HoldType == "pistol" then
			weaponsinfos[v.ClassName] = table.Copy(weaponsinfos["weapon_pistol"])
			weaponsinfos[v.ClassName].Model = v.WorldModel
			weaponsinfos[v.ClassName].BoneOffset[1] = Vector(-5,-9,-3)
			weaponsinfos[v.ClassName].BoneOffset[2] = Angle(0,270,0)
		end
	end
end

hook.Add("InitPostEntity", "load_others_guns", LoadOthers) 

LoadOthers()

function LPGB(dotrace)
    if !dotrace then
    for i=0,LocalPlayer():GetBoneCount()-1 do
        print(LocalPlayer():GetBoneName(i))
    end
    else
    local entity=LocalPlayer():GetEyeTrace().Entity
    if !IsValid(entity) then return end
    for i=0,entity:GetBoneCount()-1 do
        print(entity:GetBoneName(i))
    end
    end
end
 
local function CalcOffset(pos,ang,off)
        return pos + ang:Right() * off.x + ang:Forward() * off.y + ang:Up() * off.z;
end
     
local function clhasweapon(pl,weaponclass)
    for i,v in pairs(pl:GetWeapons()) do
        if string.lower(v:GetClass())==string.lower(weaponclass) then return true end
    end
     
    return false;
end
 
local function clgetweapon(pl,weaponclass)
    for i,v in pairs(pl:GetWeapons()) do
        if string.lower(v:GetClass())==string.lower(weaponclass) then return v end
    end
     
    return nil;
end
 
local function playergettf2class(ply)
    return ply:GetPlayerClass()
end
 
local function IsTf2Class(ply)
    return LocalPlayer().IsHL2 && !LocalPlayer():IsHL2()
end
 
local function GetHolsteredWeaponTable(ply,indx)
    local class=IsTf2Class(ply) and playergettf2class(ply) or nil
    if !class then  return weaponsinfos[indx]
    else return (weaponsinfos[indx] && weaponsinfos[indx][class]) and weaponsinfos[indx][class] or nil
    end
end
 
local function thinkdamnit()
    if !holsteredgunsconvar:GetBool() then return end
    for _,pl in pairs(player.GetAll()) do
        if !IsValid(pl) then continue end
         
        if !pl.CL_CS_WEPS then
            pl.CL_CS_WEPS={}
        end
         
        if !pl:Alive() then pl.CL_CS_WEPS={} continue end
         
        if NEXT_WEAPONS_UPDATE<CurTime() then
            pl.CL_CS_WEPS={} 
            NEXT_WEAPONS_UPDATE=CurTime()+5
        end
         
		for k, v in pairs(pl:GetInventory().Generic or {}) do /* Our inventroy */
			if v:GetClass():StartWith("sent_weapon_") then
				local class = v.WeaponClass
				local wc = weapons.GetList[class]
				
				if v.CL_CS_WEPS[class] then continue end
			end
		end
		 
        for i,v in pairs(pl:GetWeapons())do
            if !IsValid(v) then continue; end
             
            if pl.CL_CS_WEPS[v:GetClass()] then continue end
             
            if !pl.CL_CS_WEPS[v:GetClass()] then
                local worldmodel=v.WorldModelOverride or v.WorldModel //attempt to pick the model from a swep
                local attachedwmodel=v.AttachedWorldModel;
                 
                if GetHolsteredWeaponTable(pl,v:GetClass()) && GetHolsteredWeaponTable(pl,v:GetClass()).Model then //damnit,it's not a swep,then try to get it from our local table
                    worldmodel=GetHolsteredWeaponTable(pl,v:GetClass()).Model
                end
                if !worldmodel || worldmodel=="" then continue end; //allright,this weapon is not supposed to show up
                 
                 
                pl.CL_CS_WEPS[v:GetClass()]=ClientsideModel(worldmodel,RENDERGROUP_OPAQUE)
                pl.CL_CS_WEPS[v:GetClass()]:SetNoDraw(true)
                pl.CL_CS_WEPS[v:GetClass()]:SetSkin(v:GetSkin())
                pl.CL_CS_WEPS[v:GetClass()]:SetColor(v:GetColor())
                 
                if GetHolsteredWeaponTable(pl,v:GetClass()) && GetHolsteredWeaponTable(pl,v:GetClass()).Scale then
                    pl.CL_CS_WEPS[v:GetClass()]:SetModelScale(GetHolsteredWeaponTable(pl,v:GetClass()).Scale);
                end
                 
                if GetHolsteredWeaponTable(pl,v:GetClass()) && GetHolsteredWeaponTable(pl,v:GetClass()).BBP then
                    pl.CL_CS_WEPS[v:GetClass()].BuildBonePositions=GetHolsteredWeaponTable(pl,v:GetClass()).BBP;
                end
                 
                if v.MaterialOverride || v:GetMaterial() then
                    pl.CL_CS_WEPS[v:GetClass()]:SetMaterial(v.MaterialOverride || v:GetMaterial())
                end
                if worldmodel == "models/weapons/w_models/w_shotgun.mdl" then
                    pl.CL_CS_WEPS[v:GetClass()]:SetMaterial("models/weapons/w_shotgun_tf/w_shotgun_tf")
                end
                 
                pl.CL_CS_WEPS[v:GetClass()].WModelAttachment=v.WModelAttachment
                pl.CL_CS_WEPS[v:GetClass()].WorldModelVisible=v.WorldModelVisible
                 
                 
                if attachedwmodel then
                    pl.CL_CS_WEPS[v:GetClass()].AttachedModel=ClientsideModel(attachedwmodel,RENDERGROUP_OPAQUE)
                    pl.CL_CS_WEPS[v:GetClass()].AttachedModel:SetNoDraw(true)
                    pl.CL_CS_WEPS[v:GetClass()].AttachedModel:SetSkin(v:GetSkin())
                    pl.CL_CS_WEPS[v:GetClass()].AttachedModel:SetParent(pl.CL_CS_WEPS[v:GetClass()])
                    pl.CL_CS_WEPS[v:GetClass()].AttachedModel:AddEffects(EF_BONEMERGE|EF_BONEMERGE_FASTCULL|EF_PARENT_ANIMATES)
                end
            end
        end
    end
end
 
local function playerdrawdamnit(pl,legs)
    if !holsteredgunsconvar:GetBool() then return end
    if !IsValid(pl) then return end
    if !pl.CL_CS_WEPS then return end
    for i,v in pairs(pl.CL_CS_WEPS) do
 
             
        if GetHolsteredWeaponTable(pl,i) && (pl:GetActiveWeapon()==NULL || pl:GetActiveWeapon():GetClass()~=i) && clhasweapon(pl,i) then
            if GetHolsteredWeaponTable(pl,i).Priority then
                local priority=GetHolsteredWeaponTable(pl,i).Priority
                local bol=GetHolsteredWeaponTable(pl,priority) && (pl:GetActiveWeapon()==NULL || pl:GetActiveWeapon():GetClass()!=priority) && clhasweapon(pl,priority)
                if bol then continue; end
            end
             
            local oldpl=pl;
            local wep=clgetweapon(oldpl,i)
             
            if legs && IsValid(legs) then
            pl=legs;
            end
             
            if legs && IsValid(legs) && (string.find(string.lower(GetHolsteredWeaponTable(oldpl,i).Bone),"spine") or string.find(string.lower(GetHolsteredWeaponTable(oldpl,i).Bone),"clavi") ) then
            pl=oldpl;
            continue;
            end
             
            local bone=pl:LookupBone(GetHolsteredWeaponTable(oldpl,i).Bone or "")
            if !bone then pl=oldpl;continue; end
 
             
            local matrix = pl:GetBoneMatrix(bone)
            if !matrix then pl=oldpl;continue; end
            local pos = matrix:GetTranslation()
            local ang = matrix:GetAngles()
            local pos=CalcOffset(pos,ang,GetHolsteredWeaponTable(oldpl,i).BoneOffset[1])
            if GetHolsteredWeaponTable(oldpl,i).Skin then v:SetSkin(GetHolsteredWeaponTable(oldpl,i).Skin) end
             
            v:SetRenderOrigin(pos)
             
            ang:RotateAroundAxis(ang:Forward(),GetHolsteredWeaponTable(oldpl,i).BoneOffset[2].p)
            ang:RotateAroundAxis(ang:Up(),GetHolsteredWeaponTable(oldpl,i).BoneOffset[2].y)
            ang:RotateAroundAxis(ang:Right(),GetHolsteredWeaponTable(oldpl,i).BoneOffset[2].r)
             
            v:SetRenderAngles(ang)
            if v.WorldModelVisible==nil || (v.WorldModelVisible!=false) then
                v:DrawModel();
            end
             
            if IsValid(v.AttachedModel) then
                v.AttachedModel:DrawModel();
            end
            if v.WModelAttachment && multimodel then
                multimodel.Draw(v.WModelAttachment, wep, {origin=pos, angles=ang})
                multimodel.DoFrameAdvance(v.WModelAttachment, CurTime(),wep)
            end
             
            if GetHolsteredWeaponTable(oldpl,i).DrawFunction then
                GetHolsteredWeaponTable(oldpl,i).DrawFunction(v,oldpl)
            end
            pl=oldpl;
        end
    end
end
 
local function drawlegsdamnit(legs)
    playerdrawdamnit(LocalPlayer(),legs)
end
 
hook.Add("PostLegsDraw","HG_DrawOnLegs",drawlegsdamnit)
hook.Add("Think","HG_Think",thinkdamnit)
hook.Add("PostPlayerDraw","HG_Draw",playerdrawdamnit)