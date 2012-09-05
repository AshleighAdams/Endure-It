include("sh_inventory.lua")
local Frame = nil

function RemakeFrame()
	if frame then
		frame:Remove()
		frame = nil
	end
	
	local SlotSize = 40

	frame = vgui.Create("DFrame")
	frame:SetTitle("Inventory")
	frame:SetSize(500 + 10, 600 + 10)
	frame:SetVisible(false)
	frame:SetDeleteOnClose(false)
	
	local primary = vgui.Create("DPanel", frame)
	primary:SetPos(10, 5 + 25)
	primary:SetSize(SlotSize * 6, SlotSize * 2)

	local secondary = vgui.Create("DPanel", frame)
	secondary:SetPos(10 + 5 * 1 + SlotSize * 6, 5 + 25)
	secondary:SetSize(SlotSize * 3, SlotSize * 2)

	local backpack = vgui.Create("DPanel", frame)
	backpack:SetPos(10 + 5 * 2 + SlotSize * 9, 5 + 25)
	backpack:SetSize(SlotSize * 3, SlotSize * 2)

	-- Toolbelt
	for i = 0, 10 do -- Only 1 slot size items can go here...
		local slot = vgui.Create("DPanel", frame)
		slot:SetPos(10 + i * SlotSize + 5 * i, 5 + 25 + SlotSize * 2 + 5 * 1)
		slot:SetSize(SlotSize, SlotSize)
		
		local itm = (LocalPlayer():GetInventory().ToolBelt or {})[i + 1]
		if itm != nil then
			itm:SetupPanel(slot)
		end
	end

	-- Generic Inventory
	local slots = 11
	local i = 0

	while slots > 0 do
		local slot = vgui.Create("DPanel", frame)
		slot:SetPos(10 + i * SlotSize + 5 * i, 5 + 25 + SlotSize * 3 + 5 * 2 + 5)
		slot:SetSize(SlotSize, SlotSize)
		
		local itm = (LocalPlayer():GetInventory().Generic or {})[i + 1]
		if itm != nil then
			itm:SetupPanel(slot)
			slots = slots - itm:GetSize()
		else
			slots = slots - 1
		end
		
		
		i = i + 1
	end


	-- Backpack

	slots = 16

	local row = 0
	local col = 0

	while slots > 0 do
		while col <= 10 and slots > 0 do
			local slot = vgui.Create("DPanel", frame)
			slot:SetPos(10 + col * SlotSize + 5 * col, 5 + 25 + (SlotSize + 5) * (4 + row) + 5)
			slot:SetSize(SlotSize, SlotSize)
			
			local itm = (LocalPlayer():GetInventory().BackPack or {})[i + 1]
			if itm != nil then
				itm:SetupPanel(slot)
			end
			
			if itm != nil then
				itm:SetupPanel(slot)
				slots = slots - itm:GetSize()
			else
				slots = slots - 1
			end
			
			col = col + 1
		end
		row = row + 1
		col = 0
	end

	frame:SetSize(500 + 10, 5 + 25 + (SlotSize + 5) * (4 + row) + 5 + 5)
end

concommand.Add("+menu", function()
	RemakeFrame()
	frame:SetVisible(true)
	frame:MakePopup()
	frame:Center()
end)

local no_rec = false
_R.Player.InventoryChange = function(self, tbl)
	if no_rec then return end
	
	no_rec = true
		self:SetInventory(tbl)
	no_rec = false
	
	RemakeFrame()
end

