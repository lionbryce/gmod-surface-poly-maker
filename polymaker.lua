-- make the frame
local frame = vgui.Create("DFrame")
frame:SetSize(ScrW()/2,ScrH()/2)
frame:Center()
frame:MakePopup()
-- happy canvas area to hold our drawing
local canvas = vgui.Create("DPanel",frame)
canvas:Dock(FILL)

local active_point_table = 1 -- a "pointer" to the current point table we're working with, it's just the index.

local point_tables = {{}} -- a table to hold our arrays of points

local function addPoint(x,y) -- add a point to the current table
	local points = point_tables[active_point_table]
	points[#points+1] = {x = x, y = y}
end

local function removePoint() -- removes the last point from the current table
	local points = point_tables[active_point_table]
	points[#points] = nil
end

local function switchPointTable(index) -- switches to a new point table based on the index supplied, creates the table as necessary
	if index < 1 then return end -- as much as I'd like to let you go below 1, we'd have to use pairs at that point which doesn't maintain order and SortedPairs is odd

	active_point_table = index
	point_tables[active_point_table] = point_tables[active_point_table] or {} -- create the table if it doesn't exist

	print("switched to point table",active_point_table) -- nice to know which one you're working with
end

local function drawPointsTable(points, color) -- draws a table of points, optionally with a color assumes you've already set the draw color and material if not
	if color then
		surface.SetDrawColor(color)
		draw.NoTexture()
	end

	local points_len = #points

	if points_len > 2 then -- if we have more than 2 points, draw a polygon
		surface.DrawPoly(points)
	elseif points_len == 2 then -- if we have 2 points, draw a line
		surface.DrawLine(points[1].x,points[1].y,points[2].x,points[2].y)
	elseif points_len == 1 then -- if we have 1 point, draw a dot
		surface.DrawRect(points[1].x,points[1].y,3,3)
	end
end

function canvas:Paint(w,h)
	surface.SetDrawColor(255,255,255) -- paper background
	surface.DrawRect(0,0,w,h)

	surface.SetDrawColor(0,0,0) -- "pencil" foreground
	draw.NoTexture()

	for k,points in ipairs(point_tables) do -- draw all the point tables
		if k == active_point_table then -- if it's the active one, draw it with red and make sure to add where the cursor is as the next point temporarily for drawing
			local x,y = self:CursorPos()
			addPoint(x,y)
			drawPointsTable(points, Color(255,0,0))
			removePoint()

			surface.SetDrawColor(0,0,0) -- can't forget to switch back to black
		else
			drawPointsTable(points)
		end
	end
end

function canvas:OnMousePressed(key)
	print(key)
	if key == MOUSE_LEFT then -- left click = add a point
		local x,y = self:CursorPos()
		addPoint(x,y)
	elseif key == MOUSE_RIGHT then -- right click = remove a point
		removePoint()
	elseif key == MOUSE_5 then -- turns out this is the front side-button on my mouse, I will never remember that
		switchPointTable(active_point_table + 1)
	elseif key == MOUSE_4 then -- and this is the back side-button, they move the "table pointer" forward and backward
		switchPointTable(active_point_table - 1)
	end
end