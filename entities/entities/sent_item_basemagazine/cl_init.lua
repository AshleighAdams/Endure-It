include('shared.lua')

function ENT:Draw()
	
	local ent = self.Entity
	ent:DrawModel()
	
	
end

function ENT:UpdateState(state) -- called on the client
	self.Rounds = state.Rounds
	if self.Inside and ValidEntity(self.Inside) then
		self.Inside:SetClip1(self.Rounds)
	end
end

net.Receive("sent_base_item_OnDrop", function()
	local e1 = net.ReadEntity()
	local e2 = net.ReadEntity()
	e1:OnDrop(e2)
end)
