local singletons = require "kong.singletons"
local utils = require "kong.tools.utils"
local url = require "socket.url"
local Errors = require "kong.dao.errors"
local db_errors = require "kong.db.errors"
local cache = singletons.cache
local dao_factory = singletons.dao

ngx.log(ngx.CRIT, "########## DAOS.LUA ######## OPENED DAOS")


local function check_unique(jwt)
  ngx.log(ngx.CRIT, "########## DAOS.LUA ######## FUNCTION CHECK_UNIQUE")
  ngx.log(ngx.CRIT, jwt)
  -- If dao required to make this work in integration tests when adding fixtures
  if singletons.dao and ctk2.jwt then
    local res, err = singletons.dao.ctk2:find_all {jwt = ctk2.jwt}
    if not err and #res > 0 then
      ngx.log(ngx.CRIT, "########## DAOS.LUA ######## JWT IS IN THE DB")
      return false, "JWT is in the DB"
    elseif not err then
      return true
    end
  end
end

local SCHEMA = {
  ngx.log(ngx.CRIT, "########## DAOS.LUA ######## CHECK SCHEMA"),
  primary_key = {"id"},
  table = "ctk2",
  cache_key = { "jwt" },
  fields = {
    id = { type = "id", dao_insert_value = true },
    created_at = { type = "timestamp", immutable = true, dao_insert_value = true },
    jwt = { type = "string", required = false, unique = true, func = check_unique }
  },
}

return {ctk2 = SCHEMA}
