
local modpath = minetest.get_modpath("qos")

QoS = {
	modpath = modpath,
	-- List of mods wrapped with QoS
	http_mods_enabled = {},
	-- List of mods not wrapped with QoS
	http_mods_bypass = {},
	data = {},
}

QoS._config = dofile(modpath .. "/config.lua")

if QoS._config.curl_parallel_limit < 2 then
	-- QoS could be used with curl_parallel_limit = 1 too but in that case real problem is elsewhere
	dofile(modpath .. "/noop.lua")
	return
end

if QoS.config("register_chatcommands") then
	dofile(modpath .. "/commands.lua")
end

dofile(modpath .. "/main.lua")

minetest.register_on_mods_loaded(function()
	for modname in pairs(QoS._config.http_mods) do
		if not QoS.http_mods_enabled[modname] then
			table.insert(QoS.http_mods_bypass, modname)
		end
	end
end)
