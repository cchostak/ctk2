local singletons = require "kong.singletons"
local BasePlugin = require "kong.plugins.base_plugin"
local responses = require "kong.tools.responses"
local constants = require "kong.constants"
local utils = require "kong.tools.utils"
local public_tools = require "kong.tools.public"
local cjson = require "cjson"
local url = require "socket.url"
local http = require "socket.http"
local multipart = require "multipart"
local ipairs = ipairs

local Ctk2Handler = BasePlugin:extend()
Ctk2Handler.PRIORITY = 3505
Ctk2Handler.VERSION = "0.1.0"
ngx.log(ngx.CRIT, "########## CTK2 ######## EXTENDED BASE PLUGIN")

function Ctk2Handler:new()
        Ctk2Handler.super.new(self, "ctk2")
        ngx.log(ngx.CRIT, "########## CTK2 ######## INSTACIATED ITSELF")
end

-- APÓS A FUNÇÃO SER CHAMADA PELO BLOCO ACCESS, TRARÁ O TOKEN RETIRADO DO CABEÇALHO E O CONF DO SCHEMA.LUA
-- VERIFICARÁ O TOKEN JUNTO AO SERVIÇO UPSTREAM E DIRÁ SE O TOKEN TEM STATUS 200 OU NÃO
-- RETORNA O STATUSCODE OU ERRO
function checkJWT(token, conf)
        ngx.log(ngx.CRIT, "########## HANDLER.LUA ######## RUNNING checkJWT FUNCTION token")
        ngx.log(ngx.CRIT, token)
        ngx.log(ngx.CRIT, "########## HANDLER.LUA ######## RUNNING checkJWT FUNCTION url config")
        ngx.log(ngx.CRIT, tostring(conf.url))

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
        ngx.log(ngx.CRIT, "########## HANDLER.LUA ######## STATUS CODE")
        ngx.log(ngx.CRIT, statusCode)
        return statusCode
        end
end

function updateCache(token, conf)
        ngx.log(ngx.CRIT, "########## HANDLER.LUA ######## UPDATE CACHE FUNCTION")
        local cache = singletons.cache
        local dao = singletons.dao
        local credential_cache_key = dao.ctk2:cache_key(token)
        ngx.log(ngx.CRIT, credential_cache_key)
        return
end

-- LOAD THE JWT IF IT EXIST IN DATABASE
-- RETURN OCCURRENCE OR NIL
function loadJWT(token, conf)
        ngx.log(ngx.CRIT, "########## HANDLER.LUA ######## LOADJWT FUNCTION")
        ngx.log(ngx.CRIT, token)
        jwt = token
        local creds, err = singletons.cache:get(credential_cache_key)
        if creds == ("ctk2:" .. token) then
                ngx.log(ngx.CRIT, "########## HANDLER.LUA ######## TOKEN EXISTE NO CACHE")
                ngx.log(ngx.CRIT, creds)
                return true
        else
                return nil, err
        end
        -- local creds, err = singletons.dao.ctk2:find_all {
        --         jwt = jwt
        --       }
        --       if not creds then
        --         return nil, err
        --       end
        --       ngx.log(ngx.CRIT, "########## HANDLER.LUA ######## AFTER SINGLETONS")
        --       ngx.log(ngx.CRIT, creds[1])
        --       return creds[1] 
end

function Ctk2Handler:access(conf)
        Ctk2Handler.super.access(self)
        ngx.log(ngx.CRIT, "########## HANDLER.LUA ######## RUNNING ACCESS BLOCK")
        -- GET JWT FROM HEADER AND ASSIGN TO TOKEN VARIABLE
        token = ngx.req.get_headers()["Authorization"]
        ngx.log(ngx.CRIT, "########## HANDLER.LUA ######## TOKEN RETRIEVED")
        ngx.log(ngx.CRIT, token)

        local chave, erro = loadJWT(token, conf)
        credenciais = chave
        ngx.log(ngx.CRIT, "########## HANDLER.LUA ######## CREDENCIAIS")
        ngx.log(ngx.CRIT, credenciais)
        if credenciais ~= nil then
                ngx.log(ngx.CRIT, "### AS CREDENCIAIS EXISTEM NO DB ###")
                ngx.log(ngx.CRIT, credenciais)
        else
        -- THE STATUS CODE RETRIEVED FROM THE SERVICE
                local ok, err = checkJWT(token, conf)
                ngx.log(ngx.CRIT, "########## HANDLER.LUA ######## OK")
                ngx.log(ngx.CRIT, ok)
                ngx.log(ngx.CRIT, "########## HANDLER.LUA ######## ERR")
                ngx.log(ngx.CRIT, err)
                statusCode = ok
                if statusCode == 200 then
                        ngx.log(ngx.CRIT, "### STATUS 200 OK ###")
                        ngx.log(ngx.CRIT, uriRetrieved)
                        local databaseUpdate = updateCache(token, conf)
                else
                        ngx.log(ngx.CRIT, "### NÃO AUTORIZADO ###")
                        return responses.send_HTTP_FORBIDDEN("You cannot consume this service")
                end
        end
end

return Ctk2Handler