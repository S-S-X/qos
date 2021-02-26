
local limit = tonumber(minetest.settings:get("curl_parallel_limit")) or 8

if limit < 2 then
	function qos(http_api)
		print("QoS control is disabled for " .. minetest.get_current_modname())
		print("curl_parallel_limit setting too low for efficient priority control")
		return http_api
	end
end

local Queue = dofile(minetest.get_modpath("qos") .. "/queue.lua")

local qsizes = {
	tonumber(minetest.settings:get("qos.queue_size.1")) or (limit * 24),
	tonumber(minetest.settings:get("qos.queue_size.2")) or (limit * 16),
	tonumber(minetest.settings:get("qos.queue_size.3")) or (limit * 12),
}

local timeouts = {
	tonumber(minetest.settings:get("qos.max_timeout.1")) or 30,
	tonumber(minetest.settings:get("qos.max_timeout.2")) or 6,
	tonumber(minetest.settings:get("qos.max_timeout.3")) or 4,
}

local limits = {
	limit * math.ceil(qsizes[1] / 2), -- Forces pushing high priority requests to engine queue
	math.floor(limit * 0.8), -- Keep at least 20% of internal queue available for high priority requests
	math.floor(limit * 0.5), -- Keep at least 50% of internal queue available for normal + high priority requests
}

-- Queues for priority 1, 2 and 3
local queues = { Queue(qsizes[1]), Queue(qsizes[2]), Queue(qsizes[3]) }

function queues:push(priority, value)
	return self[priority]:push(value)
end

function queues:pop(priority)
	return self[priority]:pop()
end

function queues:execute(priority)
	local queue = self[priority]
	if queue.count > 0 then
		local count = math.min(queue.count, limits[priority])
		for _=1,count do
			queue:pop()()
		end
	end
end

local rc = 0

function QoS(http_api, default_priority)
	if http_api then
		-- Each API instance gets isolated api and future request handles
		local priority = default_priority or 3
		local api = http_api
		local handle_index = 0
		local handles = {}
		local obj = {}

		-- TODO: Optimize to handle full queue at once if more than single response is available
		local function fetch(req, callback)
			rc = rc + 1
			req.timeout = math.min(req.timeout, timeouts[priority])
			local handle = api.fetch_async(req)
			local function update_http_status()
				local res = api.fetch_async_get(handle)
				if res and res.completed then
					rc = rc - 1
					callback(res)
				else
					core.after(0, update_http_status)
				end
			end
			core.after(0, update_http_status)
		end

		local function fetch_async(req, index, priority_override)
			rc = rc + 1
			req.timeout = timeouts[priority_override or priority]
			handles[index] = api.fetch_async(req)
		end

		function obj.fetch_async(req, priority_override)
			local p = priority_override or priority
			if rc < limits[p] then
				-- Execute request directly when below limits
				return fetch_async(req, p)
			end
			-- Reserve future handle and queue request when above limits
			handle_index = handle_index + 1
			handles[handle_index] = true
			queues:push(p, function() local index = handle_index; fetch_async(req, index, p) end)
			return handle_index
		end

		function obj.fetch_async_get(handle)
			local real_handle = handles[handle]
			if real_handle == true then
				-- This request is queued and not yet executed
				return {}
			elseif real_handle then
				-- This request was queued and handle should
				local res = api.fetch_async_get(real_handle)
				if res.completed then
					rc = rc - 1
					handles[handle] = nil
				end
				return res
			else
				-- This request was never queued and uses handle provided by engine
				local res = api.fetch_async_get(handle)
				if res.completed then
					rc = rc - 1
				end
				return res
			end
		end

		function obj.fetch(req, callback, priority_override)
			local p = priority_override or priority
			if rc < limits[p] then
				-- Execute request when below limits
				fetch(req, callback)
			else
				-- Queue request when above limits
				--print("QoS control queueing request for", minetest.get_current_modname(), req.url)
				queues:push(p, function() fetch(req, callback) end)
			end
		end

		print("QoS control enabled for " .. minetest.get_current_modname())
		return obj
	else
		print("QoS control HTTP API request failed for " .. minetest.get_current_modname())
	end
end
qos = QoS

minetest.register_globalstep(function()
	if rc < limits[1] then queues:execute(1) else return end
	if rc < limits[2] then queues:execute(2) else return end
	if rc < limits[3] then queues:execute(3) else return end
end)
