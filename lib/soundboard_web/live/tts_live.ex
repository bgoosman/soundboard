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
          <div class="flex gap-2">
            <.button name="action" value="remix">Remix</.button>
            <.button name="action" value="gandalf">Gandalf</.button>
            <.button name="action" value="gollum">Gollum</.button>
            <.button name="action" value="bowwow">Bow-wow</.button>
            <.button name="action" value="demonic">Demonic</.button>
            <.button name="action" value="newscaster">BBC Newscaster</.button>
            <.loading_spinner class="hidden phx-submit-loading:inline-block ml-4 mb-5" />
          </div>
        </:actions>
      </.simple_form>
      <ul class="mt-4">
        <%= for query <- @queries do %>
          <li class="mb-2">
            <a href={"/tts/download?query=#{URI.encode_www_form(query)}&voice_id=#{@voice_id}"} target="_blank">
              {query}
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

  def handle_event("save", %{"action" => "remix", "query" => query, "voice_id" => voice_id} = params, socket) do
    queries = [
      # Reverse the query
      String.reverse(query),
      query,
      query <> " " <> query,
      query <> " " <> query <> " " <> query,
    ]

    {:noreply, socket
     |> assign(:form, to_form(params))
     |> assign(:queries, queries)
     |> assign(:voice_id, voice_id)}
  end

  def handle_event("save", %{"action" => "gandalf", "query" => query, "voice_id" => voice_id} = params, socket) do
    queries = [
      LiteLLM.ask!(query, system: "Respond as if you were Gandalf the Grey in one sentence"),
    ]

    {:noreply, socket
     |> assign(:form, to_form(params))
     |> assign(:queries, queries)
     |> assign(:voice_id, voice_id)}
  end

  def handle_event("save", %{"action" => "gollum", "query" => query, "voice_id" => voice_id} = params, socket) do
    queries = [
      LiteLLM.ask!(query, system: "Respond as if you were Gollum from Lord of the Rings. Use his characteristic speech patterns, including 'precious', 'my precious', 'we hates it', etc. One sentence maximum.")
    ]

    {:noreply, socket
     |> assign(:form, to_form(params))
     |> assign(:queries, queries)
     |> assign(:voice_id, voice_id)}
  end

  def handle_event("save", %{"action" => "bowwow", "query" => query, "voice_id" => voice_id} = params, socket) do
    queries = [
      LiteLLM.ask!(query, system: "Respond in random letters resembling bow-wow dog sounds. Make it chaotic, incoherent, and inscrutable. Use lots of 'woof', 'arf', 'ruff', etc. Two sentence maximum.")
    ]

    {:noreply, socket
     |> assign(:form, to_form(params))
     |> assign(:queries, queries)
     |> assign(:voice_id, voice_id)}
  end

  def handle_event("save", %{"action" => "demonic", "query" => query, "voice_id" => voice_id} = params, socket) do
    queries = [
      LiteLLM.ask!(query, system: "Respond in a demonic, evil tone. Make it sound like an infernal prayer or dark incantation. Use ominous and threatening language. One sentence maximum.")
    ]

    {:noreply, socket
     |> assign(:form, to_form(params))
     |> assign(:queries, queries)
     |> assign(:voice_id, voice_id)}
  end

  def handle_event("save", %{"action" => "newscaster", "query" => query, "voice_id" => voice_id} = params, socket) do
    queries = [
      LiteLLM.ask!(query, system: "Respond in the style of a formal BBC newscaster from the 1980s. Use proper British English, formal tone, and characteristic news reporting phrases. Make it a news report. One sentence maximum.")
    ]

    {:noreply, socket
     |> assign(:form, to_form(params))
     |> assign(:queries, queries)
     |> assign(:voice_id, voice_id)}
  end
end
