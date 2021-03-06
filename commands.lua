
minetest.register_chatcommand("qos:queue_length", {
	params = "[priority]",
	description = "Return current QoS queue length",
	privs = { [QoS.config("info_priv")] = true },
	func = function(name, priority)
		minetest.chat_send_player(name, ("QoS current queue length: %d"):format(QoS.queue_length(tonumber(priority))))
	end
})

minetest.register_chatcommand("qos:active_requests", {
	description = "Return number of active requests executed with QoS controller",
	privs = { [QoS.config("info_priv")] = true },
	func = function(name)
		minetest.chat_send_player(name, ("QoS active requests: %d"):format(QoS.active_requests()))
	end
})

minetest.register_chatcommand("qos:active_utilization", {
	description = "Return current QoS active requests utilization  percentage value",
	privs = { [QoS.config("info_priv")] = true },
	func = function(name)
		minetest.chat_send_player(name, ("QoS active utilization: %d%%"):format(QoS.active_utilization()))
	end
})

minetest.register_chatcommand("qos:utilization", {
	params = "[priority]",
	description = "Return current QoS queue utilization percentage value",
	privs = { [QoS.config("info_priv")] = true },
	func = function(name, priority)
		minetest.chat_send_player(name, ("QoS queue utilization: %d%%"):format(QoS.utilization(tonumber(priority))))
	end
})

minetest.register_chatcommand("qos:clear", {
	params = "[priority]",
	description = "Return current QoS queue utilization percentage value",
	privs = { [QoS.config("admin_priv")] = true },
	func = function(name, priority)
		if priority:find("%S") then
			local i = tonumber(priority)
			if i and QoS.data.queues[i] then
				local length = QoS.data.queues[i]
				QoS.data.queues[i]:clear()
				minetest.chat_send_player(name, ("QoS cleared %d priority %d entries"):format(length, i))
			else
				minetest.chat_send_player(name, "QoS clear: invalid priority, double check your input")
			end
		else
			for i, queue in ipairs() do
				local length = queue.count
				queue:clear()
				minetest.chat_send_player(name, ("QoS cleared %d priority %d entries"):format(length, i))
			end
		end
	end
})
