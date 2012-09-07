if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
end

if ( CLIENT ) then

	SWEP.PrintName			= "Ingram M-10"			
	SWEP.Author				= "victormeriqui & C0BRA"
	SWEP.Slot				= 2
	SWEP.SlotPos			= 4
	SWEP.IconLetter			= "l"
	
	killicon.AddFont( "smg_mac10", "CSKillIcons", SWEP.IconLetter, Color( 255, 80, 0, 255 ) )
	
end

SWEP.HoldType			= "pistol"
SWEP.Base				= "weapon_cs_base"
SWEP.Category			= "Endure-It"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/v_smg_mac10.mdl"
SWEP.WorldModel			= "models/weapons/w_smg_mac10.mdl"

SWEP.Weight				= 6
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Primary.Sound			= Sound( "Weapon_mac10.Single" )
SWEP.Primary.Recoil			= 0.7
SWEP.Primary.Damage			= 30
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.03
SWEP.Primary.ClipSize		= -1
SWEP.Primary.Delay			= 0.07
SWEP.Primary.DefaultClip	= 0
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "smg1"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"


function SWEP:Deploy()
	self:SetNetworkedBool("Reloading", false);
end

function SWEP:Reload()
	self.Weapon:DefaultReload( ACT_VM_RELOAD );
	
	if(self.Weapon:Clip1() < 31) then
		local time = self.Owner:GetViewModel():SequenceDuration();
		self:SetNetworkedBool("Reloading", true);
		timer.Simple(time, function() 
			self:SetNetworkedBool("Animate", true); 
			self:SetNetworkedBool("Reloading", false); 
		end);
	end
	
end


function SWEP:ViewModelDrawn()
	
	if (!self:GetNetworkedBool("Reloading")) then
		
		if(self:GetNetworkedBool("Animate")) then
			math.Clamp(self.ArmOffset, 0, -45)
			self.ArmOffset = self.ArmOffset - 0.4;
			if(self.ArmOffset == -45) then
				self:SetNetworkedBool("Animate", false); 	
			end
		else
			self.ArmOffset = -45;
	end
	
	else
		self.ArmOffset = 0;
	end

	
	local vm = self.Owner:GetViewModel()
	if !ValidEntity(vm) || self.Owner:GetActiveWeapon() != self then return end
		
	vm.BuildBonePositions = function()	
		local bone = vm:LookupBone("v_weapon.Right_Arm")
		local matrix = vm:GetBoneMatrix(bone);
		matrix:Translate(Vector(self.ArmOffset, 0, 0)); 
		vm:SetBoneMatrix(bone, matrix);
   end
	
end

function SWEP:Holster()
	self.ArmOffset = 0;
	return true;
end


SWEP.ZoomScale = 80;
SWEP.ZoomSpeed = 0.2;
SWEP.IronMoveSpeed = 0.02;

SWEP.OverridePos = Vector (3.7242, 2, 1)
SWEP.OverrideAng = Vector (-4.1062, 15.4322, 7)

SWEP.IronSightsPos =  Vector (2, 0, 2)
SWEP.IronSightsAng =  Vector (0, -2, 0)



function SWEP:CanTakeMagazine(mag)
	return mag:GetClass() == "sent_mag_mac10"
end
