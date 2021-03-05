local Queue = {}
Queue.__index = Queue

function Queue:push(value)
	if value and self.count < self.size then
		self.count = self.count + 1
		rawset(self, self.last, value)
		self.last = (self.last % self.size) + 1
		return true
	end
	return false
end

function Queue:pop()
	if self.count > 0 then
		local first = self.first
		self.first = (first % self.size) + 1
		local value = rawget(self, first)
		rawset(self, first, nil)
		self.count = self.count - 1
		return value
	end
end

--[[ Similar to above Queue:pop but does not perform cleanup, cannot be made thread safe and # breaks without __len
function Queue:pop()
	if self.count > 1 then
		local first = self.first
		self.first = (first % self.size) + 1
		self.count = self.count - 1
		return rawget(self, first)
	end
end
--]]

function Queue:clear()
	self.count = 0
	self.first = 1
	self.last = 1
end

-- With Lua 5.1 __len is not called for tables.
function Queue:__len()
	return self.count
end

function Queue.__newindex()
	error("Cannot assigns new values, use Queue:push(value) to add values to queue")
end

setmetatable(Queue, {
	__call = function(_, size)
		local obj = {
			size = size,
			count = 0,
			first = 1,
			last = 1,
		}
		return setmetatable(obj, Queue)
	end,
})

return Queue
