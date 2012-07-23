local oo = require "loop.simple"

local function _updatePosition(node)
	node.posChangedFlg = true
	for i, child in ipairs(node.children) do
		child.posChangedFlg = true
		_updatePosition(child)
	end
end

local function _updateRotation(node)
	node.rotChangedFlg = true
	for i, child in ipairs(node.children) do
		child.rotChangedFlg = true
		_updateRotation(child)
	end
end

local function _updateScale(node)
	node.scaleChangedFlg = true
	for i, child in ipairs(node.children) do
		child.scaleChangedFlg = true
		_updateScale(child)
	end
end

function updateTransform(node)
	for i, child in ipairs(node.children) do
		if child.posChangedFlg then
			child.derivedPosition.x = child.position.x + node.derivedPosition.x
			child.derivedPosition.y = child.position.y + node.derivedPosition.y
			child.posChangedFlg = false
		end
		if child.rotChangedFlg then
			child.derivedRotation = child.rotation + node.derivedRotation
			child.rotChangedFlg = false
		end
		if child.scaleChangedFlg then
			child.derivedScale.x = child.scale.x + node.derivedScale.x
			child.derivedScale.y = child.scale.y + node.derivedScale.y
			child.scaleChangedFlg = false
		end
		updateTransform(child)
	end

end

function updateNode(node, dt)
	for k, child in ipairs(node.children) do
		if child.onUpdate ~= nil then
			child:onUpdate(dt)
		end
		updateNode(child, dt)
	end
end

function drawNode(node)
	for k, child in ipairs(node.children) do
		if child.onDraw ~= nil then
			child:onDraw()
		end
		drawNode(child)
	end
end

Node = oo.class({
}, nil)

function Node:__init()
	local node = oo.rawnew(self, {})
	node.children = {}
	node.image = nil
	node.rotation = 0
	node.position = {x = 0, y = 0}
	node.direction = {x = 1, y = 0}
	node.center = {x = 0, y = 0}
	node.scale = {x = 1, y = 1}
	node.derivedPosition = {x = 0, y = 0}
	node.derivedRotation = 0
	node.derivedScale = {x = 1, y = 1}
	node.visible = true
	return node
end

function Node:updateCache()
	_updatePosition(self)
	_updateRotation(self)
	_updateScale(self)
end

function Node:addChild(child)
	local children = self.children
	table.insert(children, child)
	child.parent = self
end

function Node:removeChild(child)
	for k,v in ipairs(self.children) do
		if v == child then
			child.parent = nil
			table.remove(children, k)
		end
	end
end

function Node:setParent(parent)
	parent:addChild(self)
end

function Node:setPosition(x, y)
	self.position.x = x
	self.position.y = y
	_updatePosition(self)
end

function Node:translate(x, y)
	self.position.x = self.position.x + x
	self.position.y = self.position.y + y
	_updatePosition(self)
end

function Node:getDerivedPosition()
	return self.derivedPosition
end

function Node:getDerivedRotation()
	return self.derivedRotation
end

function Node:setRotation(rotation)
	self.rotation = rotation
	self.direction = Vector2.rotate(self.direction, rotation - self.rotation)
	_updateRotation(self)
end

function Node:rotate(rotation)
	self.rotation = self.rotation + rotation
	self.direction = Vector2.rotate(self.direction, rotation)
	_updateRotation(self)
end

function Node:onDraw()
	--writeLog_unit("draw")
	if self.image ~= nil then
		if self.visible == true then
			local parent = self.parent
			if parent ~= nil then
				-- writeLog_unit(printNode("parent", parent))
				-- writeLog_unit(printNode("self", self))
				love.graphics.push()
				love.graphics.translate(parent.derivedPosition.x, parent.derivedPosition.y)
				love.graphics.rotate(parent.derivedRotation)
				love.graphics.scale(parent.derivedScale.x, parent.derivedScale.y)
				love.graphics.draw(self.image, self.position.x, self.position.y, self.rotation, self.scale.x, self.scale.y, self.center.x, self.center.y, 0, 0)
				love.graphics.pop()
			else
				love.graphics.draw(self.image, self.position.x, self.position.y, self.rotation, self.scale.x, self.scale.y, self.center.x, self.center.y, 0, 0)
			end
		end
	end
end
