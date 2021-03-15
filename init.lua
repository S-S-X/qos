
local modpath = minetest.get_modpath("qos")

QoS = {
	modpath = modpath,
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
