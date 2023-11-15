---@meta

--- Module `lapis.etlua`
---
--- Provides the `EtLuaWidget` class along with the etlua enable.
---
--- [EtLuaWidget](https://leafo.net/lapis/reference/etlua_templates.html#EtluaWidget)
--- |
--- [EtLua](https://leafo.net/lapis/reference/etlua_templates.html)
local etlua = {}

--- Lapis transparently converts `.etlua` files to `EtluaWidget`s when you
--- request them to be used as a template (after enabling `etlua`). You can
--- manually compile template code programmatically by interacting directly with
--- the `EtluaWidget` class.
---
--- It is not necessary to *enable* `etlua` if you are using the `EtluaWidget`
--- class directly. Instances of the `EtluaWidget` implement the *render*
--- interface necessary to be used in any place Lapis expects a template or view.
---
--- Note that `etlua` templates are *compiled* to enable them to render at the
--- highest possible performance. You should avoid compiling templates (eg.
--- `EtluaWidget:load()`) during every request or it may have a negative impact
--- on your performance. Cache the result as a Lua module or somewhere where it
--- can persist between requests.
---
--- The default constructor of the widget class will copy every field from the
--- `opts` argument to `self`, if the opts argument is provided. Values on `self`
--- will be available in scope for the template when it is rendered.
---@class lapis.EtLuaWidget : lapis.Widget
---@overload fun(opts?: table): self
local EtLuaWidget = {}

--- The `load` method takes a etlua template string, compiles it and creates a
--- new `EtluaWidget` class that can be used to render the template with
--- parameters.
---
--- ```lua
--- local etlua = require("lapis.etlua")
---
--- local MyWidget = etlua.EtluaWidget:load([[
---   <h1>Hello <%= username %></h1>
--- ]])
---
--- local w = MyWidget({ username = "Sylviettee" })
---
--- print(w:render_to_string()) --> <h1>Hello Sylviettee</h1>
--- ```
---@param template_code string
---@return lapis.EtLuaWidget
function EtLuaWidget:load(template_code) end

etlua.EtLuaWidget = etlua

return etlua
