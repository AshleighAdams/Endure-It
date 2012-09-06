include('shared.lua')

function ENT:Draw()
	
	local ent = self.Entity
	ent:DrawModel()
	
	
end

function ENT:SetupPanel(pan)
	local btn = vgui.Create("DButton", pan)
	btn:SetPos(0, 0)
	btn:SetText(self:GetPrintName())
	btn:SetSize(pan:GetWide(), pan:GetTall())
	btn.DoClick = function()
		local Choice = DermaMenu()
		local x,y = gui.MousePos()
		Choice:SetPos(0, y) -- TODO: Hack, can't click menu if it's over a derma item...
		Choice:AddOption("Drop", function()
			LocalPlayer():InvDrop(self)
		end)
		
		for k,vv in pairs(self:GetActions()) do
			local v = vv
			Choice:AddOption(v.Name, function()
				self:InvokeAction(v.ID)
			end)
		end
		
		--InvokeAction(id, gun)
	end
end

function ENT:UpdateState(state)
end


net.Receive("item_state_update", function(len, pl)
	local itm = net.ReadEntity()
	local tbl = net.ReadTable()
	itm:UpdateState(tbl)
end)