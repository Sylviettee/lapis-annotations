---@meta

--- Module `lapis.config`
---
--- [Configuration](https://leafo.net/lapis/reference/configuration.html)
---@overload fun(environment: string|string[], opts: table)
local config = {}

--- Returns the configuration for the selected `environment`.
---@param environment? string
---@return table
function config.get(environment) end

return config
