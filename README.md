# iasc-tp-store-distribuido

1. levantar datas
	/iasc-tp-store-distribuido/kv_umbrella/apps/kv_data$ ./run.sh data1

	/iasc-tp-store-distribuido/kv_umbrella/apps/kv_data$ ./run.sh data2	


2. levantar server

	/iasc-tp-store-distribuido/kv_umbrella/apps/kv_server$ ./run.sh 1
	/iasc-tp-store-distribuido/kv_umbrella/apps/kv_server$ ./run.sh 2
	/iasc-tp-store-distribuido/kv_umbrella/apps/kv_server$ ./run.sh 3

3. levantar cliente1

	(si queres rpc) /iasc-tp-store-distribuido/kv_umbrella/apps/kv_client$ ./run.sh client1 rpc
	(si queres http) /iasc-tp-store-distribuido/kv_umbrella/apps/kv_client$ ./run.sh client1 http


        verificar configuracion desde la consola iex: Application.get_all_env :kv_client


4. consultas desde cliente1 rpc


	KVClient.Client.set :client, "clav1", "valor1"

	KVClient.Client.set :client, "clav2", "valor2"

	KVClient.Client.set :client, "clav3", "valor3"

	KVClient.Client.get :client, "clav1"

	KVClient.Client.findSmaller :client, "valor2"

	KVClient.Client.findGreater :client, "valor2"

	KVClient.Client.remove :client, "clav1"

	KVClient.Client.remove :client, "clav1"


4. consultas desde cliente http

	KVClient.Client.set_HTTP :client, "k1", "v1"
	KVClient.Client.set_HTTP :client, "k2", "v2"
	KVClient.Client.set_HTTP :client, "k3", "v3"
	KVClient.Client.set_HTTP :client, "k4", "v4"
	KVClient.Client.set_HTTP :client, "k0", "v0"
	KVClient.Client.get_HTTP :client, "k1"
	KVClient.Client.get_HTTP :client, "k2"
	KVClient.Client.get_HTTP :client, "k3"
	KVClient.Client.findSmaller_HTTP :client, "v2"
	KVClient.Client.findGreater_HTTP :client, "v2"


5. (interno) ver estado de los store

	GenServer.call :store, {:state}
