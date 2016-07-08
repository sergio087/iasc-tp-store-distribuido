# iasc-tp-store-distribuido

1. levantar datas
2. levantar server
3. consultas desde postman

3.a
POST /set HTTP/1.1
Host: localhost:4000
Content-Type: application/json
Cache-Control: no-cache
Postman-Token: 1b8ae6e3-e131-b0b6-2e71-fbf454aced44

{"key":"clave1", "value":"valor1"}

3.b
GET /get?key=clave1 HTTP/1.1
Host: localhost:4000
Cache-Control: no-cache
Postman-Token: f4cb021e-0f56-6463-65ba-98173586dedb

