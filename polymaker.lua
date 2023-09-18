-- make the frame
local frame = vgui.Create("DFrame")
frame:SetSize(ScrW() / 2, ScrH() / 2 + 50)
frame:Center()
frame:MakePopup()
local bottom_buttons = vgui.Create("Panel", frame) -- a panel to hold the buttons at the bottom
bottom_buttons:Dock(BOTTOM)
bottom_buttons:SetTall(50)
-- happy canvas area to hold our drawing
local canvas = vgui.Create("DPanel", frame)
canvas:Dock(FILL)
local color_black = Color(0, 0, 0) -- just in case this doesn't turn out to be in _G
local active_point_table = 1 -- a "pointer" to the current point table we're working with, it's just the index.

local function newPointTable()
	return {
		color = color_black
	}
end

-- a table to hold our arrays/tables of points
local point_tables = {newPointTable()}

-- add a point to the current table
local function addPoint(x, y)
	local points = point_tables[active_point_table]

	points[#points + 1] = {
		x = x,
		y = y
	}
end

-- removes the last point from the current table
local function removePoint()
	local points = point_tables[active_point_table]
	points[#points] = nil
end

-- switches to a new point table based on the index supplied, creates the table as necessary
local function switchPointTable(index)
	if index < 1 then return end -- as much as I'd like to let you go below 1, we'd have to use pairs at that point which won't work unless we restructure the data
	active_point_table = index
	point_tables[active_point_table] = point_tables[active_point_table] or newPointTable() -- create the table if it doesn't exist
	print("switched to point table", active_point_table) -- nice to know which one you're working with
end

-- draws a table of points, optionally with a color assumes you've already set the draw color and material if not
local function drawPointsTable(points, color)
	if color then
		surface.SetDrawColor(color)
		draw.NoTexture()
	end

	local points_len = #points

	-- if we have more than 2 points, draw a polygon
	if points_len > 2 then
		surface.DrawPoly(points)
	elseif points_len == 2 then
		-- if we have 2 points, draw a line
		surface.DrawLine(points[1].x, points[1].y, points[2].x, points[2].y)
	elseif points_len == 1 then
		-- if we have 1 point, draw a dot
		surface.DrawRect(points[1].x, points[1].y, 3, 3)
	end
end

function canvas:Paint(w, h)
	surface.SetDrawColor(255, 255, 255) -- paper background
	surface.DrawRect(0, 0, w, h)
	draw.NoTexture() -- reset the material

	-- draw all the point tables
	for k, points in ipairs(point_tables) do
		-- if it's the active one, draw it with red and make sure to add where the cursor is as the next point temporarily for drawing
		if k == active_point_table then
			local x, y = self:CursorPos()
			addPoint(x, y)
			drawPointsTable(points, points.color) -- need a new way to show that this one is active, maybe a border? is that even trivial?
			removePoint()
		else
			drawPointsTable(points, points.color)
		end
	end
end

-- opens a color picker for the specified point table
local function openColorPicker(index)
	local points = point_tables[index]
	assert(points, "Attempting to open color picker for non-existent point table")
	-- make another frame
	local frame = vgui.Create("DFrame")
	frame:SetSize(200, 200)
	frame:Center()
	frame:MakePopup()
	-- I love the color mixer
	local mixer = vgui.Create("DColorMixer", frame)
	mixer:Dock(FILL)
	mixer:SetPalette(false)
	mixer:SetAlphaBar(false)
	mixer:SetWangs(false)
	mixer:SetColor(Color(255, 0, 0)) -- default to red, it pops enough to be noticeable
	-- seriously, it's so good
	local button = vgui.Create("DButton", frame)
	button:Dock(BOTTOM)
	button:SetText("Set Color")

	function button:DoClick()
		local color = mixer:GetColor()
		points.color = color
		frame:Remove()
	end
end

function canvas:OnMousePressed(key)
	-- left click = add a point
	if key == MOUSE_LEFT then
		local x, y = self:CursorPos()
		addPoint(x, y)
	elseif key == MOUSE_RIGHT then
		-- right click = remove a point
		removePoint()
	elseif key == MOUSE_5 then
		-- turns out this is the front side-button on my mouse, I will never remember that
		switchPointTable(active_point_table + 1)
	elseif key == MOUSE_4 then
		-- and this is the back side-button, they move the "table pointer" forward and backward
		switchPointTable(active_point_table - 1)
	elseif key == MOUSE_MIDDLE then
		-- middle click = open the color picker
		openColorPicker(active_point_table)
	end
end

-- returns the current points table as a nice string
local function getPointsTableAsString()
	local output = {"point_tables = {"}

	for k, points in ipairs(point_tables) do
		if #points == 0 then continue end -- don't bother with empty tables
		output[#output + 1] = "\t{"

		for _, v in ipairs(points) do
			output[#output + 1] = ("\t\t{x = %s, y = %s},"):format(v.x, v.y)
		end

		local c = points.color
		output[#output + 1] = ("\t\tcolor=Color(%s,%s,%s)\n\t},"):format(c.r, c.g, c.b)
	end

	output[#output + 1] = "}"

	return table.concat(output, "\n")
end

-- Using a table improves readability, and if needed expandability
local buttonConfig = {
	{
		txt = "Print to Console",
		onClick = function()
			print(getPointsTableAsString())
		end
	},
	-- Print to console button
	{
		txt = "Save to Clipboard",
		onClick = function()
			SetClipboardText(getPointsTableAsString())
		end
	}
}

-- Save to clipboard button
for _, config in ipairs(buttonConfig) do
	local button = vgui.Create("DButton", bottom_buttons)
	button:Dock(LEFT)
	button:SetWide(150)
	button:SetText(config.txt)

	function button:DoClick()
		config.onClick()
	end
end