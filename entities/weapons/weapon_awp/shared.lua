if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
end

if ( CLIENT ) then

	SWEP.PrintName			= "AI AWP"			
	SWEP.Author				= "victormeriqui & C0BRA"

	SWEP.Slot				= 1
	SWEP.SlotPos			= 1
	SWEP.IconLetter			= "f"
	
	killicon.AddFont( "sniper_awp", "CSKillIcons", SWEP.IconLetter, Color( 255, 80, 0, 255 ) )

end

SWEP.HoldType			= "ar2"
SWEP.Base				= "weapon_cs_base"
SWEP.Category			= "Endure-It"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModelFlip		= true

SWEP.ViewModel			= "models/weapons/v_snip_awp.mdl"
SWEP.WorldModel			= "models/weapons/w_snip_awp.mdl"

SWEP.UseBullet = SniperBullet

SWEP.Weight				= 9
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false
SWEP.DontPrimaryAttackAnim = true

SWEP.Primary.Sound			= Sound( "Weapon_Awp.Single" )
SWEP.Primary.Recoil			= 1
SWEP.Primary.Damage			= 95
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 1.5
SWEP.Primary.ClipSize		= 11
SWEP.Primary.Delay			= 1.2
SWEP.Primary.DefaultClip	= 10
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "smg1"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.ZoomScale = 35;
SWEP.ZoomSpeed = 0.4;
SWEP.IronMoveSpeed = 0.02;

SWEP.IronSightsPos = Vector (5.5862, -4.5, 2.0838)
SWEP.IronSightsAng = Vector (0, 0, 0)

function SWEP:PrimaryAttack()
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	
	if ( !self:CanPrimaryAttack() ) then return end
	
	// Play shoot sound
	self.Weapon:EmitSound( self.Primary.Sound )
	
	// Shoot the bullet
	local cone = self.Primary.Cone
	if not self.Zoomed then
		cone = 0.5
	end
	self:CSShootBullet( self.Primary.Damage, self.Primary.Recoil, self.Primary.NumShots, cone )
	
	// Remove 1 bullet from our clip
	self:TakePrimaryAmmo( 1 )
	
	if ( self.Owner:IsNPC() ) then return end
	
	// Punch the player's view
	self.Owner:ViewPunch( Angle( math.Rand(-0.2,-0.1) * self.Primary.Recoil, math.Rand(-0.1,0.1) *self.Primary.Recoil, 0 ) )
	
	// In singleplayer this function doesn't get called on the client, so we use a networked float
	// to send the last shoot time. In multiplayer this is predicted clientside so we don't need to 
	// send the float.
	if ( (SinglePlayer() && SERVER) || CLIENT ) then
		self.Weapon:SetNetworkedFloat( "LastShootTime", CurTime() )
	end
	
	self.NeedsReload = true
	
	/*
	self.Owner:SetFOV(0, 0);	
	self:SetNetworkedBool("Reloading", true);
	local time = self.Owner:GetViewModel():SequenceDuration();
	timer.Simple(time, function() 
		self.Owner:SetFOV(self.ZoomScale, self.ZoomSpeed);	
		self:SetNetworkedBool("Reloading", false); 
	end);
	*/
end


function SWEP:Think()
	if self.UseBullet != SniperBullet then
		self.UseBullet = SniperBullet
	end
	if self.NeedsReload and not self.Owner:KeyDown(IN_ATTACK) then
		self.NeedsReload = false
		self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
		if ( (SinglePlayer() && SERVER) || CLIENT ) then
			self.Weapon:SetNetworkedFloat( "LastShootTime", CurTime() )
		end
	
		self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
		self.Owner:SetAnimation( PLAYER_ATTACK1 )
	end

	if self.IsZoomedIn && !self:GetNetworkedBool("Reloading") then
		self.IronTime = self.IronTime + self.IronMoveSpeed
	else
		self.IronTime = self.IronTime - self.IronMoveSpeed
	end
	
	self.IronTime = math.Clamp(self.IronTime, 0, 1)
	
	if (self.Owner:KeyDown(IN_ATTACK2) && !self.Owner:KeyDown(IN_USE)) and not self.IsZoomedIn then
		self.SwayScale = 0.5;
		self.BobScale = 0.5;
		self.Owner:SetFOV(self.ZoomScale, self.ZoomSpeed)
		self.IsZoomedIn = true
		self:SetNWBool("zoomed", true)
	elseif not self.Owner:KeyDown(IN_ATTACK2) and self.IsZoomedIn then
		self.SwayScale = 2;
		self.BobScale = 2;
		self.Owner:SetFOV(0, self.ZoomSpeed)
		self.IsZoomedIn = false
	end	
end	

