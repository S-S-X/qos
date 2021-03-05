
local curl_parallel_limit = tonumber(minetest.settings:get("curl_parallel_limit")) or 8

local defaults = {

	-- # General configuration:
	["info_priv"] = "basic_privs",
	["admin_priv"] = "basic_privs",
	["register_chatcommands"] = true,
	["enforce_timeouts"] = false,

	-- # Queue sizes:
	["queue_size.1"] = curl_parallel_limit * 16,
	["queue_size.2"] = curl_parallel_limit * 12,
	["queue_size.3"] = curl_parallel_limit * 8,

	-- # Timeouts:
	["max_timeout.1"] = 5,
	["max_timeout.2"] = 4,
	["max_timeout.3"] = 3,

	-- # Limits:
	["limits.1"] = curl_parallel_limit * 4, -- Limit queue utilization to 400% (push requests to engine queue)
	["limits.2"] = math.floor(curl_parallel_limit * 0.8), -- Limit queue utilization to 80%
	["limits.3"] = math.floor(curl_parallel_limit * 0.5), -- Limit queue utilization to 50%

}

function QoS.config(key)
	local value
	local keytype = type(defaults[key])

	-- Read value from configuration file
	if keytype == "string" then
		value = minetest.settings:get("qos." .. key) or defaults[key]
	elseif keytype == "number" then
		value = tonumber(minetest.settings:get("qos." .. key)) or defaults[key]
	elseif keytype == "boolean" then
		value = minetest.settings:get_bool("qos." .. key, defaults[key])
	else
		error("Invalid use of QoS.config, configuration key "..tostring(key).." does not exist")
	end

	value = type(defaults[key]) == "number" and tonumber(value) or value
	return value
end

local config = {

	curl_parallel_limit = curl_parallel_limit,

	qsizes = {
		QoS.config("queue_size.1"),
		QoS.config("queue_size.2"),
		QoS.config("queue_size.3"),
	},

	timeouts = {
		QoS.config("max_timeout.1"),
		QoS.config("max_timeout.2"),
		QoS.config("max_timeout.3"),
	},

	limits = {
		QoS.config("limits.1"),
		QoS.config("limits.2"),
		QoS.config("limits.3"),
	},

}

return config
