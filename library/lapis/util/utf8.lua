---@meta

--- Module `lapis.util.utf8`
---
--- This module includes a collection of LPeg patterns for working with UTF8
--- text.
local utf8 = {}

---@type any
--- A pattern that will trim all invisible characters from either side of the
--- matched string.
utf8.trim = ""

---@type any
--- A pattern that matches a single printable character. Note that printable
--- characters include whitespace, but don't include invalid unicode code points
--- or control characters.
utf8.printable_character = ""

---@type any
--- An optimal pattern that matches any unicode code points that are classified
--- as whitespace.
utf8.whitespace = ""

return utf8
