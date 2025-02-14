defmodule Soundboard.ElevenlabsTTSTest do
  use ExUnit.Case

  alias Soundboard.Elevenlabs

  test "tts/2" do
    assert {:ok, body} =
             Elevenlabs.tts("Hello, world!",
               model_id: "eleven_flash_v2_5",
               voice_id: "U1Vk2oyatMdYs096Ety7"
             )

    assert is_binary(body)
    IO.inspect(body)
  end
end
