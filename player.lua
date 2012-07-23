require "node"
require "util"
require "collision"
local oo = require "loop.simple"

Player = oo.class({
}, Node)

local function beginContact(a, b, c)
	local player = a.userdata
	local weapon = b.userdata
	if weapon.type == "sword" then
		if weapon.attacking == true then
			player:attacked({x = weapon.currDir.x * 1000, y = weapon.currDir.y * 1000})
		end
	end
	
	writeLog_unit("player beginContact this is "..tostring(player.id))
end
local function endContact(a, b, c)
	local player = a.userdata
	writeLog_unit("player endContact this is "..tostring(player.id))
end
function Player:__init(image)
	local player = oo.superclass(Player).__init(self)
	player.velocity = {x = 0, y = 0}
	player.isUp = false
	player.isDown = false
	player.isRight = false
	player.isLeft = false
	player.position.x = 200 
	player.position.y = 200
	player.image = image
	player.center.x = image:getHeight()/2
	player.center.y = player.center.x
	player.sword = nil
	player.oldDir = {x = 0, y = 1}
	player.currDirection = {x = 0, y = 1}
	
	player.fixture = Collision.createCircleFixture( player.position.x, player.position.y , image:getHeight()/2)
	Collision.setCallback(player.fixture, beginContact, endContact)
	player.fixture.userdata = player
	
	debugInfo:addinfo(function()
		local str = "player.oldDir: ".."x : "..tostring(player.oldDir.x).." y: "..tostring(player.oldDir.y)
		love.graphics.print(str, 0, 0)
	end
	)
	return player
end

function Player:setPosition(x, y)
	oo.superclass(Player).setPosition(self, x, y)
	self.fixture:setPosition(x, y)
end

function Player:attacked(v)
	self.isAttacked = true
	self.attackedVec = v
end

function Player:translate(x, y)
	oo.superclass(Player).translate(self, x, y)
	self.fixture:translate(x, y)
end

function Player:keyReleased(key, unicode)
	if key == 'w' then
		self.isUp = false
	elseif key == 's' then
		self.isDown = false
	elseif key == 'a' then
		self.isLeft = false
	elseif key == "d" then
		self.isRight = false
	end
 end

function Player:keyPressed(key, unicode)
	if key == 'w' then
		self.isUp = true
	elseif key == 's' then
		self.isDown = true
	elseif key == 'a' then
		self.isLeft = true
	elseif key == "d" then
		self.isRight = true
	elseif key == 'r' then
		self:setPosition(200, 200)
	end
end

local daccel = 700
local accel
function Player:onUpdate(dt)
	local pause = false
	local accel = {x = 0, y = 0}
	if self.isUp == true then
		accel.y = accel.y - daccel * dt
		pause = true
	end
	if self.isDown == true then
		accel.y = accel.y + daccel * dt
		pause = true
	end
	if self.isLeft == true then
		accel.x = accel.x - daccel * dt
		pause = true
	end
	if self.isRight == true then
		accel.x = accel.x + daccel * dt
		pause = true
	end

	if accel.x > 10 and accel.y > 10 then
		accel.x = 10
		accel.y = 10
	end
	
	if self.isAttacked == true then
		accel.x = accel.x + self.attackedVec.x
		accel.y = accel.y + self.attackedVec.y
		self.isAttacked = false
	end
	
	if pause == false then
		if Vector2.length(self.velocity) > 0.001 then
			accel.x = -self.velocity.x * 10 * dt
			accel.y = -self.velocity.y * 10 * dt
		else
			self.velocity.x = 0
			self.velocity.y = 0
		end
	else
		local normalizedAccel = Vector2.normalize(accel)
		if not Vector2.equal(self.oldDir, normalizedAccel) then
			self.sword:beginCompensateDir(normalizedAccel)
		end
		self.oldDir = normalizedAccel
	end
	
	self.velocity.x = self.velocity.x + accel.x
	self.velocity.y = self.velocity.y + accel.y
	
	
	self:translate(self.velocity.x * dt, self.velocity.y * dt)
	--self.fixture:setPosition(self.derivedPosition.x, self.derivedPosition.y)
end