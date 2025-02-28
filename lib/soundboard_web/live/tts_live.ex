defmodule SoundboardWeb.SoundboardWeb.TTSLive do
  use SoundboardWeb, :live_view

  alias Soundboard.Elevenlabs

  def render(assigns) do
    ~H"""
    <div>
      <.simple_form for={@form} id="tts-form" phx-change="validate" phx-submit="save">
        <.input type="text" label="query" field={@form[:query]} />
        <.input
          field={@form[:voice_id]}
          label="Voice ID"
          options={@voice_options}
          type="select"
        />
        <:actions>
          <div class="flex">
            <.button>Submit</.button>
          </div>
        </:actions>
      </.simple_form>
      <ul class="mt-4">
        <%= for query <- @queries do %>
          <li class="mb-2">
            <a href={"/tts/download?query=#{URI.encode_www_form(query)}&voice_id=#{@voice_id}"} target="_blank">
              Download "{query}"
            </a>
          </li>
        <% end %>
      </ul>
    </div>
    """
  end

  defp fetch_voices() do
    {:ok, %{"voices" => voices}} = Elevenlabs.voices()
    voices
    |> Enum.map(fn %{"name" => name, "voice_id" => voice_id} -> {name, voice_id} end)
    |> Enum.into(%{})
  end

  def mount(_params, _session, socket) do
    query = "Hello, world!"
    voice_id = "U1Vk2oyatMdYs096Ety7"
    voice_options = fetch_voices()

    {:ok,
     socket
     |> assign(:form, to_form(%{"query" => query, "voice_id" => voice_id}))
     |> assign(:queries, [])
     |> assign(:voice_id, voice_id)
     |> assign(:voice_options, voice_options)}
  end

  def handle_event("validate", params, socket) do
    {:noreply, assign(socket, :form, to_form(params |> IO.inspect(label: "params")))}
  end

  def handle_event("save", %{"query" => query, "voice_id" => voice_id} = params, socket) do
    queries = [
      # Reverse the query
      String.reverse(query),
      query,
      query <> " " <> query,
      query <> " " <> query <> " " <> query,
      query <> " " <> query <> " " <> query <> " " <> query,
      query <> " " <> query <> " " <> query <> " " <> query <> " " <> query,
      query <> " " <> query <> " " <> query <> " " <> query <> " " <> query <> " " <> query,
    ]

    {:noreply, socket
     |> assign(:form, to_form(params))
     |> assign(:queries, queries)
     |> assign(:voice_id, voice_id)}
  end
end
