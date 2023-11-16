---@meta

--- Module `lapis.cache`
---
--- Lapis comes with a simple memory cache for caching the entire result of an
--- action keyed on the parameters it receives. This is useful for speeding up
--- the rendering of rarely changing pages because all database calls and HTML
--- methods can be skipped.
---
--- The Lapis cache uses the [shared dictionary
--- API](http://wiki.nginx.org/HttpLuaModule#lua_shared_dict) from HttpLuaModule.
--- The first thing you'll need to do is create a shared dictionary in your
--- Nginx configuration.
---
--- Add the following to your `http` block to create a 15mb cache:
---
--- ```nginx
--- lua_shared_dict page_cache 15m;
--- ```
---
--- Now we are ready to start using the caching module, `lapis.cache`.
---
--- [Caching](https://leafo.net/lapis/reference/utilities.html#caching)
local cache = {}

---@class lapis.cache.cached_opts
---@field dict_name? string override the name of the shared dictionary used (defaults to `"page_cache"`)
---@field exptime? integer how long in seconds the cache should stay alive, 0 is forever (defaults to `0`)
---@field cache_key? fun(req: lapis.Request): string set a custom function for generating the cache key (default is described above)
---@field when? fun(req: lapis.Request): boolean a function that should return truthy a value if the page should be cached. Receives the request object as first argument (defaults to `nil`)
---@field [integer] lapis.application.ActionFn

--- Wraps an action to use the cache.
---
--- ```lua
--- local lapis = require("lapis")
--- local cached = require("lapis.cache").cached
---
--- local app = lapis.Application()
---
--- app:match("my_page", "/hello/world", cached(function(self)
---    return "hello world!"
--- end))
--- ```
--- The first request to `/hello/world` will run the action and store the result
--- in the cache, all subsequent requests will skip the action and return the
--- text stored in the cache.
---
--- The cache will remember not only the raw text output, but also the content
--- type and status code.
---
--- The cache key also takes into account any GET parameters, so a request to
--- `/hello/world?one=two` is stored in a separate cache slot. Multiple
--- parameters are sorted so they can come in any order and still match the same
--- cache key.
---
--- When the cache is hit, a special response header is set to 1,
--- `x-memory-cache-hit`. This is useful for debugging your application to make
--- sure the cache is working.
---
--- Instead of passing a function as the action of the cache you can also pass
--- in a table. When passing in a table the function must be the first
--- numerically indexed item in the table.
---
--- For example, you could implement microcaching, where the page is cached for a
--- short period of time, like so:
---
--- ```lua
--- local lapis = require("lapis")
--- local cached = require("lapis.cache").cached
---
--- local app = lapis.Application()
---
--- app:match("/microcached", cached({
---    exptime = 1,
---    function(self)
---       return "hello world!"
---    end
--- }))
---
--- ```
---@param fn_or_table lapis.application.ActionFn|lapis.cache.cached_opts
---@return lapis.application.ActionFn
function cache.cached(fn_or_table) end

--- Deletes an entry from the cache. Key can either be a plain string, or a
--- tuple of `{path, params}` that will be encoded as the key.
---
--- ```lua
--- local cache = require("lapis.cache")
--- cache.delete({ "/hello", { thing = "world" } })
--- ```
---
--- `dict_name` defaults to `page_cache`
---@param key string|{ [1]: string, [2]: table }
---@param dict_name? string
function cache.delete(key, dict_name) end

--- Deletes all entries from the cache.
---
--- `dict_name` defaults to `page_cache`
---@param dict_name? string
function cache.delete_all(dict_name) end

--- Deletes all entries for a specific path.
---
--- ```lua
--- local cache = require("lapis.cache")
--- cache.delete_path("/hello")
--- ```
---
--- `dict_name` defaults to `page_cache`
---@param path string
---@param dict_name? string
function cache.delete_path(path, dict_name) end

return cache
