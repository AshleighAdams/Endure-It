include('shared.lua')

function ENT:Draw()
	
	local ent = self.Entity
	ent:DrawModel()
	
	
end

function ENT:UpdateState(state) -- called on the client
	self.Rounds = state.Rounds
	if self.Inside and IsValid(self.Inside) then
		self.Inside:SetClip1(self.Rounds)
	end
end
