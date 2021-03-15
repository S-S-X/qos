require("mineunit")

mineunit("core")

describe("Mod noop initialization", function()

	local core_settings

	setup(function()
		-- Replace configuration file
		core_settings = core_settings or core.settings
		core.settings = Settings("minetest_noop.cfg")
	end)

	teardown(function()
		-- Restore configuration file
		core.settings = core_settings
	end)

	it("Wont crash", function()
		sourcefile("init")
	end)

	it("Does not load QoS", function()
		-- Noop wrapper does not have actual data or functionality
		local data = rawget(QoS, "data")
		assert.not_equal(data, QoS.data)
	end)

end)