function SWEP:Reload()
	
	self.Weapon:DefaultReload( ACT_VM_RELOAD );
		
end

local sin, cos = math.sin, math.cos; --SPEED!
local function DrawCircle(x, y, rad, qual, color, xmod, tex)
		
	local matrix = {};
	local vert = 1;
	for i = 0, math.pi*2, qual do
		
		matrix[vert] = {x = x + math.cos(i)*(rad+xmod), y = y + math.sin(i)*rad};
		vert = vert+1;

	end 
	
	surface.SetDrawColor(color)	
	surface.SetTexture(tex)
	
	--surface.DrawPoly(matrix)
end

if CLIENT then
	SWEP.ScopeRT = SWEP.ScopeRT or GetRenderTarget("ei_scope_", 1024, 1024, true)
	/*
	local TEXTURE_FLAGS_CLAMP_S = 0x0004
	local TEXTURE_FLAGS_CLAMP_T = 0x0008

	SWEP.ScopeRT = GetRenderTargetEx("testRTs",
		512,
		512,
		RT_SIZE_NO_CHANGE,
		MATERIAL_RT_DEPTH_SEPERATE,
		0, --TEXTURE_FLAGS_CLAMP_S | TEXTURE_FLAGS_CLAMP_T,
		CREATERENDERTARGETFLAGS_UNFILTERABLE_OK | CREATERENDERTARGETFLAGS_HDR
	)

	
	SWEP.mat = CreateMaterial("ei_scope_mat", "UnlitGeneric", {
		["$basetexture"] = SWEP.ScopeRT:GetName(),
		["$ignorez"] = 1,
		["$vertexcolor"] = 1,
		["$vertexalpha"] = 1,
		["$nolod"] = 1
	})
	_G.FUCKU = SWEP.mat
	*/
	--$selfillum
	Material("models/weapons/v_models/snip_awp/v_awp_scope"):SetTexture("$basetexture", SWEP.ScopeRT)
	Material("models/weapons/v_models/snip_awp/v_awp_scope"):SetUndefined("$envmap")
	Material("models/weapons/v_models/snip_awp/v_awp_scope"):SetUndefined("$envmapmask")
	Material("models/weapons/v_models/snip_awp/v_awp_scope"):SetInt("$fullbright", 1)
	Material("models/weapons/v_models/snip_awp/v_awp_scope"):SetShader("UnlitGeneric")
	
	--Material("models/weapons/v_models/snip_awp/v_awp_scope"):SetTexture("$basetexture", Material"models/debug/debugwhite":GetTexture("$basetexture"))
end

local OffsetClicksY = {}
OffsetClicksY[1] = Angle(0.02, 0, 0)
OffsetClicksY[2] = Angle(0.035, 0, 0)
OffsetClicksY[3] = Angle(0.085, 0, 0)
OffsetClicksY[4] = Angle(0.125, 0, 0)
OffsetClicksY[5] = Angle(0.15, 0, 0)
OffsetClicksY[6] = Angle(0.25, 0, 0)
OffsetClicksY[7] = Angle(0.32, 0, 0)
OffsetClicksY[8] = Angle(0.4, 0, 0)
OffsetClicksY[9] = Angle(0.49, 0, 0)
OffsetClicksY[10] = Angle(0.59, 0, 0)
OffsetClicksY[11] = Angle(0.74, 0, 0)
OffsetClicksY[12] = Angle(0.91, 0, 0)
OffsetClicksY[13] = Angle(1.1, 0, 0)
OffsetClicksY[14] = Angle(1.324, 0, 0)

