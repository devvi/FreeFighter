require "util"
local handlers = {}
Physics = {
}

function Physics.addHandler(h)
	table.insert(handlers, h)
end
function Physics.removeHandler(h)
	for k, v in ipairs(handlers) do
		if v == h then
			table.remove(handlers, k)
		end
	end
end

function Physics.beginContact(a, b, contact)
	writeLog_unit("Physics.beginContact")
	for k, v in ipairs(handlers) do
		if v.beginContact then
			if v.fixture == a then
				v:beginContact(a, b, contact)
			end
		end
	end
end

function Physics.endContact(a, b, contact)
	for k, v in ipairs(handlers) do
		if v.endContact then
			if v.fixture == a then
				v:endContact(a, b, contact)
			end
		end
	end
end

function Physics.postSolve(a, b, contact)
	for k, v in ipairs(handlers) do
		if v.postSolve then
			if v.fixture == a then
				v:postSolve(a, b, contact)
			end
		end
	end
end

function Physics.preSolve(a, b, contact)
	for k, v in ipairs(handlers) do
		if v.preSolve then
			if v.fixture == a then
				v:preSolve(a, b, contact)
			end
		end
	end
end