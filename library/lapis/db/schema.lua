---@meta

--- Module `lapis.db.schema`
---
--- Lapis comes with a collection of tools for creating your database schema
--- inside of the `lapis.db.schema` module.
---
--- [Schema](https://leafo.net/lapis/reference/database.html#database-schemas)
local schema = {}

--- The first argument to `create_table` is the name of the table and the second
--- argument is an array table that describes the table.
---
--- ```lua
--- local schema = require("lapis.db.schema")
---
--- local types = schema.types
---
--- schema.create_table("users", {
---    {"id", types.serial},
---    {"username", types.varchar},
---
---    "PRIMARY KEY (id)"
--- })
--- ```
---
--- Note: In MySQL you should use `types.id` to get an auto-incrementing primary
--- key ID. Additionally you should not specify `PRIMARY KEY (id)` either.
---
--- This will generate the following SQL:
---
--- ```sql
--- CREATE TABLE IF NOT EXISTS "users" (
---   "id" serial NOT NULL,
---   "username" character varying(255) NOT NULL,
---   PRIMARY KEY (id)
--- );
--- ```
---
--- The items in the second argument to `create_table` can either be a table, or
--- a string. When the value is a table it is treated as a column/type tuple:
---
---     { column_name, column_type }
---
--- They are both plain strings. The column name will be escaped automatically.
--- The column type will be inserted verbatim after it is passed through
--- `tostring`. `schema.types` has a collection of common types that can be used.
--- For example, `schema.types.varchar` evaluates to `character varying(255) NOT
--- NULL`. See more about types below.
---
--- If the value to the second argument is a string then it is inserted directly
--- into the `CREATE TABLE` statement, that's how we create the primary key
--- above.
---@param table_name string
---@param declarations (string|{[1]: string, [2]: lapis.schema.type})[]
function schema.create_table(table_name, declarations) end

--- Drops a table.
---
--- ```lua
--- schema.drop_table("users")
--- ```
---
--- ```sql
--- DROP TABLE IF EXISTS "users";
--- ```
---@param table_name string
function schema.drop_table(table_name) end

---@class lapis.schema.index_opts
---@field unique? boolean
---@field where? lapis.db.condition

--- `create_index` is used to add new indexes to a table. The first argument is a
--- table, the rest of the arguments are the ordered columns that make up the
--- index. Optionally the last argument can be a Lua table of options.
---
--- There are two options `unique: BOOL`, `where: clause_string`.
---
--- `create_index` will also check if the index exists before attempting to create
--- it. If the index exists then nothing will happen.
---
--- Here are some example indexes:
---
--- ```lua
--- local create_index = schema.create_index
---
--- create_index("users", "created_at")
--- create_index("users", "username", { unique = true })
---
--- create_index("posts", "category", "title")
--- create_index("uploads", "name", { where = "not deleted" })
--- ```
---
--- This will generate the following SQL:
---
--- ```sql
--- CREATE INDEX ON "users" (created_at);
--- CREATE UNIQUE INDEX ON "users" (username);
--- CREATE INDEX ON "posts" (category, title);
--- CREATE INDEX ON "uploads" (name) WHERE not deleted;
--- ```
---@param table_name string
---@param ... string|lapis.schema.index_opts
function schema.create_index(table_name, ...) end

--- Drops an index from a table. It calculates the name of the index from the
--- table name and columns. This is the same as the default index name generated
--- by database on creation.
---
--- ```lua
--- local drop_index = schema.drop_index
---
--- drop_index("users", "created_at")
--- drop_index("posts", "title", "published")
--- ```
---
--- This will generate the following SQL:
---
--- ```sql
--- DROP INDEX IF EXISTS "users_created_at_idx"
--- DROP INDEX IF EXISTS "posts_title_published_idx"
--- ```
---@param table_name string
---@param ... string
function schema.drop_index(table_name, ...) end

--- Adds a column to a table.
---
--- ```lua
--- schema.add_column("users", "age", types.integer)
--- ```
---
--- Generates the SQL:
---
--- ```sql
--- ALTER TABLE "users" ADD COLUMN "age" integer NOT NULL DEFAULT 0
--- ```
---@param table_name string
---@param column_name string
---@param column_type string
function schema.add_column(table_name, column_name, column_type) end

--- Removes a column from a table.
---
--- ```lua
--- schema.drop_column("users", "age")
--- ```
---
--- Generates the SQL:
---
--- ```sql
--- ALTER TABLE "users" DROP COLUMN "age"
--- ```
---@param table_name string
---@param column_name string
function schema.drop_column(table_name, column_name) end

--- Changes the name of a column.
---
--- ```lua
--- schema.rename_column("users", "age", "lifespan")
--- ```
---
--- Generates the SQL:
---
--- ```sql
--- ALTER TABLE "users" RENAME COLUMN "age" TO "lifespan"
--- ```
---@param table_name string
---@param old_name string
---@param new_name string
function schema.rename_column(table_name, old_name, new_name) end

--- Changes the name of a table.
---
--- ```lua
--- schema.rename_table("users", "members")
--- ```
---
--- Generates the SQL:
---
--- ```sql
--- ALTER TABLE "users" RENAME TO "members"
--- ```
---@param old_name string
---@param new_name string
function schema.rename_table(old_name, new_name) end

--- All of the column type generators are stored in `schema.types`. All the types
--- are special objects that can either be turned into a type declaration string
--- with `tostring`, or called like a function to be customized.
---
--- Here are all the default values:
---
--- ```lua
--- local types = require("lapis.db.schema").types
---
--- print(types.boolean)       --> boolean NOT NULL DEFAULT FALSE
--- print(types.date)          --> date NOT NULL
--- print(types.double)        --> double precision NOT NULL DEFAULT 0
--- print(types.foreign_key)   --> integer NOT NULL
--- print(types.integer)       --> integer NOT NULL DEFAULT 0
--- print(types.numeric)       --> numeric NOT NULL DEFAULT 0
--- print(types.real)          --> real NOT NULL DEFAULT 0
--- print(types.serial)        --> serial NOT NULL
--- print(types.text)          --> text NOT NULL
--- print(types.time)          --> timestamp without time zone NOT NULL
--- print(types.varchar)       --> character varying(255) NOT NULL
--- print(types.enum)          --> smallint NOT NULL
--- ```
---
--- You'll notice everything is `NOT NULL` by default, and the numeric types have
--- defaults of 0 and boolean false.
---
--- When a type is called like a function it takes one argument, a table of
--- options.
---
--- Here are some examples:
---
--- ```lua
--- types.integer({ default = 1, null = true })  --> integer DEFAULT 1
--- types.integer({ primary_key = true })        --> integer NOT NULL DEFAULT 0 PRIMARY KEY
--- types.text({ null = true })                  --> text
--- types.varchar({ primary_key = true })        --> character varying(255) NOT NULL PRIMARY KEY
--- types.real({ array = true })                 --> real[]
--- ```
---@class lapis.schema.types
---@field [string] lapis.schema.type
local types = {}

---@class lapis.schema.type_opts
---@field default? any sets default value
---@field null? boolean determines if the column is `NOT NULL`
---@field unique? boolean determines if the column has a unique index
---@field primary_key? boolean determines if the column is the primary key
---@field array? boolean|integer makes the type an array (PostgreSQL Only), pass number to set how many dimensions the array is, `true` == `1`
---@field auto_increment? boolean makes the type automatically increment (MySQL Only)

---@class lapis.schema.time_opts : lapis.schema.type_opts
---@field timezone? boolean

---@alias lapis.schema.type string | fun(opts?: lapis.schema.type_opts): string

---@type lapis.schema.type
types.id = ""

---@type lapis.schema.type
types.boolean = ""

---@type lapis.schema.type
types.date = ""

---@type lapis.schema.type
types.double = ""

---@type lapis.schema.type
types.foreign_key = ""

---@type lapis.schema.type
types.integer = ""

---@type lapis.schema.type
types.numeric = ""

---@type lapis.schema.type
types.real = ""

---@type lapis.schema.type
types.serial = ""

---@type lapis.schema.type
types.text = ""

---@type lapis.schema.type
types.varchar = ""

---@type lapis.schema.type
types.enum = ""

---@type string | fun(opts?: lapis.schema.time_opts): string
types.time = ""

schema.types = types

return schema
