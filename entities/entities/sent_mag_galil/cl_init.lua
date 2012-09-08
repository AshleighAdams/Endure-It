include('shared.lua')
function ENT:UpdateState(state) -- called on the client
	self.BaseClass.UpdateState(self, state)
	self.Bullet = state.Bullet or self.Bullet
end
