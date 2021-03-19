
local function get_priority(priority)
	if priority then
		priority = tonumber(priority)
		if priority and QoS.data.queues[priority] then
			return priority
		end
		return false
	end
end

local function align(s, w)
	s = tostring(s)
	return s .. string.rep(' ', w - #s)
end

minetest.register_chatcommand("qos:queue_length", {
	params = "[<priority>]",
	description = "Return current QoS queue length",
	privs = { [QoS.config("info_priv")] = true },
	func = function(name, priority)
		priority = get_priority(priority)
		if priority then
			minetest.chat_send_player(name, ("QoS current queue length: %d"):format(QoS.queue_length(priority)))
		elseif priority == false then
			minetest.chat_send_player(name, "Invalid priority parameter, use empty or 1-"..#QoS.data.queues)
		else
			local rows = {}
			for i,_ in ipairs(QoS.data.queues) do
				table.insert(rows, (" %s %d%%"):format(align(i, 8), QoS.utilization(i)))
			end
			local total = QoS.queue_length()
			minetest.chat_send_player(name, ("QoS queue length %d in:\n%s"):format(total, table.concat(rows, "\n")))
		end
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
	params = "[<priority>]",
	description = "Return current QoS queue utilization percentage value",
	privs = { [QoS.config("info_priv")] = true },
	func = function(name, priority)
		priority = get_priority(priority)
		if priority then
			minetest.chat_send_player(name, ("QoS queue utilization: %d%%"):format(QoS.utilization(priority)))
		elseif priority == false then
			minetest.chat_send_player(name, "Invalid priority parameter, use empty or 1-"..#QoS.data.queues)
		else
			local rows = {}
			for i,_ in ipairs(QoS.data.queues) do
				table.insert(rows, (" %s %d%%"):format(align(i, 8), QoS.utilization(i)))
			end
			local total = QoS.utilization()
			minetest.chat_send_player(name, ("QoS queue utilization %d%% in:\n%s")
				:format(total, table.concat(rows, "\n"))
			)
		end
	end
})

minetest.register_chatcommand("qos:clear", {
	params = "<priority>|all",
	description = "Clear QoS queues by priority, clear all queues if piority is 'all'",
	privs = { [QoS.config("admin_priv")] = true },
	func = function(name, priority)
		if priority == "all" then
			for i, queue in ipairs(QoS.data.queues) do
				local length = queue.count
				queue:clear()
				minetest.chat_send_player(name, ("QoS cleared %d entries from priority %d"):format(length, i))
			end
		elseif get_priority(priority) then
			priority = get_priority(priority)
			local length = QoS.data.queues[priority].count
			QoS.data.queues[priority]:clear()
			minetest.chat_send_player(name, ("QoS cleared %d entries from priority %d"):format(length, priority))
		else
			minetest.chat_send_player(name, "Invalid priority parameter, use 1-"..#QoS.data.queues.." or 'all'")
		end
	end
})
