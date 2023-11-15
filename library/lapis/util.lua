---@meta

--- Module `lapis.util`
---
--- [Functions](https://leafo.net/lapis/reference/utilities.html#functions)
local util = {}

--- URL unescapes string
---@param str string
---@return string
function util.unescape(str) end

--- URL escapes string
---@param str string
---@return string
function util.escape(str) end

--- Parses query string into a table
---@param str string
---@return table<string, string>
function util.parse_query_string(str) end

--- Converts a key,value table into a query string
---@param tbl table<string, string|number|boolean>
---@return string
function util.encode_query_string(tbl) end

--- Convert CamelCase to camel_case.
---@param str string
---@return string
function util.underscore(str) end

--- Converts a string to a slug suitable for a URL. Removes all whitespace and
--- symbols and replaces them with `-`.
---@param str string
---@return string
function util.slugify(str) end

--- Iterates over array table `tbl` appending all unique values into a new array
--- table, then returns the new one.
---@param tbl any[]
---@return any[]
function util.uniquify(tbl) end

--- Trims the whitespace off of both sides of a string. Note that this function
--- is only aware of ASCII whitespace characters, such as space, newline, tab,
--- etc.
--- For full Unicode/UTF8 support see the `lapis.util.utf8` module
---@param str string
---@return string
function util.trim(str) end

--- Trims the whitespace off of all values in a table. Uses `pairs` to traverse
--- every key in the table.
---
--- The table is modified in place.
---@param tbl string[]
function util.trim_all(tbl) end

--- Trims the whitespace off of all values in a table. The entry is removed from
--- the table if the result is an empty string.
---
--- If an array table `keys` is supplied then any other keys not in that list
--- are removed (with `nil`, not the `empty_val`)
---
--- If `empty_val` is provided then the whitespace only values are replaced with
--- that value instead of `nil`
---
--- The table is modified in place.
---
--- ```lua
--- local db = require("lapis.db")
--- local trim_filter = require("lapis.util").trim_filter
---
--- unknown_input = {
---   username = "     hello    ",
---   level = "admin",
---   description = " "
--- }
---
--- trim_filter(unknown_input, {"username", "description"}, db.NULL)
---
--- -- unknown input is now:
--- -- {
--- --   username = "hello",
--- --   description = db.NULL
--- -- }
--- ```
---@param tbl table<string, any>
---@param keys? string[]
---@param empty_val? any
function util.trim_filter(tbl, keys, empty_val) end

--- Converts `obj` to JSON. Will strip recursion and things that can not be
--- encoded.
---@param obj table
---@return string
function util.to_json(obj) end

--- Converts JSON to table, a direct wrapper around Lua CJSON's `decode`.
---@param str string
---@return table
function util.from_json(str) end

--- Returns a string in the format "1 day ago".
---
--- `parts` allows you to add more words. With `parts=2`, the string
--- returned would be in the format `1 day, 4 hours ago`.
---@param date string | osdate
---@param parts? number
---@param suffix? string
---@return string
function util.time_ago_in_words(date, parts, suffix) end

--- Makes it so accessing an unset value in `tbl` will run a `require` to search
--- for the value. Useful for autoloading components split across many files.
--- Overwrites `__index metamethod`. The result of the require is stored in the
--- table.
---
--- ```lua
--- local models = autoload("models")
---
--- local _ = models.HelloWorld --> will require "models.hello_world"
--- local _ = models.foo_bar --> will require "models.foo_bar"
--- ```
---@param prefix string
---@param tbl? table
---@return table
function util.autoload(prefix, tbl) end

return util
