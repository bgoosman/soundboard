defmodule Soundboard.AppConfig do
  defp read do
    {:ok, yml} = YamlElixir.read_from_file("config.yml")
    yml
  end

  @doc """
  ```elixir
  get_in(["graphxr", "http://localhost:9000", "api_key"], "GRAPHXR_API_KEY", "default value")
  ```
  """
  def get(path, env_key, default \\ nil) do
    case read() |> get_in(path) do
      nil ->
        case System.get_env(env_key) do
          nil -> default
          value -> value
        end
      value -> value
    end
  end

  def get!(path, env_key, default \\ nil) do
    case get(path, env_key, default) do
      nil -> raise "Path not found: \"#{path |> Enum.join(".")}\". Env \"#{env_key}\" also not found"
      value -> value
    end
  end
end
