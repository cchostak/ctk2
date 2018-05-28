local singletons = require "kong.singletons"
local BasePlugin = require "kong.plugins.base_plugin"
local responses = require "kong.tools.responses"
local constants = require "kong.constants"
local utils = require "kong.tools.utils"
local cjson = require "cjson"
local url = require "socket.url"
local http = require "socket.http"
local access = require "kong.plugins.ctk2.access"
local ipairs = ipairs

local Ctk2Handler = BasePlugin:extend()
Ctk2Handler.PRIORITY = 3505
Ctk2Handler.VERSION = "0.1.0"
ngx.log(ngx.CRIT, "########## CTK2 ######## EXTENDED BASE PLUGIN")

function Ctk2Handler:new()
  Ctk2Handler.super.new(self, "ctk2")
  ngx.log(ngx.CRIT, "########## CTK2 ######## INSTACIATED ITSELF")
end

function checkJWT(token)
        ngx.log(ngx.CRIT, "########## CTK2 ######## RUNNING checkJWT FUNCTION")
        ngx.log(ngx.CRIT, token)

        uriRetrieved = ngx.var.uri
        host = ngx.var.host
        -- CHECK WHETER THE JWT EXISTS OR NOT
        if token == nil then
                ngx.log(ngx.CRIT, "--- FORBIDDEN ---")
                ngx.log(ngx.CRIT, token)
                return responses.send_HTTP_FORBIDDEN("You cannot consume this service")
        else
                ngx.log(ngx.CRIT, "--- TOKEN ---")
                ngx.log(ngx.CRIT, token)
                -- SET THE URL THAT WILL BE USED TO VALIDADE THE JWT
                -- CONF.URL RECEIVES THE URL USED UPON INSTALLATION OF THE PLUGIN
                ura = conf.url .. token
                -- THE HTTP REQUEST THAT TEST IF JWT IS VALID OR NOT
                local data = ""

                local function collect(chunk)
                        if chunk ~= nil then
                        data = data .. chunk
                        end
                return true
                end

                local ok, statusCode, headers, statusText = http.request {
                        method = "POST",
                        url = ura,
                        sink = collect
                }
        end
        return statusCode
end

function Ctk2Handler:access(conf)
 Ctk2Handler.super.access(self)
 ngx.log(ngx.CRIT, "########## CTK2 ######## RUNNING ACCESS BLOCK")
 -- GET JWT FROM HEADER AND ASSIGN TO TOKEN VARIABLE
 token = ngx.req.get_headers()["Authorization"]
 ngx.log(ngx.CRIT, "########## CTK2 ######## TOKEN RETRIEVED")
 ngx.log(ngx.CRIT, token)


 -- THE STATUS CODE RETRIEVED FROM THE SERVICE
 local ok, err = checkJWT(token)
 statusCode = ok
 if statusCode == 200 then
        ngx.log(ngx.CRIT, "### STATUS 200 OK ###")
        ngx.log(ngx.CRIT, uriRetrieved)
 else
        ngx.log(ngx.CRIT, "### NÃO AUTORIZADO ###")
        return responses.send_HTTP_FORBIDDEN("You cannot consume this service")
 end
end

return Ctk2Handler