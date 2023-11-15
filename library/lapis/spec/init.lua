---@meta

--- Module `lapis.spec`
---
--- Provides the `use_test_server` and `close_test_server` functions.
---
--- [Using the Test Server](https://leafo.net/lapis/reference/testing.html#using-the-test-server)
local spec = {}

--- The `use_test_server` function will ensure that the test server is running for
--- the duration of the specs within the block:
---
--- ```lua
--- local use_test_server = require("lapis.spec").use_test_server
---
--- describe("my site", function()
---    use_test_server()
---    -- write some tests that use the server here
--- end)
--- ```
---
--- The test server will either spawn a new Nginx if one isn't running, or it
--- will take over your development server until `close_test_server` is called
--- (`use_test_server` automatically calls that for you, but you can call it
--- manually if you wish). Taking over the development server can be useful
--- because the same stdout is used, so any output from the server is written to
--- a terminal you might already have open.
function spec.use_test_server() end

--- Closes the test server
function spec.close_test_server() end

return spec