function SWEP:DrawHUD()
	local Cam = {}
	
	self.Zero.ClicksY = math.Clamp(self.Zero.ClicksY, 0, 14)
	
	self.LastClicksY = self.LastClicksY or 0
	if self.LastClicksY != self.Zero.ClicksY then
		self.LastClicksY = self.Zero.ClicksY
		chat.AddText("Zeroing at ", Color(255, 127, 0), tostring(self.Zero.ClicksY * 100), " meters")
	end
	
	if self.IronTime < 0.1 then return end
	
	self.Zero.ClicksY = self.Zero.ClicksY or 0
	self.Zero.ClicksX = self.Zero.ClicksX or 0
	
	Cam.angles = LocalPlayer():EyeAngles() + (OffsetClicksY[self.Zero.ClicksY] or Angle(0,0,0)) + Angle(0, self.Zero.ClicksX/300 * -1, 0)
    Cam.origin = LocalPlayer():GetShootPos()
    
	local sizex = 800
	local sizey = 800
	
	Cam.x = 0-- - sizex / 2;
    Cam.y = 0-- - sizey / 2;
    Cam.w = 1024;
    Cam.h = 1024;
	
	Cam.drawviewmodel = false;
	Cam.zfar = 2000 * 16
	
	Cam.fov = 1;
	Cam.zfar = 2000 * 16;

	if self.IronTime == 1 then
		self.ViewModelFlip = false
	else
		self.ViewModelFlip = true
	end
	
	local oldrt = render.GetRenderTarget()
	render.SetRenderTarget(self.ScopeRT)
		local w, h = ScrW(), ScrH()
		render.SetViewPort(0, 0, 1024, 1024)
		render.RenderView(Cam)
		
		surface.SetDrawColor(0, 0, 0, 255)
		--surface.DrawLine(0, 512 + 25, 1024*2, 512+25)
		
		local cx = w / 2
		local cy = h / 2
		
		surface.DrawLine(cx, 0, cx, h)
		surface.DrawLine(0, cy, w, cy)
		
		
		for i = 1, 10 do
			local mildot_size = 12
			local spacing = (1/Cam.fov * 170) * i --57 * i
			local spacing_half = spacing - (1/Cam.fov * 170) * 0.5
			
			surface.DrawLine(cx - mildot_size, cy + spacing, cx + mildot_size, cy + spacing) // down
			surface.DrawLine(cx - mildot_size / 2, cy + spacing_half, cx + mildot_size / 2, cy + spacing_half) // down half
			surface.DrawLine(cx - mildot_size, cy - spacing, cx + mildot_size, cy - spacing) // up
			surface.DrawLine(cx - mildot_size / 2, cy - spacing_half, cx + mildot_size / 2, cy - spacing_half) // up half
			
			spacing = spacing *  (w / h)
			spacing_half = spacing_half * (w / h)
			mildot_size = mildot_size * (h / w)
			
			surface.DrawLine(cx - spacing, cy + mildot_size, cx - spacing, cy - mildot_size) // left
			surface.DrawLine(cx - spacing_half, cy + mildot_size / 2, cx - spacing_half, cy - mildot_size / 2) // left half
			surface.DrawLine(cx + spacing, cy + mildot_size, cx + spacing, cy - mildot_size) // right
			surface.DrawLine(cx + spacing_half, cy + mildot_size / 2, cx + spacing_half, cy - mildot_size / 2) // right half
		end
		
		--surface.DrawLine(512*1.875, 0, 512 * 1.875, 1024*2)
		
		surface.SetDrawColor(0, 0, 0, 255 - math.pow(self.IronTime, 6) * 255)
		surface.DrawRect(0, 0, w, h)
		
		render.SetViewPort(0, 0, w, h)
	render.SetRenderTarget(oldrt)
	
	/*
	local oldrt = render.GetRenderTarget()
	render.SetRenderTarget(self.ScopeRT)
		render.Clear(0, 0, 0, 255)
		render.ClearDepth()
		local w, h = ScrW(), ScrH()
		render.SetViewPort(0, 0, 512, 512)
			cam.Start2D()
				render.RenderView(Cam)
					surface.SetDrawColor(255, 255, 255, 255)
					surface.SetMaterial(self.mat)
					--surface.SetTexture(self.ScopeRT)
					
					surface.DrawTexturedRectUV(0, 0, 512, 512, 1, -1)
			cam.End2D()
		render.SetViewPort(0, 0, w, h)
		
	--render.SetRenderTarget(self.ScopeRT)
	
	render.SetRenderTarget(oldrt)
	
	*/

	
	if(self.IsZoomedIn && self.IronTime == 1 && !self:GetNetworkedBool("Reloading")) then
		
		
		--DrawCircle(ScrW()/2, ScrH()/2, 300, 0.1, Color(255,255,255,255), 0, self.ScopeRT)
		
		/*
		render.ClearStencil()
		render.SetStencilEnable( true ) 

		render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_NEVER);
		render.SetStencilFailOperation(STENCILOPERATION_INCR);
		render.SetStencilPassOperation(STENCILOPERATION_KEEP); 

		DrawCircle(ScrW()/2, ScrH()/2, 300, 0.1, Color(255,255,255,255), 0);
		
		render.SetStencilPassOperation( STENCILOPERATION_DECR);
		
		DrawCircle(ScrW()/2, ScrH()/2, 200, 0.1, Color(255,255,255,255), 0);
		
		render.SetStencilReferenceValue(1);
		render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL);
		
		surface.SetDrawColor(0, 0, 0, 255);
		surface.DrawRect(0, 0, ScrW(), ScrH());
		
		render.SetStencilEnable(false);
		*/
	end
end

function SWEP:AdjustMouseSensitivity()
	if self.IsZoomedIn and self.IronTime == 1 then
		return 0.1
	end
	return 1
end


