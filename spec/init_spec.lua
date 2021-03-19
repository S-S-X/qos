require("mineunit")

mineunit("core")

describe("Mod initialization", function()

	it("Wont crash", function()
		sourcefile("init")
	end)

	it("Wont crash if initialized with nil", function()
		QoS(nil)
		QoS()
	end)

	it("Wont crash if initialized with nil and priority", function()
		QoS(nil, 2)
	end)

end)
