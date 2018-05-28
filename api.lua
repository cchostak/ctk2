local crud = require "kong.api.crud_helpers"

ngx.log(ngx.CRIT, "########## API.LUA ######## RUNNING API.LUA")

return {
  ["/ctk2/"] = {
    ngx.log(ngx.CRIT, "########## API.LUA ######## DAO FACTORY")
    GET = function(self, dao_factory)
      crud.paginated_set(self, dao_factory.jwt)
    end
  },
  ["/ctk2/:credential_key_or_id"] = {
    ngx.log(ngx.CRIT, "########## API.LUA ######## JWT CREDENTIAL")
    before = function(self, dao_factory, helpers)
      local credentials, err = crud.find_by_id_or_field(
        ngx.log(ngx.CRIT, "########## API.LUA ######## BEFORE FUNCTION")
        ngx.log(ngx.CRIT, credentials)
        dao_factory.ctk2,
        {},
        ngx.unescape_uri(self.params.credential_key_or_id),
        "jwt"
      )

      if err then
        ngx.log(ngx.CRIT, "########## API.LUA ######## ERRO")
        ngx.log(ngx.CRIT, err)
        return helpers.yield_error(err)
      elseif next(credentials) == nil then
        return helpers.responses.send_HTTP_NOT_FOUND()
      end

      self.params.credential_key_or_id = nil
      self.params.username_or_id = credentials[1].jwt
      crud.find_consumer_by_username_or_id(self, dao_factory, helpers)
    end,

    GET = function(self, dao_factory,helpers)
      return helpers.responses.send_HTTP_OK(self.consumer)
    end
  }
}
