defmodule Soundboard.Elevenlabs do
  @moduledoc ~S"""

  # Example cURL:

    curl -X POST "#{base_url()}/text-to-speech/JBFqnCBsd6RMkjVDRZzb?output_format=mp3_44100_128" \
        -H "xi-api-key: #{api_key()}" \
        -H "Content-Type: application/json" \
        -d '{
          "text": "The first move is what sets everything in motion.",
          "model_id": "eleven_multilingual_v2"
        }'

  """

  defp req() do
    Req.new(
      base_url: base_url(),
      headers: [{"xi-api-key", api_key()}]
    )
  end

  def models() do
    url = "/models"
    case Req.get(req(), url: url) do
      {:ok, %{status: 200, body: body}} ->
        {:ok, body}

      {:ok, %{status: status, body: body}} ->
        {:error, %{status: status, body: body}}
    end
  end

  def voices() do
    url = "/voices"
    case Req.get(req(), url: url) do
      {:ok, %{status: 200, body: body}} ->
        {:ok, body}

      {:ok, %{status: status, body: body}} ->
        {:error, %{status: status, body: body}}
    end
  end

  def tts(text, opts \\ []) do
    output_format = Keyword.get(opts, :output_format, "mp3_44100_128")
    model_id = Keyword.get(opts, :model_id, "eleven_flash_v2_5")
    voice_id = Keyword.get(opts, :voice_id, "U1Vk2oyatMdYs096Ety7")
    url = "/text-to-speech/#{voice_id}?output_format=#{output_format}" |> IO.inspect(label: "url")
    body = Jason.encode!(%{text: text, model_id: model_id})

    case Req.post(req(), url: url, body: body) do
      {:ok, %{status: 200, body: body}} ->
        {:ok, body}

      {:ok, %{status: status, body: body}} ->
        {:error, %{status: status, body: body}}
    end
  end

  def base_url do
    "https://api.elevenlabs.io/v1"
  end

  def api_key do
    Application.get_env(:soundboard, :elevenlabs_api_key)
  end
end
