include('shared.lua')

function ENT:Draw()
	
	local ent = self.Entity
	ent:DrawModel()
	
	
end

function ENT:UpdateState(state) -- called on the client
	self.Rounds = state.Rounds
end
