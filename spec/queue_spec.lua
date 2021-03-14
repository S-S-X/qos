require("mineunit")

local Queue = sourcefile("queue")

describe("Queue initialization", function()

	local q = Queue(4)

	it("sets initial counts", function()
		assert.equals(q.size, 4)
		assert.equals(q.count, 0)
	end)

	it("updates count", function()
		q:push(1)
		assert.equals(q.size, 4)
		assert.equals(q.count, 1)
	end)

	it("does not push nil values", function()
		local first = q.first
		local last = q.last

		q:push(nil)

		assert.equals(q.size, 4)
		assert.equals(q.count, 1)
		assert.equals(q.first, first)
		assert.equals(q.last, last)
	end)

	it("contains single value", function()
		assert.not_nil(q:pop())
		assert.is_nil(q:pop())

		assert.equals(q.size, 4)
		assert.equals(q.count, 0)
	end)

end)

describe("Queue", function()

	local q = Queue(4)

	it("returns correct values", function()
		q:push(11)
		q:push(12)
		q:push(13)
		q:push(14)
		assert.equals(q:pop(), 11)
		assert.equals(q:pop(), 12)
		assert.equals(q:pop(), 13)
		assert.equals(q:pop(), 14)
	end)

	it("discards data when full", function()
		assert.is_true(q:push(21))
		assert.is_true(q:push(22))
		assert.is_true(q:push(23))
		assert.is_true(q:push(24))
		assert.is_false(q:push(25))

		assert.equals(q.size, 4)
		assert.equals(q.count, 4)
	end)

	it("accepts data when not full", function()
		assert.equals(q:pop(), 21)
		assert.is_true(q:push(25))
		assert.is_false(q:push(26))

		assert.equals(q:pop(), 22)
		assert.is_true(q:push(26))
		assert.is_false(q:push(27))

		assert.equals(q.size, 4)
		assert.equals(q.count, 4)
	end)

	it("reduces counter", function()
		assert.equals(23, q:pop())
		assert.equals(3, q.count)

		assert.equals(24, q:pop())
		assert.equals(2, q.count)

		assert.equals(25, q:pop())
		assert.equals(1, q.count)

		assert.equals(26, q:pop())

		assert.equals(q.size, 4)
		assert.equals(q.count, 0)
	end)

	it("does not reduce counter when empty", function()
		q:pop()
		assert.equals(q.size, 4)
		assert.equals(q.count, 0)

		q:pop()
		assert.equals(q.size, 4)
		assert.equals(q.count, 0)
	end)

	it("clears queue", function()
		q:push(1)
		q:push(2)
		q:push(3)
		q:push(4)
		assert.equals(q.count, q.size)
		-- Clear queue
		q:clear()
		-- Check that queue is empty
		assert.equals(q.count, 0)
		assert.is_nil(q:pop())
		-- And size is not changed
		assert.equals(q.size, 4)
	end)

end)

describe("Queue direct access", function()

	local q = Queue(4)
	q:push(11)
	q:push(12)
	q:push(13)

	it("allows reading values", function()
		assert.equals(11, q[1])
		assert.equals(12, q[2])
		assert.equals(13, q[3])
		assert.is_nil(q[4])
	end)

	it("disallows adding values", function()
		assert.error(function() q[11] = 22 end)
	end)

	it("disallows writing values", function()
		pending("Behavior TBD")
		assert.error(function() q[1] = 21 end)
	end)

end)

describe("Queue # operator", function()

	local VERSION = tonumber(_VERSION:gmatch("%d%.%d")())

	local q = Queue(4)

	it("increments counter", function()
		q:push(10)
		q:push(10)
		q:push(10)
		q:push(10)

		assert.equals(q.count, 4)
		assert.equals(#q, 4)
	end)

	it("increments counter when not full", function()
		q:pop()
		q:push(10)
		q:push(10)

		assert.equals(q.count, 4)
		assert.equals(#q, 4)
	end)

	it("decrements counter", function()
		if VERSION <= 5.1 then
			pending("Table # operator override does not work with Lua <= 5.1")
		end

		q:pop()
		assert.equals(3, q.count)
		assert.equals(3, #q)

		q:pop()
		assert.equals(2, q.count)
		assert.equals(2, #q)

		q:pop()
		assert.equals(1, q.count)
		assert.equals(1, #q)

		q:pop()

		assert.equals(q.size, 4)
		assert.equals(q.count, 0)
		assert.equals(#q, 0)
	end)

	it("does not decrement counter when empty", function()
		if VERSION <= 5.1 then
			pending("Table # operator override does not work with Lua <= 5.1")
		end

		q:pop()
		assert.equals(q.count, 0)
		assert.equals(#q, 0)

		q:pop()
		assert.equals(q.size, 4)
		assert.equals(q.count, 0)
		assert.equals(#q, 0)
	end)

end)
