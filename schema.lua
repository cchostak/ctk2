local utils = require "kong.tools.utils"


return {
  no_consumer = true,
  strip_path = true,
  fields = {
    key_names = {type = "array", required = true, default = {"ctk"}},
    url = {type = "url", default = "", required = true}
  },
}