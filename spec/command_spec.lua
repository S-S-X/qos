require("mineunit")

mineunit("core")

mineunit("common/chatcommands")

sourcefile("init")

-- Patch spy.on method, see https://github.com/Olivine-Labs/luassert/pull/174
function spy.on(target_table, target_key)
	local s = spy.new(target_table[target_key])
	rawset(target_table, target_key, s)
	-- store original data
	s.target_table = target_table
	s.target_key = target_key
	return s
end

describe("Queue initialization", function()

	it("executes qos:queue_length", function()
		local func = minetest.registered_chatcommands["qos:queue_length"].func

		spy.on(minetest, "chat_send_player")
		func("SX")
		assert.spy(minetest.chat_send_player).was.called(1)

		spy.on(minetest, "chat_send_player")
		func("SX", "1")
		assert.spy(minetest.chat_send_player).was.called(1)

		spy.on(minetest, "chat_send_player")
		func("SX", "5")
		assert.spy(minetest.chat_send_player).was.called(1)

		spy.on(minetest, "chat_send_player")
		func("SX", "not valid number")
		assert.spy(minetest.chat_send_player).was.called(1)
	end)

	it("executes qos:active_requests", function()
		local func = minetest.registered_chatcommands["qos:active_requests"].func

		spy.on(minetest, "chat_send_player")
		func("SX")
		assert.spy(minetest.chat_send_player).was.called(1)
	end)

	it("executes qos:active_utilization", function()
		local func = minetest.registered_chatcommands["qos:active_utilization"].func

		spy.on(minetest, "chat_send_player")
		func("SX")
		assert.spy(minetest.chat_send_player).was.called(1)
	end)

	it("executes qos:utilization", function()
		local func = minetest.registered_chatcommands["qos:utilization"].func

		spy.on(minetest, "chat_send_player")
		func("SX")
		assert.spy(minetest.chat_send_player).was.called(1)

		spy.on(minetest, "chat_send_player")
		func("SX", "1")
		assert.spy(minetest.chat_send_player).was.called(1)

		spy.on(minetest, "chat_send_player")
		func("SX", "5")
		assert.spy(minetest.chat_send_player).was.called(1)

		spy.on(minetest, "chat_send_player")
		func("SX", "not valid number")
		assert.spy(minetest.chat_send_player).was.called(1)
	end)

	describe("qos:clear", function()

		local func = minetest.registered_chatcommands["qos:clear"].func
		local function spy_on_queues_clear()
			spy.on(QoS.data.queues[1], "clear")
			spy.on(QoS.data.queues[2], "clear")
			spy.on(QoS.data.queues[3], "clear")
		end

		it("clears all queues", function()
			spy.on(minetest, "chat_send_player")
			spy_on_queues_clear()
			func("SX", "all")
			assert.spy(minetest.chat_send_player).was.called(3)
			assert.spy(QoS.data.queues[1].clear).was.called(1)
			assert.spy(QoS.data.queues[2].clear).was.called(1)
			assert.spy(QoS.data.queues[3].clear).was.called(1)
		end)

		it("clears selected queue", function()
			spy.on(minetest, "chat_send_player")
			spy_on_queues_clear()
			func("SX", "1")
			assert.spy(minetest.chat_send_player).was.called(1)
			assert.spy(QoS.data.queues[1].clear).was.called(1)
			assert.spy(QoS.data.queues[2].clear).was.called(0)
			assert.spy(QoS.data.queues[3].clear).was.called(0)
		end)

		it("does not attempt clearing nonexistent queue", function()
			spy.on(minetest, "chat_send_player")
			spy_on_queues_clear()
			func("SX", "5")
			assert.spy(minetest.chat_send_player).was.called(1)
			assert.spy(QoS.data.queues[1].clear).was.called(0)
			assert.spy(QoS.data.queues[2].clear).was.called(0)
			assert.spy(QoS.data.queues[3].clear).was.called(0)
		end)

		it("does not clear with invalid arguments", function()
			spy.on(minetest, "chat_send_player")
			spy_on_queues_clear()
			func("SX", "not valid number")
			assert.spy(minetest.chat_send_player).was.called(1)
			assert.spy(QoS.data.queues[1].clear).was.called(0)
			assert.spy(QoS.data.queues[2].clear).was.called(0)
			assert.spy(QoS.data.queues[3].clear).was.called(0)
		end)

		it("does not clear with empty arguments", function()
			spy.on(minetest, "chat_send_player")
			spy_on_queues_clear()
			func("SX")
			assert.spy(minetest.chat_send_player).was.called(1)
			assert.spy(QoS.data.queues[1].clear).was.called(0)
			assert.spy(QoS.data.queues[2].clear).was.called(0)
			assert.spy(QoS.data.queues[3].clear).was.called(0)
		end)

	end)

end)
