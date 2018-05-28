# Instalação do plugin

Assumindo que Kong já está funcionando

cd /usr/local/share/lua/5.1/kong/plugins/

git clone https://github.com/cchostak/ctk.git

kong restart

# 1. Criar serviço kong
curl -i -X POST http://localhost:8001/services/ \
    -d 'name={NOME DO SERVIÇO SEM CURLY BRACES}' \
    -d 'url={URL DE DESTINO SEM CURLY BRACES}'

# 2. Criar rota kong

curl -i -X POST http://localhost:8001/routes/ \
    -d 'hosts[]=localhost' \
    -d 'paths[]={URI DO LOCALHOST, SEM CURLY BRACES}' \
    -d 'service.id={ID DO SERVIÇO GERADO ANTERIORMENTE}'

# 3. Instalar plugin

curl -X POST http://localhost:8001/services/{NOME DO SERVIÇO}/plugins \
    --data "name=ctk" \
	--data "config.url={URL QUE SERÁ USADA PARA VALIDAÇÃO DO JWT}"

# EXEMPLO

1. Criar serviço kong

curl -i -X POST http://localhost:8001/services/ \
    -d 'name=usuarios' \
    -d 'url=http://chrissychostak.com/usuarios' 

2. Criar rota kong

curl -i -X POST http://localhost:8001/routes/ \
    -d 'hosts[]=localhost' \
    -d 'paths[]=/usuarios' \
    -d 'service.id=75c14873-ce5a-45e9-8be9-9d02671cb440'
	
3. Instalar plugin

curl -X POST http://localhost:8001/services/usuarios/plugins \
    --data "name=ctk" \
	--data "config.url=http://jwt.com/access"