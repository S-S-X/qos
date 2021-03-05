
-- Do not load actual QoS functionality at all, add noop wrapper with annoying messages.
-- After loading this file mod should stop doing anything else.

local function wrapper(_, arg1)
	print("QoS control is disabled for " .. tostring(minetest.get_current_modname()))
	print("curl_parallel_limit setting too low for efficient priority control")
	return arg1
end

setmetatable(QoS, {
	__call = wrapper,
	__index = function(self) return wrapper(nil, self) end,
})

QoS.__index = QoS
