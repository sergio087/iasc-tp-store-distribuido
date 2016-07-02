defmodule Client do

    def init do 
        Application.get_env(:kv, :key)
    end
    def set(key, val) do
        HTTPotion.post "http://localhost:4000/set", [body: "key=" <> URI.encode_www_form("clave") <> ", val=" <> URI.encode_www_form("valor"),
        headers: ["User-Agent": "My App", "Content-Type": "application/x-www-form-urlencoded"]]
        
    end
    def get(key) do
        HTTPotion.get("http://localhost:4000/get", query: %{key: key})
   end

    def findGreater(minVal) do
        HTTPotion.get("http://localhost:4000/find", query: %{min: minVal})
    end
    def findSmaller(maxVal) do
        HTTPotion.get("http://localhost:4000/find", query: %{max: maxVal})
    end
end
