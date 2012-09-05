include('shared.lua')

function ENT:Draw()
	
	local ent = self.Entity
	ent:DrawModel()
	
	
end

function ENT:SetupPanel(pan)
	local lbl = vgui.Create("DLabel", pan)
	lbl:SetPos(0, 0)
	lbl:SetText(self.PrintName)
	lbl:SizeToContents()
end

function ENT:UpdateState(state)
end


net.Receive("item_state_update", function(len, pl)
	local itm = net.ReadEntity()
	local tbl = net.ReadTable()
	itm:UpdateState(tbl)
end)