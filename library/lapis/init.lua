---@meta

--- Module `lapis`
---
--- Re-exports Application from `lapis.application`.
local lapis = {}

lapis.Application = require('lapis.application').Application

---@private
---@type table
lapis.app_cache = {}

--- Starts the Lapis router.
--- This function should be called in `content_by_lua_*`.
---@param app_cls string
function lapis.serve(app_cls) end

return lapis
