local io = io

function printNode(title, node)
	local s = 	"--Node: "..title.."\n"..
				"node addr : "..tostring(node).."\n"..
				"node.image : "..tostring(node.image).."\n"..
				"node.derivedPosition.x : "..tostring(node.derivedPosition.x).."\n"..
				"node.derivedPosition.y : "..tostring(node.derivedPosition.y).."\n"..
				"node.derivedScale.x : "..tostring(node.derivedScale.x).."\n"..
				"node.derivedScale.y : "..tostring(node.derivedScale.y).."\n"..
				"node.derivedRotation : "..tostring(node.derivedRotation).."\n"
	return s	
end

debugInfo = {}
debugInfo.infos = {}

function debugInfo:addinfo(info)
	table.insert(self.infos, info)
end

function debugInfo:draw()
	for k, v in ipairs(self.infos) do
		if type(v) == "function" then
			v()
		elseif type(v) == "string" then
			love.graphics.print(v, 0, k * 10)
		end
	end
end

Vector2 = {}

function Vector2.cross(v1, v2)
	return v1.x * v2.y - v1.y * v2.x
end

function Vector2.dot(v1, v2)
	return v1.x * v2.x + v1.y * v2.y
end
function Vector2.equal(v1, v2)
	if v1.x == v2.x and v1.y == v2.y then
		return true
	else
		return false
	end
end
function Vector2.length(v) 
	return math.sqrt(v.x * v.x + v.y * v.y)
end
function Vector2.rotate(v, rotation)
	local newx,newy	
	newx = v.x * math.cos(rotation) - v.y * math.sin(rotation)
	newy = v.x * math.sin(rotation) + v.y * math.cos(rotation)
	return {x = newx, y = newy}
end
function Vector2.normalize(v)
	local length = Vector2.length(v)
	return { x = v.x/length,y = v.y/length}
end
function interpolate(origin, des, t)
	return origin * (1 - t) + des * t
end

local file = io.open("LuaLog.txt", "w")

function writeLog(s)
	if debug.getinfo(2,"n").name ~= nil then
		file:write("function: "..debug.getinfo(2,"n").name.." "..s.."\n")
	else
		file:write("function: "..debug.getinfo(1,"n").name.." "..s.."\n")
	end
	file:flush()
end
function writeLog_unit(s)
	if s ~= nil then
		file:write(s.."\n")
	end
	file:flush()
end
function closeLog()
	file:flush()
	file:close()
	file = nil
end