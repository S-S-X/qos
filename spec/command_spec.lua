require("mineunit")

mineunit("core")

mineunit("common/chatcommands")
mineunit("server")
mineunit("player")

sourcefile("init")

mineunit:mods_loaded()

describe("Queue initialization", function()

	local SX = Player("SX", { basic_privs = true })

	it("executes qos:queue_length", function()
		spy.on(minetest, "chat_send_player")
		SX:send_chat_message("/qos:queue_length")
		assert.spy(minetest.chat_send_player).was.called()

		spy.on(minetest, "chat_send_player")
		SX:send_chat_message("/qos:queue_length 1")
		assert.spy(minetest.chat_send_player).was.called()

		spy.on(minetest, "chat_send_player")
		SX:send_chat_message("/qos:queue_length 5")
		assert.spy(minetest.chat_send_player).was.called()

		spy.on(minetest, "chat_send_player")
		SX:send_chat_message("/qos:queue_length not valid number")
		assert.spy(minetest.chat_send_player).was.called()
	end)

	it("executes qos:active_requests", function()
		spy.on(minetest, "chat_send_player")
		SX:send_chat_message("/qos:active_requests")
		assert.spy(minetest.chat_send_player).was.called()
	end)

	it("executes qos:active_utilization", function()
		spy.on(minetest, "chat_send_player")
		SX:send_chat_message("/qos:active_utilization")
		assert.spy(minetest.chat_send_player).was.called()
	end)

	it("executes qos:utilization", function()
		spy.on(minetest, "chat_send_player")
		SX:send_chat_message("/qos:utilization")
		assert.spy(minetest.chat_send_player).was.called()

		spy.on(minetest, "chat_send_player")
		SX:send_chat_message("/qos:utilization 1")
		assert.spy(minetest.chat_send_player).was.called()

		spy.on(minetest, "chat_send_player")
		SX:send_chat_message("/qos:utilization 5")
		assert.spy(minetest.chat_send_player).was.called()

		spy.on(minetest, "chat_send_player")
		SX:send_chat_message("/qos:utilization not valid number")
		assert.spy(minetest.chat_send_player).was.called()
	end)

	describe("qos:clear", function()
		local function spy_on_queues_clear()
			spy.on(QoS.data.queues[1], "clear")
			spy.on(QoS.data.queues[2], "clear")
			spy.on(QoS.data.queues[3], "clear")
		end

		it("clears all queues", function()
			spy.on(minetest, "chat_send_player")
			spy_on_queues_clear()
			SX:send_chat_message("/qos:clear all")
			assert.spy(minetest.chat_send_player).was.called()
			assert.spy(QoS.data.queues[1].clear).was.called()
			assert.spy(QoS.data.queues[2].clear).was.called()
			assert.spy(QoS.data.queues[3].clear).was.called()
		end)

		it("clears selected queue", function()
			spy.on(minetest, "chat_send_player")
			spy_on_queues_clear()
			SX:send_chat_message("/qos:clear 1")
			assert.spy(minetest.chat_send_player).was.called()
			assert.spy(QoS.data.queues[1].clear).was.called()
			assert.spy(QoS.data.queues[2].clear).was.not_called()
			assert.spy(QoS.data.queues[3].clear).was.not_called()
		end)

		it("does not attempt clearing nonexistent queue", function()
			spy.on(minetest, "chat_send_player")
			spy_on_queues_clear()
			SX:send_chat_message("/qos:clear 5")
			assert.spy(minetest.chat_send_player).was.called()
			assert.spy(QoS.data.queues[1].clear).was.not_called()
			assert.spy(QoS.data.queues[2].clear).was.not_called()
			assert.spy(QoS.data.queues[3].clear).was.not_called()
		end)

		it("does not clear with invalid arguments", function()
			spy.on(minetest, "chat_send_player")
			spy_on_queues_clear()
			SX:send_chat_message("/qos:clear not valid number")
			assert.spy(minetest.chat_send_player).was.called()
			assert.spy(QoS.data.queues[1].clear).was.not_called()
			assert.spy(QoS.data.queues[2].clear).was.not_called()
			assert.spy(QoS.data.queues[3].clear).was.not_called()
		end)

		it("does not clear with empty arguments", function()
			spy.on(minetest, "chat_send_player")
			spy_on_queues_clear()
			SX:send_chat_message("/qos:clear")
			assert.spy(minetest.chat_send_player).was.called()
			assert.spy(QoS.data.queues[1].clear).was.not_called()
			assert.spy(QoS.data.queues[2].clear).was.not_called()
			assert.spy(QoS.data.queues[3].clear).was.not_called()
		end)

	end)

end)
