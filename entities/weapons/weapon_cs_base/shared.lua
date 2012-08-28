
if (SERVER) then

	AddCSLuaFile( "shared.lua" )
	SWEP.Weight				= 5
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false

end

if ( CLIENT ) then

	SWEP.DrawAmmo			= true
	SWEP.DrawCrosshair		= false
	SWEP.ViewModelFOV		= 82
	SWEP.ViewModelFlip		= true
	SWEP.CSMuzzleFlashes	= true
	
	local fd1 = {}
	fd1.font = "csd"
	fd1.size = ScreenScale(30)
	fd1.weight = 500
	fd1.antialias = true
	fd1.additive = true
	
	local fd2 = table.Copy(fd1)
	
	surface.CreateFont("CSKillIcons", fd1)
	surface.CreateFont("CSSelectIcons", fd2)

end

SWEP.Author			= "Counter-Strike"
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= ""

// Note: This is how it should have worked. The base weapon would set the category
// then all of the children would have inherited that.
// But a lot of SWEPS have based themselves on this base (probably not on purpose)
// So the category name is now defined in all of the child SWEPS.
//SWEP.Category			= "Counter-Strike"

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= false

SWEP.Primary.Sound			= Sound( "Weapon_AK47.Single" )
SWEP.Primary.Recoil			= 1.5
SWEP.Primary.Damage			= 40
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.02
SWEP.Primary.Delay			= 0.15

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"
SWEP.UseBullet = DefaultBullet;

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.InventorySlots = 10
SWEP.InventoryPrimary = true

SWEP.ZoomScale = 50;
SWEP.ZoomSpeed = 1;


function SWEP:Initialize()	
	self:SetWeaponHoldType( self.HoldType )
	self.Weapon:SetNetworkedBool("Zoom", false);
	self.IronTime = 0;
end

function SWEP:Reload()
	self.Weapon:DefaultReload( ACT_VM_RELOAD );
end



function SWEP:PrimaryAttack()

	self.Weapon:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	
	if ( !self:CanPrimaryAttack() ) then return end
	
	self.Weapon:EmitSound( self.Primary.Sound )
	self:CSShootBullet( self.Primary.Damage, self.Primary.Recoil, self.Primary.NumShots, self.Primary.Cone )
	self:TakePrimaryAmmo( 1 )
	
	if ( self.Owner:IsNPC() ) then return end
	
	self.Owner:ViewPunch( Angle(math.random(-self.Primary.Recoil, -1), math.random(-self.Primary.Recoil, 1), math.random(-1, 1)) )
	
	// In singleplayer this function doesn't get called on the client, so we use a networked float
	// to send the last shoot time. In multiplayer this is predicted clientside so we don't need to 
	// send the float.
	if ( (SinglePlayer() && SERVER) || CLIENT ) then
		self.Weapon:SetNetworkedFloat( "LastShootTime", CurTime() )
	end
	
end

function SWEP:SecondaryAttack()
end

function SWEP:CSShootBullet( dmg, recoil, numbul, cone )

	numbul 	= numbul 	or 1
	
	if numbul > 1 then
		numbul = numbul * 5
	end
	
	cone 	= cone 		or 0.01
	cone = cone * 0.5
	
	if CLIENT and IsFirstTimePredicted() then
		for i = 1, numbul do
			local bul = {}
			local lp = LocalPlayer()
			bul.StartPos = lp:GetShootPos()
			bul.Direction = lp:GetAimVector()

			bul.Direction = bul.Direction + 
				Vector(
					math.Rand(-1, 1) * cone, 
					math.Rand(-1, 1) * cone, 
					math.Rand(-1, 1) * cone
				)
			bul.Direction:Normalize()

			bul.TraceIgnore = {LocalPlayer()}
			bul.TraceMask = MASK_SHOT
			bul.RandSeed = math.Rand(-100000, 100000)
			
			bul.Bullet = DefaultBullet
			
			print("abc", self.UseBullet)
			
			if self.UseBullet then
				bul.Bullet = self.UseBullet
				print("using ", bul.Bullet.Name)
			elseif numbul > 1 then
				bul.Bullet = BuckShot
			elseif dmg > 70 then
				bul.Bullet = SniperBullet
			end
			print("SHOOTING")
			ShootBullet(bul, function(bullet)
				bullet.Velocity = bullet.Velocity + lp:GetVelocity()
			end)
		end
	end
	
	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK ) 		// View model animation
	self.Owner:MuzzleFlash()								// Crappy muzzle light
	self.Owner:SetAnimation( PLAYER_ATTACK1 )				// 3rd Person Animation
	
	if ( self.Owner:IsNPC() ) then return end
	
	// CUSTOM RECOIL !
	if ( (SinglePlayer() && SERVER) || ( !SinglePlayer() && CLIENT && IsFirstTimePredicted() ) ) then
	
		local eyeang = self.Owner:EyeAngles()
		
		eyeang.p = eyeang.p - self.Primary.Recoil/10;
		eyeang.y = eyeang.y - self.Primary.Recoil/10;
			
		self.Owner:SetEyeAngles(eyeang);
	
	end
	//wtf is this shitl

end

function SWEP:Think()	
	if self.Owner:KeyDown(IN_ATTACK2) and not self.IsZoomedIn then
		print("ZOOMY")
		self.IronTime = self.IronTime + self.ZoomSpeed/25;
		self.Weapon:SetNetworkedBool("Zoom", true);
		self.Owner:SetFOV(self.ZoomScale, self.ZoomSpeed);
		self.IsZoomedIn = true
	elseif not self.Owner:KeyDown(IN_ATTACK2) and self.IsZoomedIn then
		print("UNZOOMY")
		self.IronTime = 0;
		self.Weapon:SetNetworkedBool("Zoom", false);
		self.Owner:SetFOV(0, self.ZoomSpeed)
		self.IsZoomedIn = false
	end	
end	

function SWEP:GetViewModelPosition( pos, ang )

	local zoom = self.Weapon:GetNetworkedBool("Zoom");
	
	if(zoom) then
		
		local grad = Lerp( self.IronTime, 0, 1)
		local Offset = LerpVector( 1, self.OldPos, self.IronSightsPos )
		
		ang:RotateAroundAxis(ang:Right(), self.IronSightsAng.x)
		ang:RotateAroundAxis(ang:Up(), self.IronSightsAng.y)
		ang:RotateAroundAxis(ang:Forward(), self.IronSightsAng.z)
	
		local Right = ang:Right()
		local Up = ang:Up()
		local Forward = ang:Forward()
	
		pos = pos + Offset.x * Right * grad
		pos = pos + Offset.y * Forward * grad
		pos = pos + Offset.z * Up * grad

		return pos, ang
	
	else
		self.OldPos = pos;
		return pos, ang
	end

end


function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
	
	draw.SimpleText( self.IconLetter, "CSSelectIcons", x + wide/2, y + tall*0.2, Color( 255, 210, 0, 255 ), TEXT_ALIGN_CENTER )
	
	// try to fool them into thinking they're playing a Tony Hawks game
	draw.SimpleText( self.IconLetter, "CSSelectIcons", x + wide/2 + math.Rand(-4, 4), y + tall*0.2+ math.Rand(-14, 14), Color( 255, 210, 0, math.Rand(10, 120) ), TEXT_ALIGN_CENTER )
	draw.SimpleText( self.IconLetter, "CSSelectIcons", x + wide/2 + math.Rand(-4, 4), y + tall*0.2+ math.Rand(-9, 9), Color( 255, 210, 0, math.Rand(10, 120) ), TEXT_ALIGN_CENTER )
	
end

function SWEP:DrawHUD()


end

