-- make the frame
local frame = vgui.Create("DFrame")
frame:SetSize(ScrW()/2,ScrH()/2)
frame:Center()
frame:MakePopup()
-- happy canvas area to hold our drawing
local canvas = vgui.Create("DPanel",frame)
canvas:Dock(FILL)

local points = {} -- table to hold our points

local function addPoint(x,y) -- convenience function to add a point to our table
	points[#points+1] = {x = x, y = y}
end

function canvas:Paint(w,h)
	surface.SetDrawColor(255,255,255) -- might make this configurable later, for now we'll imagine we're drawing on paper
	surface.DrawRect(0,0,w,h)

	draw.NoTexture()
	surface.SetDrawColor(0,0,0)

	local x,y = self:CursorPos()
	addPoint(x,y) -- add the current cursor position to our table so that we can see what we're about to add

	local points_len = #points

	if points_len > 2 then -- you need at least 3 points to draw a polygon
		surface.DrawPoly(points)
	elseif points_len == 2 then -- make a line if we only have 2 points so we can see what we're about to add when we have less than 3 points still
		surface.DrawLine(points[1].x,points[1].y,points[2].x,points[2].y)
	elseif points_len == 1 then -- make a dot in case your cursor just doesn't exist anymore I guess
		surface.DrawRect(points[1].x,points[1].y,3,3) -- 3 pixels wide and tall so you can see it even if you have the standard Windows cursor
	end

	points[points_len] = nil -- delete the extra point we added
end

function canvas:OnMousePressed(key) -- I was today (2023-09-10) years old when I learned this function exists, almost did it with a think hook
	if key == MOUSE_LEFT then -- left click = add a point
		local x,y = self:CursorPos()
		addPoint(x,y)
	elseif key == MOUSE_RIGHT then -- right click = remove a point
		points[#points] = nil
	end
end