require "player"
require "sword"
require "commandprocess"
require "util"
require "callphysicscb"
require "collision"
local world
local root = Node()
local player1
local player2
local sword

function love.load()
	player1 = Player(love.graphics.newImage("green_ball.png"))
	player1.id = "real player"
	root:addChild(player1)
	
	player2 = Player(love.graphics.newImage("green_ball.png"), world)
	player2:setPosition(400, 400)
	
	player2.id = "dummy player"
	root:addChild(player2)
	local swordPoint = Node()
	swordPoint.direction = {x = 0, y = 1}
	player1:addChild(swordPoint)
	
	sword = Sword(love.graphics.newImage("sword.png"), world)
	swordPoint:addChild(sword)
	player1.sword = sword
	
	-- hack for performance
	Collision.addContactTeamplate(sword.fixture, player2.fixture)
	
	
	
	InputManager.addListender(player1)
	InputManager.addListender(sword)
end

function love.keypressed(key, unicode)
	InputManager.KeyPressed(key)
end

function love.keyreleased(key, unicode)
	InputManager.KeyReleased(key)
end

function love.update(dt)
	updateNode(root, dt)
	updateTransform(root)
	Collision.solve()
end

function love.draw()
	--[[love.graphics.setColor(255, 0, 0)
	love.graphics.circle("line", player1.body:getX(), player1.body:getY(), player1.shape:getRadius())
	love.graphics.circle("line", player2.body:getX(), player2.body:getY(), player2.shape:getRadius())
	love.graphics.polygon("fill", sword.body:getWorldPoints(sword.shape:getPoints()))
	love.graphics.setColor(255, 255, 255)
	]]
	love.graphics.setColor(255, 0, 0)
	Collision.drawFixtures()
	love.graphics.setColor(255, 255, 255)
	
	drawNode(root)
	debugInfo:draw()
end