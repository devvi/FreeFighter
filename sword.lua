require "node"
require "util"
require "callphysicscb"
require "collision"
local math = math
local oo = require "loop.simple" 
local pi = math.pi
local maxPowerUpRotation = - pi/4 
local swordLength = 100
local function beginContact(self, other, contact)
	writeLog_unit("sword beginContact")
end
local function endContact(a, b, c)
	writeLog_unit("sword endContact")
end
Sword = oo.class(
{
	direction = {x = 0, y = 1},
	rotateVelocity = math.pi,
	attackRotateTime = 0,
	attackRotateTimer = 0,
	isRotate = false,
	beginRotate = false,
	player = nil,
	-- player's direction compensate the weapon should direct toward veclocity  
}, Node)

function Sword:beginCompensateDir(newdir)
	self.newDir = newdir
end

function Sword:__init(image, world)
	local sword = oo.superclass(Sword).__init(self)
	sword.image = image
	sword.type = "sword"
	sword.center.x = sword.image:getWidth()/2
	sword.center.y = sword.image:getHeight()/2
	sword.position.y = swordLength
	sword.scale.x = 0.2
	sword.scale.y = 0.2
	sword.visible = true
	sword.currDir = {x = 0, y = 1}
	sword.newDir = {x = 0, y = 1}
	sword.compensateVel = 2 * math.pi
	sword.compensateRotation = 0
	
	sword.targetRotation = sword.rotation
	sword.rotateVelocity = pi * 2
	sword.powerUpRotation = self.rotateVelocity/(20 * pi) * maxPowerUpRotation
	
	sword.lockInput = false
	sword.attacking = false
	sword.finishCompensate = true
	sword.isKeyPressed = false
	
	sword.fixture = Collision.createLineFixture(200, 210, 200, 280)
	sword.fixture.userdata = sword
	Collision.setCallback(sword.fixture, beginContact, endContact)
	debugInfo:addinfo(function()
		local degree = sword.compensateRotation / (2* math.pi/360)
		local str1 = "Sword.compensateRotation degree: "..tostring(degree)
		local str2 = "Sword.currDir x : "..tostring(sword.currDir.x).." y: "..tostring(sword.currDir.y)
		local str3 = "SwordPoint.rotation : "..tostring(sword.parent.rotation)
		local str4 = "Sword.newDir x : "..tostring(sword.newDir.x).." y: "..tostring(sword.newDir.y)
		local str5 = "Sword.powerUpRotation: "..tostring(sword.powerUpRotation)
		local str6 = "Sword.oldRotation: "..tostring(sword.oldRotation)
		local str7 = "Sword.lockInput: "..tostring(sword.lockInput)
		
		love.graphics.print(str1, 0, 20)
		love.graphics.print(str2, 0, 40)
		love.graphics.print(str3, 0, 60)
		love.graphics.print(str4, 0, 80)
		love.graphics.print(str5, 0, 100)
		love.graphics.print(str6, 0, 120)
		love.graphics.print(str7, 0, 140)
		
	end)
	return sword
end
function Sword:rotateBody(derivedRotation)
	-- self.body:setAngle(derivedRotation)
	self.fixture:setRotation(derivedRotation + pi /2)
	local centerX = self.parent.derivedPosition.x
	local centerY = self.parent.derivedPosition.y
	local x = centerX + swordLength * math.cos(derivedRotation + pi /2)
	local y = centerY + swordLength * math.sin(derivedRotation + pi /2)
	-- self.body:setPosition(x, y)
	self.fixture:setPosition(x, y)
end
function Sword:onUpdate(dt)
	if self.isRotate == true then
		self.rotateVelocity = self.rotateVelocity + self.rotateVelocity * dt
		
		if self.rotateVelocity > 5 * math.pi then
			self.rotateVelocity = 5 * math.pi
		end
		
		if self.oldRotation ~= nil then
			local powerUpRotation = self.rotateVelocity/(5 * math.pi) * maxPowerUpRotation
			self.powerUpRotation = powerUpRotation
			
			if math.abs(math.abs(self.oldRotation - self.parent.rotation) + powerUpRotation) < 0.01 then
				self.parent:setRotation(self.oldRotation + powerUpRotation)
				self:rotateBody(self.derivedRotation)
				self.powerUpBias = math.abs(self.parent.rotation - self.oldRotation)
				self.oldRotation = nil
			else
				self.parent:rotate(powerUpRotation * dt)
				self:rotateBody(self.derivedRotation)
				self.powerUpBias = math.abs(self.parent.rotation - self.oldRotation)
			end
		end
	end
	
	
	if self.beginRotate == true then
		local bias = dt * self.rotateVelocity
		self.parent:rotate(bias)
		-- self.body:setAngle(self.derivedRotation)
		self.fixture:setRotation(self.derivedRotation)
		if  math.abs(self.targetRotation - self.parent.rotation) < 0.2 then
			self.beginRotate = false
			self.parent:setRotation(self.targetRotation)
			self:rotateBody(self.derivedRotation)
			self.rotateVelocity = pi * 2
			self.lockInput = false
			self.attacking = false
		end
	end
		
	
	self.compensateRotation = -math.acos(Vector2.dot(self.currDir, self.newDir))
	
	if Vector2.cross(self.currDir, self.newDir) > 0 then
		self.compensateRotation = -self.compensateRotation
	end
	
	local bias = self.compensateRotation * self.compensateVel * dt
	
	if math.abs(bias) < 0.0001 then
		self.lockInput = false
	else
		self.lockInput = true
	end
	self.currDir = Vector2.rotate(self.currDir, bias)
	self.parent:rotate(bias)
	self:rotateBody(self.parent.rotation)
end

local flg = false
function Sword:keyReleased(key, unicode)
	if not self.lockInput and not flg then
		if key == 'j' then
			self.isRotate = false
			self.beginRotate = true
			self.targetRotation = self.parent.rotation + math.pi * 2 + self.powerUpBias
			self.oldRotation = nil
			self.lockInput = true
			self.attacking = true
		end
		self.isKeyPressed = false
	end
end

function Sword:keyPressed(key, unicode)
	if not self.lockInput then
		if key == 'j' then
			self.isRotate = true
			self.beginRotate = false
			if self.oldRotation == nil then
				self.oldRotation = self.parent.rotation
			end
		end
		self.isKeyPressed = true
		flg = false
	else
		flg = true
	end
 end