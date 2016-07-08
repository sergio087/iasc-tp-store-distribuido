# iasc-tp-store-distribuido

1. levantar datas
	/iasc-tp-store-distribuido/kv_umbrella/apps/kv_data$ ./run.sh data1
	/iasc-tp-store-distribuido/kv_umbrella/apps/kv_data$ ./run.sh data2	
2. levantar server
	/iasc-tp-store-distribuido/kv_umbrella/apps/kv_server$ ./run.sh
3. levantar cliente1
	/iasc-tp-store-distribuido/kv_umbrella/apps/kv_client$ ./run.sh client1
4. consultas desde cliente1
	{:ok, pid} = KVClient.Client.start_link
	KVClient.Client.set pid, "clave1", "valor1"
	KVClient.Client.get pid, "clave1"

