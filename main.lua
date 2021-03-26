
local parallel_limit = QoS._config.curl_parallel_limit
local limits = QoS._config.limits
local qsizes = QoS._config.qsizes
local timeouts = QoS._config.timeouts

local Queue = dofile(QoS.modpath .. "/queue.lua")

-- Dropped requests never to be seen again, something is terribly wrong if there's even single request recorded here
QoS.data.dropped = {0,0,0}
local dropped = QoS.data.dropped

-- Construct Queues for priorities 1, 2 and 3
QoS.data.queues = { Queue(qsizes[1]), Queue(qsizes[2]), Queue(qsizes[3]) }
local queues = QoS.data.queues

function queues:push(priority, value)
	local success = self[priority]:push(value)
	if not success then
		dropped[priority] = dropped[priority] + 1
	end
	return success
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

function QoS.queue_length(priority)
	if priority then
		return queues[priority].count
	end
	local count = 0
	for i=1,#queues do
		count = count + queues[i].count
	end
	return count
end

function QoS.active_requests()
	return rc
end

function QoS.active_utilization()
	return rc > 0 and (rc / parallel_limit * 100) or 0
end

function QoS.queue_size(priority)
	if priority then
		return qsizes[priority]
	end
	local size = 0
	for i=1,#qsizes do
		size = size + qsizes[i]
	end
	return size
end

function QoS.utilization(priority)
	local count = priority and queues[priority].count or QoS.queue_length()
	local size = priority and qsizes[priority] or QoS.queue_size()
	return count > 0 and (count / size * 100) or 0
end

local function QoS_wrapper(_, http_api, default_priority)
	local modname = minetest.get_current_modname()
	if http_api then
		-- Each API instance gets isolated api and future request handles
		local priority = default_priority or 3
		local max_timeout = timeouts[priority]
		local api = http_api
		local handle_index = 0
		local handles = {}
		local obj = {}
		-- Functions
		local fetch
		local fetch_async

		local function get_timeout(timeout, priority_override)
			-- Timeout for connection in seconds. Engine default is 3 seconds.
			return math.min(timeout or 3, priority_override and timeouts[priority_override] or max_timeout)
		end

		if QoS.config("enforce_timeouts") then
			-- TODO: Optimize to handle full queue at once if more than single response is available
			function fetch(req, callback, priority_override)
				rc = rc + 1
				req.timeout = get_timeout(req.timeout, priority_override)
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

			function fetch_async(req, index, priority_override)
				rc = rc + 1
				req.timeout = get_timeout(req.timeout, priority_override)
				handles[index] = api.fetch_async(req)
				return index
			end
		else
			-- TODO: Optimize to handle full queue at once if more than single response is available
			function fetch(req, callback)
				rc = rc + 1
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

			function fetch_async(req, index)
				rc = rc + 1
				handles[index] = api.fetch_async(req)
				return index
			end
		end

		function obj.fetch_async(req, priority_override)
			-- Reserve future handle
			handle_index = handle_index + 1
			local p = priority_override or priority
			-- Check queue limits for selected priority
			if rc < limits[p] then
				-- Execute request directly
				return fetch_async(req, handle_index, p)
			elseif queues:push(p, function() local index = handle_index; fetch_async(req, index, p) end) then
				-- Queue request
				handles[handle_index] = true
				return handle_index
			end
			-- Queues are full, return nothing. Request failed and will not be executed ever.
		end

		function obj.fetch_async_get(handle)
			local real_handle = handles[handle]
			if real_handle == true then
				-- This request is queued and not yet executed
				return {}
			elseif real_handle then
				-- This request was queued
				local res = api.fetch_async_get(real_handle)
				if res.completed then
					rc = rc - 1
					handles[handle] = nil
				end
				return res
			end
			error("QoS fetch_async_get invalid handle")
		end

		function obj.fetch(req, callback, priority_override)
			local p = priority_override or priority
			if rc < limits[p] then
				-- Execute request when below limits
				fetch(req, callback, priority_override)
			else
				-- Queue request when above limits
				--print("QoS control queueing request for", minetest.get_current_modname(), req.url)
				queues:push(p, function() fetch(req, callback) end)
			end
		end

		print("QoS control enabled for " .. modname)
		QoS.http_mods_enabled[modname] = true
		return obj
	else
		print("QoS control HTTP API request failed for " .. modname)
	end
end

setmetatable(QoS, { __call = QoS_wrapper })

minetest.register_globalstep(function()
	if rc < limits[1] then queues:execute(1) else return end
	if rc < limits[2] then queues:execute(2) else return end
	if rc < limits[3] then queues:execute(3) else return end
end)
