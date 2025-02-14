defmodule SoundboardWeb.TTSController do
  use SoundboardWeb, :controller

  alias Soundboard.Elevenlabs

  def download(conn, params) do
    text = Map.get(params, "text", "Hello, world!")
    options = params |> Map.delete("text") |> Enum.into([])

    {:ok, bytes} = Elevenlabs.tts(text, options)

    conn
    |> send_download({:binary, bytes}, filename: "tts.mp3")
  end
end
