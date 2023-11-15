---@meta

--- Module `lapis.spec.server`
---
--- Provides the `request` function.
---
--- [request](https://leafo.net/lapis/reference/testing.html#using-the-test-server/request)
local server = {}

---@class lapis.request.options
---@field post? table A table of POST parameters. Sets default method to `"POST"`, encodes the table as the body of the request and sets the `Content-type` header to `application/x-www-form-urlencoded`
---@field data? string The body of the HTTP request as a string. The `Content-length` header is automatically set to the length of the string
---@field method? string The HTTP method to use (defaults to `"GET"`)
---@field headers? table<string, string> Additional HTTP request headers
---@field expect? 'json' What type of response to expect, currently only supports `"json"`. It will parse the body automatically into a Lua table or throw an error if the body is not valid JSON.
---@field port? integer The port of the server, defaults to the randomly assigned port defined automatically when running tests

--- To make HTTP request to the test server you can use the helper function
--- `request` found in `"lapis.spec.server"`. For example we might write a test to
--- make sure `/` loads without errors:
---
--- ```lua
--- local request = require("lapis.spec.server").request
--- local use_test_server = require("lapis.spec").use_test_server
---
--- describe("my site", function()
---    use_test_server()
---
---    it("should load /", function()
---       local status, body, headers = request("/")
---       assert.same(200, status)
---    end)
--- end)
--- ```
---
--- `path` is either a path or a full URL to request against the test server. If it
--- is a full URL then the hostname of the URL is extracted and inserted as the
--- `Host` header.
---
--- The `options` argument can be used to further configure the request.
---
--- The function has three return values: the status code as a number, the body of
--- the response and any response headers in a table.
---@param path string
---@param options? lapis.request.options
---@return integer, string|table, table<string, string>
function server.request(path, options) end

---@class lapis.Server
local Server = {}

--- Executes Lua code on the server.
---@param code string
function Server:exec(code) end

--- Returns the currently attached test server. This will provide a handle to the
--- server that enables you to execute code within that process.
---
--- The `exec` method will execute Lua code on the server.
---
--- ```lua
--- local get_current_server = require("lapis.spec.server").get_current_server
--- local use_test_server = require("lapis.spec").use_test_server
---
--- describe("my site", function()
---   use_test_server()
---
---   it("runs code on server", function()
---     local server = assert(get_current_server())
---     server:exec([[
---       require("myapp").some_variable = 100
---     ]])
---   end)
--- end)
--- ```
---@return lapis.Server
function server.get_current_server() end

return server
