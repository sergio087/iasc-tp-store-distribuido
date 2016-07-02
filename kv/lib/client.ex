defmodule Client do

    def init do 
        Application.get_env(:kv, :key)
    end
    def set(key, val) do
        HTTPotion.post "https://httpbin.org/post", [body: "hello=" <> URI.encode_www_form("w o r l d !!"),
        headers: ["User-Agent": "My App", "Content-Type": "application/x-www-form-urlencoded"]]
    end
    def get(key) do
        HTTPotion.get("httpbin.org/get", query: %{key: key})
    end

    def findGreater(minVal) do
        HTTPotion.get("httpbin.org/get", query: %{min: minVal})
    end
    def findSmaller(maxVal) do
        HTTPotion.get("httpbin.org/get", query: %{max: maxVal})
    end
end
