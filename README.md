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


4. consultas desde cliente1

	KVClient.Client.set :client, "clav1", "valor1"

	KVClient.Client.set :client, "clav2", "valor2"

	KVClient.Client.set :client, "clav3", "valor3"

	KVClient.Client.get :client, "clav1"

	KVClient.Client.findSmaller :client, "valor2"

	KVClient.Client.findGreater :client, "valor2"

	KVClient.Client.remove :client, "clav1"

	KVClient.Client.remove :client, "clav1"


