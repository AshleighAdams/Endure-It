AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include('shared.lua')

function ENT:RestoreState(state)
	self.Bullet = state.Bullet or self.Bullet
	self.BaseClass.RestoreState(self, state)
end

function ENT:GetState()
	local ret = self.BaseClass.GetState(self)
	if self.BulletChanged then
		self.BulletChanged = false
		ret.Bullet = self.Bullet
	end
	return ret
end
