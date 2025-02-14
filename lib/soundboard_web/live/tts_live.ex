defmodule SoundboardWeb.SoundboardWeb.TTSLive do
  use SoundboardWeb, :live_view

  def render(assigns) do
    query = assigns.form.params["query"]
    IO.inspect(query, label: "query")
    ~H"""
    <div>
      <.form for={@form} phx-change="validate" phx-submit="save">
        <.input type="text" name="query" field={@form[:query]} />
      </.form>
      <a href={"/tts/download?text=#{query}"}>Download</a>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    query = "Hello, world!"

    {:ok, assign(socket, :form, to_form(%{"query" => query}))}
  end

  def handle_event("validate", params, socket) do
    {:noreply, assign(socket, :form, to_form(params))}
  end
end
