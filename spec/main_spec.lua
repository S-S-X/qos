require("mineunit")

mineunit("core")
mineunit("http")
mineunit("server")
mineunit("common/after")
mineunit("common/chatcommands")

sourcefile("init")

describe("QoS wrapped HTTP API", function()

	setup(function()
		-- Set fake current running mod name, mytestmod is added to secure.http_mods
		mineunit:set_current_modname("mytestmod")
	end)

	teardown(function()
		-- Restore current running mod name
		mineunit:restore_current_modname()
	end)

	it("wraps fetch for supplied object", function()
		local http = minetest.request_http_api()
		local qos_http = QoS(http, 2)

		local checkpoint = spy.new(function(data)
			-- HTTP response table gets through QoS
			assert.is_hashed(data)
		end)
		spy.on(http, "fetch")

		qos_http.fetch({ url = "http://127.0.0.1/" }, checkpoint)
		mineunit:execute_globalstep()

		-- checkpoint was called once, minetest default handler was not called
		assert.spy(checkpoint).was.called(1)
		assert.spy(http.fetch).was.called(0)
	end)

	it("pushes requests to QoS queue", function()
		local http = minetest.request_http_api()
		local qos_http = QoS(http, 2)

		local checkpoint = spy.new(function(data)
			-- HTTP response table gets through QoS
			assert.is_hashed(data)
		end)
		spy.on(http, "fetch")
		spy.on(QoS.data.queues[2], "push")

		-- Create 30 fetch requests, curl_parallel_limit = 12 (fixtures/minetest.cfg)
		for i=1,30 do qos_http.fetch({ url = "http://127.0.0.1/" }, checkpoint) end

		mineunit:execute_globalstep()

		-- checkpoint was called 9 times (at most 80% of curl_parallel_limit)
		assert.spy(checkpoint).was.called(9)
		-- priority 2 queue push was called 21 times: total 30 - executed 9 = queued 21
		assert.spy(QoS.data.queues[2].push).was.called(21)
		-- minetest default handler was not called
		assert.spy(http.fetch).was.called(0)
	end)

end)
