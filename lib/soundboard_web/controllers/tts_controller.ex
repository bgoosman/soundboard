defmodule SoundboardWeb.TTSController do
  use SoundboardWeb, :controller

  alias Soundboard.Elevenlabs

  def download(conn, params) do
    query = Map.get(params, "query", "Hello, world!") |> IO.inspect(label: "query")
    voice_id = Map.get(params, "voice_id", "U1Vk2oyatMdYs096Ety7")

    {:ok, bytes} = Elevenlabs.tts(query, voice_id: voice_id)

    conn
    |> send_download({:binary, bytes}, filename: "tts.mp3")
  end
end
