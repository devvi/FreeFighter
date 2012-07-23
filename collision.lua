local oo = require "loop.simple"
local circle = "circle"
local line = "line"
Fixture = oo.class({
}, nil)

function Fixture:__init(x, y)
	local fixture =  oo.rawnew(self, {})
	fixture.position = {x = x, y = x}
	fixture.rotation = 0
	fixture.userdata = fixture
	fixture.id = "fixture"
	return fixture
end

function Fixture:onDraw()
	love.graphics.circle( "fill", self.position.x, self.position.y, 5)
end

function Fixture:setPosition(x, y)
	self.position.x = x
	self.position.y = y
end
function Fixture:translate(x ,y)
	self.position.x = self.position.x + x
	self.position.y = self.position.y + y
end
function Fixture:setRotation(r)
	self.rotation = r
end

function Fixture:getRotation()
	return self.rotation
end

function Fixture:getPosition()
	return self.position.x, self.position.y
end

CircleFixture = oo.class({
}, Fixture)

function CircleFixture:__init(x, y, r)
	local fixture =  oo.superclass(CircleFixture).__init(self, x, y)
	fixture.radius = r
	fixture.type = circle
	return fixture
end
function CircleFixture:setPosition(x, y)
	oo.superclass(CircleFixture).setPosition(self, x, y)
end

function CircleFixture:setRotation(r)
	oo.superclass(CircleFixture).setRotation(self, r)
end
function CircleFixture:onDraw()
	oo.superclass(CircleFixture).onDraw(self)
	love.graphics.circle( "line", self.position.x, self.position.y, self.radius)	
end

LineFixture = oo.class({
}, Fixture)

function LineFixture:__init(x, y, x1, y1, x2, y2)
	local fixture =  oo.superclass(LineFixture).__init(self, x, y)
	fixture.point1 = {x = x1, y = y1}
	fixture.point2 = {x = x2, y = y2}
	-- fixture.radius = Vector2.length({x = x2 - x1 y = y2 - y1})/2 
	fixture.type = line
	return fixture
end
function LineFixture:setPosition(x, y)
	local biasx = x - self.position.x
	local biasy = y - self.position.y
	oo.superclass(LineFixture).setPosition(self, x, y)
	self.point1.x = self.point1.x + biasx
	self.point2.x = self.point2.x + biasx
	self.point1.y = self.point1.y + biasy
	self.point2.y = self.point2.y + biasy
end

function LineFixture:translate(x, y)
	oo.superclass(LineFixture).translate(self, x, y)
	self.point1.x = self.point1.x + x
	self.point2.x = self.point2.x + x
	self.point1.y = self.point1.y + y
	self.point2.y = self.point2.y + y
end
function LineFixture:setRotation(r)
	oo.superclass(LineFixture).setRotation(self, r)
	local vec = {x = self.point2.x - self.point1.x, y = self.point2.y - self.point1.y}
	local radius = Vector2.length(vec)/2 
	-- local radius = self.radius
	local centerx = self.position.x
	local centery = self.position.y
	self.point1.x = centerx + radius * math.cos(r)
	self.point1.y = centery + radius * math.sin(r)
	self.point2.x = centerx + radius * math.cos(r + math.pi)
	self.point2.y = centery + radius * math.sin(r + math.pi)
end
function LineFixture:onDraw()
	oo.superclass(LineFixture).onDraw(self)
	--[[love.graphics.push()
	love.graphics.translate(self.position.x, self.position.y)
	love.graphics.rotate(self.rotation)]]
	love.graphics.line( self.point1.x, self.point1.y, self.point2.x, self.point2.y)	
	--love.graphics.pop()
end

-- type of fixtures -- 

local fixtures = {}
local collidedFixtures = {}
local contact = {f1 = nil, f2 = nil}
local contactTeamplates = {f1 = nil, f2 = nil}
Collision = {}

local function isAlreadyCollided(f1, f2)	
	for k, v in ipairs(collidedFixtures) do
		if (v.f1 == f1 and v.f2 == f2) or (v.f1 == f2 and v.f2 == f1) then
			return true
		end
	end
	return false
end
local function removeContact(f1, f2)
	for k, v in ipairs(collidedFixtures) do
		if (v.f1 == f1 and v.f2 == f2) or (v.f1 == f2 and v.f2 == f1) then
			table.remove(collidedFixtures, k)
		end
	end
end
function Collision.createCircleFixture(x, y , r)
	local circleFixture = CircleFixture(x, y, r)
	table.insert(fixtures, circleFixture)
	return circleFixture
end
function Collision.createLineFixture(x1, x2, y1, y2)
	local lineFixture = LineFixture((x2 - x1)/2, (y2 - y1)/2, x1, x2, y1, y2)
	table.insert(fixtures, lineFixture)
	return lineFixture
