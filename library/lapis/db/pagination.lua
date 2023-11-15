---@meta

--- Module `lapis.db.pagination`
---
--- [Pagination](https://leafo.net/lapis/reference/models.html#pagination)
local pagination = {}

---@class lapis.Paginator.opts : lapis.model.select_opts
---@field per_page? integer The number of items fetched per page
---@field prepared_results? fun(results: table[]) A function that is passed the results of any fetched page to prepare the objects before being returned from methods like `get_page`, `get_all`, and `each_item`. It should return the results after they have been prepared or updated.

--- Using the `paginated` method on models we can easily paginate through a query
--- that might otherwise return many results. The arguments are the same as the
--- `select` method but instead of the result it returns a special `Paginator`
--- object.
---
--- For example, say we have the following table and model:
---
--- ```lua
--- create_table("users", {
---    { "id", types.serial },
---    { "name", types.varchar },
---    { "group_id", types.foreign_key },
---
---    "PRIMARY KEY(id)"
--- })
---
--- local Users = Model:extend("users")
--- ```
---
--- We can create a paginator like so:
---
--- ```lua
--- local paginated = Users:paginated([[where group_id = ? order by name asc]], 123)
--- ```
---
--- The type of paginator created by the `paginated` class method is an
--- `OffsetPaginator`. This paginator uses `LIMIT` and `OFFSET` query clauses to
--- fetch pages. There is also an `OrderedPaginator` which is described below.
--- It can provide significantly increased performance for larger datasets given
--- the right indexes and circumstances are met.
---
--- Note: Always provide an `ORDER BY` clause when using a paginator or the
--- pages returned by the paginator may not be consistent.
---
--- A paginator can be configured by passing a table as the last argument.
---
--- Any additional options are passed directly to the `select` class method to
--- control the query. For example, `fields` can be used to restrict what
--- columns are fetched
---@class lapis.Paginator
---@overload fun(model: lapis.Model, clause?: string, ...: lapis.Paginator.opts | any): self
local Paginator = {}

--- Gets `page_num`th page, where pages are 1 indexed. The number of items per
--- page is controlled by the `per_page` option, and defaults to 10. Returns an
--- array table of model instances.
---
--- ```lua
--- `local page1 = paginated:get_page(1)
--- local page6 = paginated:get_page(6)
--- ```
---
--- ```sql
--- SELECT * from "users" where group_id = 123 order by name asc limit 10 offset 0
--- SELECT * from "users" where group_id = 123 order by name asc limit 10 offset 50
--- ```
---
--- Note: The OrderedPaginator fetches pages in a fundamentally different way,
--- see below for more information.
---@param page_num integer
---@return lapis.Entity[]
function Paginator:get_page(page_num) end

--- Returns an iterator function that can be used to iterate through each page
--- of the results. Useful for processing a large query without having the
--- entire result set loaded in memory at once.
---
--- Each item is preloaded with the `prepare_results` function if provided.
---
--- ```lua
--- for page_results, page_num in paginated:each_page() do
---    print(page_results, page_num)
--- end
--- ```
---
--- Note: Be careful modifying rows in the database when iterating over each
--- page, as your modifications might change the query result order and you may
--- process rows multiple times or none at all. Consider using a stable sorting
--- direction like the primary key ascending.
---
--- `starting_page` defaults to `1`
---@param starting_page? integer
---@return fun(self: lapis.Paginator): lapis.Entity[], integer
function Paginator:each_page(starting_page) end

--- Returns an iterator for every item returned by the pager. It uses `each_page`
--- to fetch results in chunks of `per_page` items. Because data is pulled
--- incrementally it's suitable for iterating over large data sets.
---
--- Each item is preloaded with the `prepare_results` function if provided.
---
--- Note: Iteration order can change if the table is modified during iteration,
--- see the warning on `each_page`.
---
--- ```lua
--- for item in pager:each_item() do
---    print(item.name)
--- end
--- ```
---@return fun(self: lapis.Paginator): lapis.Entity
function Paginator:each_item() end

pagination.Paginator = Paginator

--- This paginator uses `LIMIT` and `OFFSET` query clauses to fetch pages.
---
--- See Paginator to learn more.
---@class lapis.OffsetPaginator : lapis.Paginator
---@overload fun(model: lapis.Model, clause?: string, ...: any): self
local OffsetPaginator = {}

--- Gets every item from the paginator by issuing a single query, ignoring any
--- pagination options. If you have a large dataset you want to iterate over,
--- consider using `each_item` as it will query in chunks to reduce peak memory
--- usage.
---
--- Each item is preloaded with the `prepare_results` function if provided.
---
--- ```lua
--- local users = paginated:get_all()
--- ```
---
--- ```sql
--- SELECT * from "users" where group_id = 123 order by name asc
--- ```
---@return lapis.Entity[]
function OffsetPaginator:get_all() end

--- Returns the total number of pages.
---@return integer
function OffsetPaginator:num_pages() end

--- Checks to see if the paginator returns at least 1 item. Returns a boolean.
--- This is more efficient than counting the items and checking for a number
--- greater than 0 because the query generated by this function doesn't do any
--- counting.
---
--- ```lua
--- if pager:has_items() then
---    -- ...
--- end
--- ```
---
--- ```sql
--- SELECT 1 FROM "users" where group_id = 123 limit 1
--- ```
---@return boolean
function OffsetPaginator:has_items() end

--- Gets the total number of items that can be returned. The paginator will parse
--- the query and remove all clauses except for the `WHERE` when issuing a `COUNT`.
---
--- ```lua
--- local users = paginated:total_items()
--- ```
---
--- ```sql
--- SELECT COUNT(*) as c from "users" where group_id = 123
--- ```
---@return integer
function OffsetPaginator:total_items() end

pagination.OffsetPaginator = OffsetPaginator

--- The default paginator, also know as the `OffsetPaginator`, uses `LIMIT` and
--- `OFFSET` to handle fetching pages. For large data sets, this can become
--- inefficient for viewing later pages since the database has to scan past all
--- the preceding rows when handling the offset.
---
--- An alternative way to handling pagination is using a `WHERE` clause along
--- with an `ORDER` and `LIMIT`. If the right index is on the table then the
--- database can skip directly to the rows that should be contained in the page.
---
--- With this method you don't get page numbers, but instead must keep track of
--- the last index of the previous page. This is best represented with a
--- *load more* button on your site.
---
--- The `OrderedPaginator` class is a subclass of the `Paginator` that uses this
--- method to paginate results.
---
--- Here's an example model:
---
--- ```lua
--- create_table("events", {
---    { "id", types.serial },
---    { "user_id", types.foreign_key },
---    { "data", types.text },
---
---    "PRIMARY KEY(id)"
--- })
---
--- local Events = Model:extend("events")
--- ```
--- Here's how to instantiate an ordered paginator that can iterate over the
--- `events` table for a specific user id, in ascending order:
---
--- ```lua
--- local OrderedPaginator = require("lapis.db.pagination").OrderedPaginator
--- local pager = OrderedPaginator(Events, "id", "where user_id = ?", 123, {
---    per_page = 50
--- })
--- ```
---
--- The `OrderedPaginator` constructor function matches the same interface as
--- the regular `Paginator` except it takes an additional argument after the
--- model name: the name of the column(s) to order by.
---
--- Call `get_page` with no arguments to get the first page of results. In
--- addition to the results of the query, the addition arguments contain the
--- values that should be passed to get page to get the next page of results.
---
--- ```lua
--- -- get the first page
--- local results, next_page = pager:get_page()
---
--- -- get the next page
--- local results_2, next_page = pager:get_page(next_page)
--- ```
---
--- ```sql
--- SELECT * from "events" where user_id = 123 order by "events"."id" ASC limit 50
--- SELECT * from "events" where "events"."id" > 4832 and (user_id = 123) order by "events"."id" ASC limit 50
--- ```
---
--- ## Pagination order
---
--- The pagination order can be specified by the `order` field in the options
--- table. The default is `asc`.
---
--- ```lua
--- local OrderedPaginator = require("lapis.db.pagination").OrderedPaginator
--- local pager = OrderedPaginator(Events, "id", "where user_id = ?", 123, {
---    order = "desc",
--- })
--- ```
---
--- This will affect any calls to `get_page` on the paginator.
---
--- Additionally, the `after` and `before` methods on the paginator let you
--- fetch results in a specific order. They both share the same interface as
--- `get_page`, but `after` will always fetch ascending, and `before` will
--- always fetch descending.
---
--- ### Composite ordering
---
--- If you have a model that has a composite sorting key (made up of more than one
--- column), you can pass a table array as the ordering column:
---
--- ```lua
--- local OrderedPaginator = require("lapis.db.pagination").OrderedPaginator
--- local pager = OrderedPaginator(SomeModel, {"user_id", "post_id"})
--- ```
---
--- The `get_page` method on the paginator takes as many arguments as there are
--- columns. Additionally, it will return that many additional values after the
--- results to be passed on as the next page.
---
--- ```lua
--- -- get the first page
--- local results, last_user_id, last_post_id = pager:get_page()
---
--- -- get the next page
--- local results_2 = pager:get_page(last_user_id, last_post_id)
--- ```
---
--- ```sql
--- SELECT * from "some_model"
---   order by "some_model"."user_id" ASC, "some_model"."post_id" ASC limit 10
---
--- SELECT * from "some_model" where
---   ("some_model"."user_id", "some_model"."post_id") > (232, 582)
---   order by "some_model"."user_id" ASC, "some_model"."post_id" ASC limit 10
--- ```
---@class lapis.OrderedPaginator : lapis.Paginator
---@overload fun(model: lapis.Model, field: string, clause?: string, ...: lapis.Paginator.opts | any): self
local OrderedPaginator = {}

--- Calls `get_ordered` with the order being the initialized order
---@param ... any
---@return any
function OrderedPaginator:get_page(...) end

--- Calls `get_ordered` with the order being ascending
---@param ... any
---@return any
function OrderedPaginator:after(...) end

--- Calls `get_ordered` with the order being descending
---@param ... any
---@return any
function OrderedPaginator:before(...) end

--- Call `get_order` with no addition arguments to get the first page of results.
--- In addition to the results of the query, the addition arguments contain the
--- values that should be passed to get page to get the next page of results.
---@param order 'ASC' | 'DESC'
---@param ... any
---@return any
function OrderedPaginator:get_ordered(order, ...) end

pagination.OrderedPaginator = OrderedPaginator

return pagination
