include('shared.lua')

function ENT:Draw()
	
	local ent = self.Entity
	ent:DrawModel()
	
	
end




function ENT:SetupPanel(pan)
--SpawnIcon DButton
	local btn = vgui.Create("DButton", pan)
	btn:SetPos(0, 0)
	btn:SetWidth(pan:GetWide())
	btn:SetTall(pan:GetTall())
	--btn:SetSize(pan:GetWide(), pan:GetTall())
	--btn:SetModel(self.Model or "")
	
	--btn:SetToolTip(self:GetPrintName())
	
	btn:SetText(self:GetPrintName())
	--btn:SetSize(32)
	btn.DoClick = function()
		local x,y = gui.MousePos()
		--frame:SetVisible(false)
		
		local Choice = DermaMenu()
		Choice:SetPos(x, y) -- TODO: Hack, can't click menu if it's over a derma item...
		--timer.Simple(0.2, gui.EnableScreenClicker)
		
		if self:GetEquipSlot() != "" then
			Choice:AddOption("Equip", function()
				LocalPlayer():InvEquip(self)
			end)
			Choice:AddOption("Unequip", function()
				LocalPlayer():InvMove(self, self.PreferedSlot)
			end)
		end
		
		Choice:AddOption("Drop", function()
			LocalPlayer():InvDrop(self)
		end)
		
		Choice:AddOption("Move to toolbelt", function()
			LocalPlayer():InvMove(self, "ToolBelt")
		end)
		
		Choice:AddOption("Move to generic", function()
			LocalPlayer():InvMove(self, "Generic")
		end)
		/*
		Choice:AddOption("Move to backpack", function()
			LocalPlayer():InvMove(self, "BackPack")
		end)
		*/
		
		for k,vv in pairs(self:GetActions()) do
			local v = vv
			Choice:AddOption(v.Name, function()
				frame:SetVisible(true)
				self:InvokeAction(v.ID)
			end)
		end
		
		Choice:Open()
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

net.Receive("sent_base_item_OnDrop", function()
	local e1 = net.ReadEntity()
	local e2 = net.ReadEntity()
	
	if not e1.OnDrop then
		print("WARNING: No CS OnDrop for entity " .. e1:GetClass())
		return
	end
	e1:OnDrop(e2)
end)
