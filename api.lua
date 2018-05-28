local crud = require "kong.api.crud_helpers"

return {
  ["/:jwt"] = {
    GET = function(self, dao_factory)
      crud.paginated_set(self, dao_factory.jwt)
    end
  }