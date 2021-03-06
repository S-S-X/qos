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
		qos_http = QoS(http, 2)

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

end)
