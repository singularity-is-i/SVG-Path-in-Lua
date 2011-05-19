module(..., package.seeall)


local segMents = {};
local bezierSegment = {x,y};
local endCaps = {};
local tempCaps = {};
local tempBG = {};
local handleDot = {};

local FALSE = 0;
local TRUE  = 1;
local moved = FALSE;
local numPoints = 0;
local NUMPOINTS = 200;
local gSegments;

-- Configure these as needed
local granularity = 200;
local lineWidth = 4;

local bbg = nil;

----------------------------------------------------------------------------------------
-- 
-- 
----------------------------------------------------------------------------------------
		
local function destroyBezierSegment()	

	segMents = nil;
	segMents = {};
	handleDot = nil
	handleDot = {};
	endCaps = {};
	
	bezierSegment = nil;
	bezierSegment = {x,y};
	
	tempCaps = {};
	tempBG = {};
	
	
	numPoints = 0;
	NUMPOINTS = 200;
	gSegments = {};
	bbg = nil;
end

----------------------------------------------------------------------------------------
-- 
-- 
----------------------------------------------------------------------------------------

local function drawBezierSegment(r,g,b)

	line = display.newLine(bezierSegment[1].x,bezierSegment[1].y,bezierSegment[2].x,bezierSegment[2].y);
	for i = 3, granularity, 1 do 
		line:append( bezierSegment[i].x,bezierSegment[i].y);
	end
	line:setColor(r,g,b);
	line.width = lineWidth;
	
end


----------------------------------------------------------------------------------------
-- 
-- 
----------------------------------------------------------------------------------------

local function setupBezierSegment()
	
	local inc = (1.0 / granularity);

	for i = 1, #endCaps,4 do 

	local t = 0;
	local t1 = 0;
	local i = 1;
	

	for j = 1, granularity do 

			t1 = 1.0 - t;
	
			local t1_3 = t1*t1*t1
			local t1_3a = (3*t)*(t1*t1)
			local t1_3b = (3*(t*t))*t1;
			local t1_3c = (t * t * t )
	
			local p1 = endCaps[i]; -- start point
			local p2 = endCaps[i+1]; -- start control point
			local p3 = endCaps[i+2]; -- end control point
			local p4 = endCaps[i+3]; -- end point
			
			-- print( "**p1** " .. p1.x .. " -- " .. p1.y )
			-- print( "**p2** " .. p2.x .. " -- " .. p2.y )
			-- print( "**p3** " .. p3.x .. " -- " .. p3.y )
			-- print( "**p4** " .. p4.x .. " -- " .. p4.y )
	
			local 	x = t1_3  * p1.x;
			x = 	x + t1_3a * p2.x;
			x = 	x + t1_3b * p3.x;
			x =		x + t1_3c * p4.x

			local 	y = t1_3  * p1.y;
			y = 	y + t1_3a * p2.y;
			y = 	y + t1_3b * p3.y;
			y =		y + t1_3c * p4.y;

			bezierSegment[j].x = x;
			bezierSegment[j].y = y;
			
			-- print( "**" .. j .. "** x:" .. bezierSegment[j].x .. " -- y:" .. bezierSegment[j].y )
						
			t = t + inc;
		end
	end
end 
----------------------------------------------------------------------------------------
-- 
-- 
----------------------------------------------------------------------------------------

local function drawBezierHandles()

	if ( gSegments ) then
		gSegments:removeSelf()
	end

	gSegments = display.newGroup()
	
	for i = 1,#endCaps,2 do 
		local line = display.newLine(endCaps[i].x,endCaps[i].y,endCaps[i+1].x,endCaps[i+1].y);
		line:setColor(255,128,128);
		line.width = 5;
		gSegments:insert( line )
		table.insert(segMents,line);
	end 
	
end


----------------------------------------------------------------------------------------
-- 
-- 
----------------------------------------------------------------------------------------

local function dragHandles(event)

	local t = event.target

	local phase = event.phase
	if "began" == phase then
		-- Make target the top-most object
		local parent = t.parent
		parent:insert( t )
		display.getCurrentStage():setFocus( t )

		t.isFocus = true

		t.x0 = event.x - t.x
		t.y0 = event.y - t.y

		elseif t.isFocus then
		if "moved" == phase then
			-- Make object move (we subtract t.x0,t.y0 so that moves are
			-- relative to initial grab point, rather than object "snapping").
			t.x = event.x - t.x0
			t.y = event.y - t.y0
			
		elseif "ended" == phase or "cancelled" == phase then
			display.getCurrentStage():setFocus( nil )
			t.isFocus = false
			setupBezier(255,25,0);
		end
	end

	return true
	
end


----------------------------------------------------------------------------------------
-- 
-- 
----------------------------------------------------------------------------------------

local function initBezierSegment()

	for j = 1, granularity, 1 do
	
		local pt = {};
		pt.x = 0;
		pt.y = 0;
		table.insert(bezierSegment,pt);
		
	end
end

----------------------------------------------------------------------------------------
-- 
-- 
----------------------------------------------------------------------------------------

function drawCurve(params)

	if (params) then
	
		initBezierSegment()
		endCaps = {};
	
		-- The order is important
		table.insert (endCaps,params.src); -- Source point
		table.insert (endCaps,params.srcCtrlPt); -- Source Angle point
		table.insert (endCaps,params.destCtrlPt); -- Destination Angle point
		table.insert (endCaps,params.dest); -- Destination point
	
		
		-- To draw anchor points and handles 
		-- drawBezierHandles();

		-- To setupBezierSegment
		setupBezierSegment();

		-- Draw the segment 
		drawBezierSegment(255,75,0);
		
		
		-- 4th destroy the segment
		destroyBezierSegment();
		
		--return TRUE;
	end
	
	return FALSE;
end

----------------------------------------------------------------------------------------
-- 
-- 
----------------------------------------------------------------------------------------

function getSegments(params)

	if (params) then
	
		initBezierSegment()
	
		-- The order is important
		table.insert (endCaps,params.src); -- Source point
		table.insert (endCaps,params.srcCtrlPt); -- Source Angle point
		table.insert (endCaps,params.destCtrlPt); -- Destination Angle point
		table.insert (endCaps,params.dest); -- Destination point
	
		
		-- To draw anchor points and handles 
		drawBezierHandles();

		-- To setupBezierSegment
		setupBezierSegment();

		-- Draw the segment 
		-- drawBezierSegment(255,25,0);
		
		return bezierSegment;
		
		-- 4th destroy the segment
		-- destroyBezierSegment();
		
		
	end
	
	return FALSE;
end
