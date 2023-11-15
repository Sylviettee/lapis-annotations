---@meta

--- Module `lapis.application`
---
--- Provides the `Application` class along with some helpers.
---
--- [Application](https://leafo.net/lapis/reference/actions.html#application-methods)
--- |
--- [Helpers](https://leafo.net/lapis/reference/utilities.html#application-helpers)
local application = {}

---@alias lapis.application.ActionFn fun(self: lapis.Request): string|lapis.Request.options, lapis.Request.options?

---@class lapis.Application
---@overload fun(opts?: table): self
local Application = {}

--- Specifies a view that will be used to wrap the content of the results
--- response in. A `layout` is always rendered around the result of the
--- action’s render unless layout is set to false, or a renderer with a
--- separate content type is used (eg. `json`)
---
--- Can either be an instance of a view or a string. When a string is provided,
--- the layout is loaded as a module via the require using the module name
--- `{views_prefix}.{layout_name}`.
---
--- Default `require('lapis.views.layout')`
Application.layout = require('lapis.views.layout')

--- View used to render an unrecoverable error in the default `handle_error`
--- callback. The value of this field is passed directly to Render Option
--- `render`, enabling the use of specifying the page by view name or directly
--- by a widget or template.
---
--- Default `require('lapis.views.error')`
Application.error_page = require('lapis.views.error')

--- A prefix appended to the view name (joined by .) whenever a view is
--- specified by string to determine the full module name to require.
---
--- Default `'views'`
Application.views_prefix = 'views'

--- A prefix appended to the action name (joined by .) whenever an action is
--- specified by string to determine the full module name to require.
---
--- Default `'actions'`
Application.actions_prefix = 'actions'

--- A prefix appended to the flow name (joined by .) whenever a flow is
--- specified by string to determine the full module name to require.
---
--- Default `'flows'`
Application.flows_prefix = 'flows'

--- The class that will be used to instantiate new request objects when
--- dispatching a request.
---
--- Default `require('lapis.request')`
---
---@see lapis.Request
Application.Request = require('lapis.request')

--- When a request does not match any of the routes you've defined, the
--- `default_route` method will be called to create a response.
---
--- A default implementation is provided:
---
--- ```lua
--- function app:default_route()
--- -- strip trailing /
---    if self.req.parsed_url.path:match("./$") then
---       local stripped = self.req.parsed_url:match("^(.+)/+$")
---       return {
---          redirect_to = self:build_url(stripped, {
---          status = 301,
---          query = self.req.parsed_url.query,
---          })
---       }
---    else
---       self.app.handle_404(self)
---    end
--- end
--- ```
---
--- The default implementation will check for excess trailing `/` on the end of
--- the URL it will attempt to redirect to a version without the trailing slash.
--- Otherwise it will call the `handle_404` method on the application.
---
--- This method, `default_route`, is a normal method of your application. You
--- can override it to do whatever you like. For example, this adds logging:
---
--- ```lua
--- function app:default_route()
---    ngx.log(ngx.NOTICE, "User hit unknown path " .. self.req.parsed_url.path)
---
---    -- call the original implementation to preserve the functionality it provides
---    return lapis.Application.default_route(self)
--- end
--- ```
function Application:default_route() end

--- In the default default_route, the method `handle_404` is called when the
--- path of the request did not match any routes.
---
--- A default implementation is provided:
---
--- ```lua
--- function app:handle_404()
---    error("Failed to find route: " .. self.req.request_uri)
--- end
--- ```
---
--- This will trigger a 500 error and a stack trace on every invalid request.
--- If you want to make a proper 404 page this is where you would do it.
---
--- Overriding the `handle_404` method instead of `default_route` allows us to
--- create a custom 404 page while still keeping the trailing slash removal code.
---
--- Here’s a simple 404 handler that just prints the text "Not Found!"
---
--- ```lua
--- function app:handle_404()
---    return { status = 404, layout = false, "Not Found!" }
--- end
--- ```
function Application:handle_404() end

--- Every action executed by Lapis is wrapped by `xpcall`. This ensures fatal
--- errors can be captured and a meaningful error page can be generated instead
--- of the server’s default error page, which may not be useful.
---
--- The error handler should only be used to capture fatal and unexpected errors,
--- expected errors are discussed in the Exception Handling guide.
---
--- Lapis comes with an error handler pre-defined that extracts information
--- about the error and renders the template specified by
--- `application.error_page`. This error page contains a stack trace and the
--- error message.
---
--- If you want to have your own error handling logic you can override the
--- method handle_error:
---
--- ```lua
--- config.custom_error_page is made up for this example
--- function app:handle_error(err, trace)
---    if config.custom_error_page then
---       return { render = "my_custom_error_page" }
---    else
---       return lapis.Application.handle_error(self, err, trace)
---    end
--- end
--- ```
---
--- The request object, or `self`, passed to the error handler is not the one
--- that was created for the request that failed. Lapis provides a new one since
--- the existing one maybe have been partially written to when it failed.
---
--- You can access the original request object with self.original_request
---
--- Lapis' default error page shows an entire stack trace, so it’s recommended
--- to replace it with a custom one in your production environments, and log the
--- exception in the background.
---
--- The lapis-exceptions module augments the error handler to records errors in
--- a database. It can also email you when there’s an exception.
---@param err string
---@param trace string
function Application:handle_error(err, trace) end

--- You can configure a cookie’s settings by overriding the the
--- `cookie_attributes` method on your application. Here’s an example that adds
--- an expiration date to cookies to make them persist:
---
--- ```lua
--- local date = require("date")
--- local app = lapis.Application()
---
--- app.cookie_attributes = function(self)
---   local expires = date(true):adddays(365):fmt("${http}")
---   return "Expires=" .. expires .. "; Path=/; HttpOnly"
--- end
--- ```
---
--- The `cookie_attributes` method takes the request object as the first
--- argument (`self`) and then the name and value of the cookie being processed.
---@param self lapis.Request
---@return string
function Application.cookie_attributes(self) end

--- Adds a new route to the route group contained by the application.
--- Note that routes are inheritance by the inheritance change of the
--- application object.
---
--- You can overwrite a route by re-using the same route name, or path, and that
--- route will take precedence over one defined further up in the inheritance
--- change.
---
--- Class approach:
---
--- ```lua
--- local app = lapis.Application:extend()
---
--- app:match("index", "/index", function(self) return "Hello world!" end)
--- app:match("/about", function(self) return "My site is cool" end)
--- ```
---
--- Instance approach:
---
--- ```lua
--- local app = lapis.Application()
--- app:match("index", "/index", function(self)
---   return "Hello world!"
--- end)
--- app:match("/about", function(self)
---   return "My site is cool"
--- end)
--- ```
---@param route_name string
---@param route_patch string
---@param action_fn lapis.application.ActionFn
---@overload fun(self: lapis.Application, route_patch: string, action_fn: lapis.application.ActionFn))
function Application:match(route_name, route_patch, action_fn) end

Application.get = Application.match
Application.post = Application.match
Application.delete = Application.match
Application.put = Application.match

--- Loads a module named `feature` using `require`. If the result of that module
--- is callable, then it will be called with one argument, `application`.
---@param feature string
function Application:enable(feature) end

--- Appends a before filter to the chain of filters for the application.
--- Before filters are applied in the order they are added. They receive one
--- argument, the request object.
---
--- A before filter is a function that will run before the action’s function.
--- If a `write` takes place in a before filter then the request is ended after
--- the before filter finishes executing. Any remaining before filters and the
--- action function are not called.
---@param fn lapis.application.ActionFn
function Application:before_filter(fn) end


---@class lapis.Application.include_opts
---@field path? string If provided, every path copied over will be prefixed with the value of this option. It should start with a `/` and a trailing slash should be included if desired.
---@field name? string If provided, every route name will be prefixed with the value of the this option. Provide a trailing `.` if desired.

--- Copies all the routes from `other_app` into the current app. `other_app` can
--- be either an application class or an instance. If there are any before
--- filters in `other_app`, every action of `other_app` will be be wrapped in a
--- new function that calls those before filters before calling the original
--- function.
---
--- Options can either be provided in the argument `opts`, or will be pulled
--- from `other_app`, with precedence going to the value provided in `opts`
--- if provided.
---
--- Note that application instance configuration like `layout` and `views_prefix`
--- are not kept from the included application.
---@param other_app lapis.Application
---@param opts? lapis.Application.include_opts
function Application:include(other_app, opts) end

--- Searches the inheritance chain for the first action specified by the route
--- name, `name`.
---
--- Returns the `action` value and the route path object if an action could be
--- found. If `resolve` is `true` the action value will be loaded if it’s a
--- deferred action like `true` or a module name
---
--- Returns `nil` if no action could be found.
---@param name string
---@param resolve? boolean
---@return any?
function Application:find_action(name, resolve) end

--- Creates a subclass of the Application class. This method is only available
--- on the class object, not the instance. Instance fields can be provided as
--- via the `fields` argument or by mutating the returned metatable object.
---
--- This method returns the newly created class object, and the metatable for
--- any instances of the class.
---
--- ```lua
--- local MyApp, MyApp_mt = lapis.Application:extend("MyApp", {
---    layout = "custom_layout",
---    views_prefix = "widgets"
--- })
---
--- function MyApp_mt:handle_error(err)
---    error("oh no!")
--- end
---
--- -- note that `match` is a class method, so MyApp_mt is not used here
--- MyApp:match("home", "/", function(self) return "Hello world!" end)
--- ```
---@param name string
---@param fields? table
---@param setup_fn? function
---@overload fun(self: lapis.Application, fields?: table, setup_fn?: function): lapis.Application, lapis.Application
---@return lapis.Application
---@return lapis.Application
function Application:extend(name, fields, setup_fn) end

application.Request = Application.Request
application.Application = Application

---@class lapis.application.respond_to_opts
---@field GET? lapis.application.ActionFn
---@field HEAD? lapis.application.ActionFn
---@field POST? lapis.application.ActionFn
---@field PUT? lapis.application.ActionFn
---@field DELETE? lapis.application.ActionFn
---@field CONNECT? lapis.application.ActionFn
---@field OPTIONS? lapis.application.ActionFn
---@field TRACE? lapis.application.ActionFn
---@field PATCH? lapis.application.ActionFn
---@field before? lapis.application.ActionFn

--- `verbs_to_fn` is a table of functions that maps a HTTP verb to a
--- corresponding function. Returns a new function that dispatches to the
--- correct function in the table based on the verb of the request.
---
--- If an action for `HEAD` does not exist Lapis inserts the following function
--- to render nothing:
---
--- ```lua
--- function() return { layout = false } end
--- ```
---
--- If the request is a verb that is not handled then the Lua `error` function
--- is called and a 500 page is generated.
---
--- A special `before` key can be set to a function that should run before any
--- other action. If `self.write` is called inside the before function then the
--- regular handler will not be called.
---@param verbs_to_fn? lapis.application.respond_to_opts
function application.respond_to(verbs_to_fn) end

--- Wraps a function to catch errors sent by `yield_error` or `assert_error`.
---
--- If the first argument is a function then that function is called on request
--- and the following default error handler is used:
---
--- ```lua
--- function() return { render = true } end
--- ```
---
--- If a table is the first argument then the `1`st element of the table is used
--- as the action and value of `on_error` is used as the error handler.
---
--- When an error is yielded then the `self.errors` variable is set on the
--- current request and the error handler is called.
---@param fn_or_tbl lapis.application.ActionFn | table
---@return lapis.application.ActionFn
function application.capture_errors(fn_or_tbl) end

--- A wrapper for `capture_errors` that passes in the following error handler:
---
--- ```lua
--- function(self) return { json = { errors = self.errors } } end
--- ```
---@param fn lapis.application.ActionFn
---@return lapis.application.ActionFn
function application.capture_errors_json(fn) end

--- Yields a single error message to be captured by `capture_errors`.
---@param error_message string
function application.yield_error(error_message) end

--- Works like Lua’s `assert` but instead of triggering a Lua error it triggers
--- an error to be captured by `capture_errors`
---@generic T
---@param v? T
---@param message? any
---@return T
---@return any ...
function application.assert_error(v, message, ...) end

--- Return a new function that will parse the body of the request as JSON and 
--- inject it into `self.params` if the `Content-Type` is set to
--- `application/json`. Suitable for wrapping an action handler to make it aware
--- of JSON encoded requests.
---
--- ```lua
--- local json_params = require("lapis.application").json_params
---
--- app:match("/json", json_params(function(self)
---   return self.params.value
--- end))
--- ```
---
--- ```bash
--- $ curl \
---   -H "Content-type: application/json" \
---   -d '{"value": "hello"}' \
---   'https://localhost:8080/json'
--- ```
---
--- The unmerged parameters can also be accessed from `self.json`. If there was
--- an error parsing the JSON then `self.json` will be `nil` and the request
--- will continue without error.
---@param fn lapis.application.ActionFn
---@return lapis.application.ActionFn
function application.json_params(fn) end

return application
