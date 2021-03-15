require("mineunit")

mineunit("core")

mineunit("common/chatcommands")

sourcefile("init")

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
		func("SX", "not valid number")
		assert.spy(minetest.chat_send_player).was.called(1)
	end)

	it("executes qos:clear", function()
		local func = minetest.registered_chatcommands["qos:clear"].func

		spy.on(minetest, "chat_send_player")
		func("SX")
		assert.spy(minetest.chat_send_player).was.called(3)

		spy.on(minetest, "chat_send_player")
		func("SX", "1")
		assert.spy(minetest.chat_send_player).was.called(1)

		spy.on(minetest, "chat_send_player")
		func("SX", "not valid number")
		assert.spy(minetest.chat_send_player).was.called(1)
	end)

end)
