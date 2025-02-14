alias Soundboard.Elevenlabs

{:ok, voices} = Elevenlabs.voices()

voices
|> Jason.encode!(pretty: true)
|> IO.puts()
