-- Released under MIT License
-- Created by Jaya Polumuru

----------------------------------------------------------------------------------------
-- Split Information
-- 
-- Compatibility: Lua-5.1
----------------------------------------------------------------------------------------


function split(str, pat)
   local t = {}  -- NOTE: use {n = 0} in Lua-5.0
   local fpat = "(.-)" .. pat
   local last_end = 1
   local s, e, cap = str:find(fpat, 1)
   while s do
      if s ~= 1 or cap ~= "" then
	 table.insert(t,cap)
      end
      last_end = e+1
      s, e, cap = str:find(fpat, last_end)
   end
   if last_end <= #str then
      cap = str:sub(last_end)
      table.insert(t, cap)
   end
   return t
end


function drawMyCurve(pathCurve)
	local be = require("bezier")
	
	for i = 2, #pathCurve,3 do 
		
			local src = pathCurve[i-1];
			local srcAngle = pathCurve[i];
			local destAngle = pathCurve[i+1];
			local dest = pathCurve[i+2];
			
			be.drawCurve({src=src,srcCtrlPt=srcAngle,destCtrlPt=destAngle,dest=dest})
	end
	
end

----------------------------------------------------------------------------------------
-- 
-- 
----------------------------------------------------------------------------------------

local function main()
	
	
	local pathCurve = { {x=155.45091 , y=121.75114 } ,
		{x=132.99905 , y=118.63369 } ,
		{x=88.396117 , y=136.55905 } ,
		{x=45.69419 , y=177.0584 } ,
		{x=46.404538 , y=199.11231 } ,
		{x=61.061375 , y=241.77014 } ,
		{x=95.080232 , y=294.61088 } ,
		{x=102.667602 , y=301.5453 } ,
		{x=123.194382 , y=306.72902 } ,
		{x=150.176422 , y=304.27686 } ,
		{x=167.789582 , y=290.61337 } ,
		{x=196.697852 , y=253.83526 } ,
		{x=221.679152 , y=194.62943 } ,
		{x=217.845102 , y=175.39042 } ,
		{x=194.288802 , y=140.91897 } ,
		{x=151.008532 , y=109.23687 }  

		}
	
	drawMyCurve(pathCurve);
	
	
	
	local pathArray = extractPath({file='exp.svg'})
	
	for k1,v1 in pairs(pathArray) do 	
		
		local finalPts = {};

		finalPts = extractPointsFromPath({pathd=v1});

		-- Draw curve for each orbit
		drawMyCurve(finalPts);

	end
	
	
end

function extractPath(params)
	require("xml_parser")

	local xml = XmlParser:ParseXmlFile(params.file);
	local pathd = '';
	local pathArray = {};

	if (xml['ChildNodes']) then
		for k1,v1 in pairs(xml['ChildNodes']) do 
			for k2,v2 in pairs(v1['ChildNodes']) do
				if (v2['Name'] and v2['Name'] == 'path') then

					for k3,v3 in pairs(v2) do
						if (k3 == 'Attributes') then
							for k4,v4 in pairs(v3) do
								if (k4 == 'd') then
									print (v4);
									table.insert(pathArray, v4);
								end
							end
						end
					end
				end
			end 
		end
	end
	
	return pathArray;
end

function extractPointsFromPath(params)
		
	local mArray = split(params.pathd, "m +");
	local m1Array = {};
	local mpts = {};
	local cpts = {};
	local tsrc = {};
	local tdes = {};
	
	local finalPts = {};
	
	if (mArray[1]) then 
		-- print (mArray[1]);
		m1Array = split(mArray[1], " *c *");
		
		local srcArray = split(m1Array[1], " +");
		local curveArray = split(m1Array[2], " +");
		
		
		for k,v in pairs(srcArray) do 
			local tmpts = split(v, ",");
			table.insert(mpts,{x=tmpts[1],y=tmpts[2]});
		end
		
		for k,v in pairs(curveArray) do 
			local tmpts = split(v, ",");
			table.insert(cpts,{x=tmpts[1],y=tmpts[2]});
		end
	
	end
	
	
	-- Always comes first, Translate relative points
	for k,v in pairs(mpts) do
		if (k == 1) then
			src = v;
		else
			mpts[k] = {x=src.x+v.x,y=src.y+v.y};
			src = mpts[k];
		end
	end
		
	-- Adding the points for curve, Making relative points constant
	local count = 0
	for k,v in pairs(cpts) do 
	 	if (src) then
			-- src = v;
			count = count+1
			cpts[k] = {x=src.x+v.x,y=src.y+v.y};
			table.insert(finalPts, cpts[k]);
			if (count % 3 == 0) then
				src = cpts[k];
			end
		end
	end
	
	
	table.insert(finalPts, 1, mpts[#mpts]);
	
	-- for k,v in pairs(finalPts) do 
	-- 	for k1,v1 in pairs(v) do 
	-- 		print(k1 .. "##" .. v1) 
	-- 	end
	-- end
	
	return finalPts;


end

main();
