---@meta

--- Module `lapis.html`
---
--- [Widget](https://leafo.net/lapis/reference/html_generation.html#widget-methods)
--- |
--- [Html Methods](https://leafo.net/lapis/reference/html_generation.html#html-module)
local html = {}

--- The default constructor of the `Widget` class will copy every field from the
--- `opts` argument to `self`, if the `opts` argument is provided. You can use
--- this to set render-time parameters or override methods.
---
--- ```lua
--- local Widget = require("lapis.html").Widget
---
--- local SomeWidget = Widget:extend({
---    content = function(self)
---      div("Hello ", self.name)
---    end
--- })
---
--- local w = SomeWidget({ name = "Sylviettee" })
--- print(widget:render_to_string()) --> <div>Hello Sylviettee</div>
--- ```
---
--- It is safe to override the constructor and not call `super` if you want to
--- change the initialization conditions of your widget.
---@class lapis.Widget
---@overload fun(opts?: table): self
local Widget = {}

--- Creates a new subclass of the `Widget` base class. The `fields` argument is
--- a table of properties that will be copied into the instance metatable of the
--- newly created class, or it can be a function and it will be set as the
--- content field.
---
--- `name` is not directly used by Lapis but it can be helpful to provide it for
--- debugging and for implementing systems that derive details about the
--- rendered output based on the name of the widget (eg. automatically generated
--- a class based on the widget’s name)
---
--- `setup_fn` is an optional function that will be called with the class object
--- as the only argument. This function is called after properties have been set
--- but before any `__inherited` callbacks are called. The default Widget class
--- does not have any `__inherited` callbacks so it is not necessary to use this
--- function unless you specifically need that behavior for a subclass you have
--- created.
---
--- This method returns the newly created class object, followed by the instance
--- metatable.
---
--- ```lua
--- local SomeWidget = Widget:extend(function(self)
---    return div("Hello world!")
--- end)
--- print(SomeWidget():render_to_string())
--- ```
---@param name string
---@param fields? table
---@param setup_fn? function
---@overload fun(self: lapis.Widget, fields?: table, init_fn?: function): lapis.Widget, lapis.Widget
---@return lapis.Widget
---@return lapis.Widget
function Widget:extend(name, fields, setup_fn) end

--- Makes the methods and properties from another class available on the widget
--- class. This can be used to implement a form a multiple inheritance for
--- sharing code across many widgets without having to change the parent-class.
---
--- The argument `other_class` can either be a reference to a class, or a string.
--- If it's a string, it will be passed to `require`. The module should return a
--- class to be included.
---
--- When including another class, the widget's class hierarchy is changed: A
--- dynamic *mixins* class is created exactly one level above the widget class.
--- This dynamically inserted class will contain all the copied fields from any
--- included classes. A widget will only ever have one mixins class created for
--- it, regardless of how many classes are included. The mixins class's parent
--- class will be the original parent class of the widget when it was first
--- defined.
---
--- As an example, if given the following class hierarchy:
---
--- `LoginPage < Pages < lapis.Widget`
---
--- The first call to `include` within `LoginPage` will change the class
--- hierarchy to:
---
--- `LoginPage < LoginPageMixins < Pages < lapis.Widget`
---
--- The dynamically inserted class `LoginPageMixins` will contain all the fields
--- copied from the included classes.
---
--- Because of this organization, the following hold true:
---
--- * Any methods or properties declared directly on the widget will take
--- precedence over any fields in the mixins class.
--- * `super` can be used in the widget's methods to access overridden methods
--- in the mixin class
--- * The included class is able to use `super`, but it will point to the
--- widget's original parent class, and not to a method in the hierarchy of the
--- included class
--- * If the included class is using inheritance, the hierarchy is flattened
--- when fields are copied into the mixins class
--- * Because there is only one mixin class per widget class, if multiple
--- included classes implement the same fields, they will be overwritten by
--- subsequent calls to `include`. It is not possible to access overwritten
--- properties
---
--- The function `is_mixins_class` from the `lapis.html` module can be used to
--- determine if a class is a mixins class or not.
---@param other_class table
---@return any
function Widget:include(other_class) end

--- Renders the `content` method of a widget and returns the string result. This
--- will automatically create a temporary buffer for the duration of the render.
--- This internally calls `widget.render()` with the temporary buffer.
---
--- Keep in mind that widgets must be executed in a special scope to enable the
--- HTML builder functions to work. It is not possible to call the `content`
--- method directly on the widget if you wish to render it, you must use this
--- method.
---@return string
function Widget:render_to_string() end

--- Renders the `content` method of the widget to the provided buffer. Under
--- normal circumstances it is not necessary to use this method directly.
--- However, it's worth noting it exists to avoid accidentally overwriting the
--- method when sub-classing your own widgets.
---
--- This method returns nothing.
---@param buffer string[]
---@param ... string
function Widget:render(buffer, ...) end

--- `content_for` is used for sending HTML or strings from the view to the
--- layout. You've probably already seen `@content_for "inner"` if you've looked
--- at layouts. By default the content of the view is placed in the content
--- block called `"inner"`.
---
--- If `content_for` is called multiple times on the same `name`, the results
--- will be appended, not overwritten.
---
--- You can create arbitrary content blocks from the view by calling
--- `@content_for` with a name and some content:
---
--- You can use either strings or builder functions as the content.
---
--- To access the content from the layout, call `@content_for` without the
--- content argument:
---
--- If a string is used as the value of a content block then it will be escaped
--- before written to the buffer. If you want to insert a raw string then you
--- can use a builder function in conjunction with the `raw` function:
---@param name string
---@param content string | function | lapis.Widget
function Widget:content_for(name, content) end

--- Checks to see if content for `name` is set.
---@param name string
function Widget:has_content_for(name) end

html.Widget = Widget

--- Runs the function, `fn` in the HTML rendering context.
--- Returns the resulting HTML as a string.
---@param fn function
---@return string
function html.render_html(fn) end

--- Escapes any HTML special characters in the string. The following are escaped:
---
--- * `&` - `&amp;`
--- * `<` - `&lt;`
--- * `>` - `&gt;`
--- * `"` - `&quot;`
--- * `'` - `&#039;`
---@param str string
---@return string
function html.escape(str) end

--- Converts a nested Lua table into a HTML class attribute string.
--- Passing a string to this function will return the string unmodified.
---
--- This function is applied to the value of the class attribute when using the
--- HTML builder syntax.
---
--- ```lua
--- classnames({
---    "one",
---    "two",
---    yes = true,
---    {
---       skipped = false,
---       haveit = true,
---       "",
---       "last"
---    }
--- }) --> "one two yes haveit last"
---@param t table
---@return string
function html.classnames(t) end

--- Returns `true` if the argument `obj` is an auto-generated mixin class that
--- is inserted into the class hierarchy of a widget when `Widget:include` is
--- called.
---@param obj table
---@return boolean
function html.is_mixins_class(obj) end

return html
