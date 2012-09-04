

// GUI Codens below
if frame then frame:Remove() end

print("HEELO")

local SlotSize = 40

frame = vgui.Create("DFrame")
frame:SetTitle("Inventory")
frame:SetSize(500 + 10, 600 + 10)
frame:Center()
frame:SetVisible(true)
frame:MakePopup()

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
end

-- Generic Inventory
local slots = 10

while slots > 0 do
	local slot = vgui.Create("DPanel", frame)
	slot:SetPos(10 + i * SlotSize + 5 * i, 5 + 25 + SlotSize * 3 + 5 * 2 + 5)
	slot:SetSize(SlotSize, SlotSize)
	slots--
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
		
		slots = slots - 1
		col = col + 1
	end
	row = row + 1
	col = 0
end

frame:SetSize(500 + 10, 5 + 25 + (SlotSize + 5) * (4 + row) + 5 + 5)