end
function Collision.removeFixture(f)
	for k, v in ipairs(fixtures) do 
		if v == f then
			table.remove(fixtures, k)
		end
	end
end

function Collision.addContactTeamplate(v1, v2)
	table.insert(contactTeamplates, {f1 = v1, f2 = v2})
end

function Collision.removeContactTeamplate(v1, v2)
	for k, v in ipairs(contactTeamplates) do
		if v.f1 == v1 and v.f2 == v2 then
			table.remove(contactTeamplates, k)
		end
	end
end


 
function Collision.drawFixtures()
	for k, v in ipairs(fixtures) do 
		v:onDraw()
	end
end

local function isLineSegmentCross(x11, y11, x12, y12, x21, y21, x22, y22 )
	local p1 = x11 * (y21 - y12) + x12 * (y11 - y21) + x21 * (y12 - y11)
	local p2 = x11 * (y22 - y12) + x12 * (y11 - y22) + x22 * (y12 - y11)
	
	if p1 * p2 >= 0 and not (p1 == 0 and p2 == 0) then
		return false
	end
	
	p1 = x21 * (y11 - y22) + x22 * (y21 - y11) + x11 * (y22 - y21)
	p2 = x21 * (y12 - y22) + x22 * (y21 - y12) + x12 * (y22 - y21)
	
	if p1 * p2 >= 0 and not (p1 == 0 and p2 == 0) then
		return false
	end 
	
	return true
	
end


local function isLineSegmentCircleCross(x1, y1, x2, y2, centerx, centery, r)
	local A = (x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1)
	local B = ((x2 - x1) * (x1 - centerx) + (y2 - y1) * (y1 - centery)) * 2
	local C = centerx * centerx + centery * centery + x1 * x1 + y1 * y1 - (centerx * x1 + centery * y1) * 2 - r * r
	local p = B * B - A * C * 4
	local realp = math.sqrt(p)
	local u1 = (-B + realp)/(A * 2)
	local u2 = (-B - realp)/(A * 2)
	if p < 0 then
		return false
	elseif (u1 <= 1 and u1 >= 0) or (u2 <=1 and u2 >= 0) then
		return true
	else
		return false
	end
end
local function callBeginContact(v1, v2)
	if  not isAlreadyCollided(v1, v2) then
		if v1.beginContact then
			v1.beginContact(v1, v2)
		end
		if v2.beginContact then
			v2.beginContact(v2, v1)
		end
		table.insert(collidedFixtures, {f1 = v1, f2 = v2})
	end
end
local function callEndContact(v1, v2)
	if isAlreadyCollided(v1, v2) then
		if v1.endContact then
			v1.endContact(v1, v2)
		end
		if v2.endContact then
			v2.endContact(v2, v1)
		end
		removeContact(v1, v2)
	end
end
function Collision.setCallback(f, beginContact, endContact)
	f.beginContact = beginContact
	f.endContact = endContact
end
local function logf(v1, v2)
	writeLog_unit("p1 x: "..tostring(v1.point1.x).." p1 y: "..tostring(v1.point1.y) )
	writeLog_unit("p2 x: "..tostring(v1.point2.x).." p2 y: "..tostring(v1.point2.y) )
	writeLog_unit("player2 x: "..tostring(v2.position.x).."  y: "..tostring(v2.position.y) )
	writeLog_unit("player2 r: "..tostring(v2.radius))
end
function Collision.solve()
	for k1, v1 in ipairs(fixtures) do
		for k2, v2 in ipairs(fixtures) do 
			if v1 ~= v2 and v1 == contactTeamplates[1].f1 and v2 == contactTeamplates[1].f2 then
				if v1.type == line and v2.type == line then
					--isLineSegmentCross
					if isLineSegmentCross(v1.point1.x, v1.point1.y, v1.point2.x, v1.point2.y,
					v2.point1.x, v2.point1.y, v2.point2.x, v2.point2.y) then
						callBeginContact(v1, v2)
					else
						callEndContact(v1, v2)
					end
				elseif v1.type == line and v2.type == circle then
					--isLineSegmentCircleCross
					-- writeLog_unit("line and circle")
					if isLineSegmentCircleCross(v1.point1.x, v1.point1.y, v1.point2.x, v1.point2.y,
					v2.position.x, v2.position.y, v2.radius) then
						--logf(v1, v2)
						callBeginContact(v1, v2)
					else
						callEndContact(v1, v2)
					end
				elseif v1.type == circle and v2.type == circle then
					local lengthVec = {x = v2.position.x - v1.position.x, y = v2.position.y - v1.position.y}
					local length = Vector2.length(lengthVec)
					if length < (v1.radius + v2.radius) then
						callBeginContact(v1, v2)
					else
						callEndContact(v1, v2)
					end
				end
			end
		end
	end
end