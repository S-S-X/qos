![luacheck](https://github.com/S-S-X/qos/workflows/luacheck/badge.svg)
![mineunit](https://github.com/S-S-X/qos/workflows/mineunit/badge.svg)
![coverage](https://mineunit-badges.000webhostapp.com/S-S-X/qos/coverage)

## Minetest HTTP API QoS control queue

### Usage:

Function `QoS` returns HTTP API wrapped within simple request priority manager.
`HttpAPI QoS(http_api, default_priority = 3)`

Simply wrap `minetest.request_http_api` with `QoS` and you're good to go.

```lua
local http = minetest.request_http_api()

http = QoS and QoS(http, 2) or http
```

or alternative if you like:
```lua
local http = QoS and QoS(minetest.request_http_api(), 2) or minetest.request_http_api()
```

### Priorities

QoS comes with 3 priority levels without interesting names, priority levels are 1, 2 and 3.

Lowest number is highest priority and priority 1 requests can cause queue to get clogged.

Priorities 2 and 3 will always leave empty space for priority 1 requests and cannot completely fill queues ever.

Queued requests will be processed in first in, first out order but in a way that queued highest priority requests
will be handled first and lower priorities only if there's still free slots for parallel processing.

### Configuration

Configuration key value pairs goes to main `minetest.cfg`. Default values listed below.

Code for solving dynamic default values is shown between `<` and `>`.
Changing these values makes them static.

Important Minetest engine configuration keys:

* **`curl_parallel_limit = 8`**
  How many http requests can be parallelized by engine.
  It is recommended to increase this a bit when using qos mod.

QoS configuration keys:

* **`qos.info_priv = basic_privs`**
* **`qos.admin_priv = basic_privs`**
* **`qos.register_chatcommands = true`**
* **`qos.enforce_timeouts = false`**
* **`qos.queue_size.1 = <curl_parallel_limit * 16>`**
* **`qos.queue_size.2 = <curl_parallel_limit * 12>`**
* **`qos.queue_size.3 = <curl_parallel_limit * 8>`**
* **`qos.max_timeout.1 = 5`**
* **`qos.max_timeout.2 = 4`**
* **`qos.max_timeout.3 = 3`**
* **`qos.limits.1 = curl_parallel_limit * 4`**
  Limit queue utilization to 400%, this forces to overcommit requests to engine queue.
  Engine queues are not very efficient as of Minetest 5.4, for very large queues it is recommended to keep this smaller.
* **`qos.limits.2 = <math.floor(curl_parallel_limit * 0.8)>`**
  Limit queue utilization to 80% by default. Attempts to always leave at least 20% reserved for priority 1 requests.
* **`qos.limits.3 = <math.floor(curl_parallel_limit * 0.5)>`**
  Limit queue utilization to 50% by default. Attempts to always leaves at least 50% reserved for priority 2 and 1.

### Extras

#### Minetest HTTP API

QoS provides `priority_override` as last argument for HTTP API functions, this can be used to override default priority.

* **`http.fetch(req, callback, priority_override)`**
  If no `priority_override` provided then one given to `QoS(http_api, priority)` initialization function is used.
* **`http.fetch_async(req, priority_override)`**
  If no `priority_override` provided then one given to `QoS(http_api, priority)` initialization function is used.

#### Monitoring functions:

* **`QoS.queue_length(priority)`**
  Return total number of queued requests by priority. If priority not given then return sum of all priorities.
* **`QoS.active_requests()`**
  Return total number of active executed but not yet finished requests.
* **`QoS.active_utilization()`**
  Return % utilization of engine request queue.
* **`QoS.queue_size(priority)`**
  Return size of QoS request queue.
* **`QoS.utilization(priority)`**
  Return % utilization of queue by priority. If priority not given then aggregate utilization of all queues is returned.

#### Queue control API

* **`QoS.data.queues[<priority>]`**
  Direct access to queues, see `Queue`.
* **`QoS.data.dropped[<priority>]`**
  Dropped request counter. Behavior is about to change, currently ever increasing counters for dropped requests.

#### Queue objects accessible through QoS.data.queues

* **`Queue:push(value)`**
  Push variable to queue, normally should not be used externally.
* **`Queue:pop()`**
  Remove and return variable from queue, normally should not be used externally.
* **`Queue:clear()`**
  Clear all values from queue, does not return values.

#### Chat commands

* **`/qos:queue_length [priority]`**
  Return current QoS queue length.
* **`/qos:active_requests`**
  Return number of active requests executed with QoS controller.
* **`/qos:active_utilization`**
  Return current QoS active requests utilization  percentage value.
* **`/qos:utilization [priority]`**
  Return current QoS queue utilization percentage value.
* **`/qos:clear <priority>|all`**
  Clears selected or all queues. All queued requests are gone for good.
