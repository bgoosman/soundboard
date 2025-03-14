defmodule LiteLLM do
  alias Soundboard.AppConfig

  def chat(options) do
    base_url = get_base_url()
    api_key = get_api_key()

    Req.post(
      base_url <> "/chat/completions",
      json: options,
      headers: %{
        "Authorization" => "Bearer #{api_key}",
        "Content-Type" => "application/json"
      },
      retry: false,
      receive_timeout: 60_000 * 10,
      pool_timeout: 60_000 * 10,
      connect_options: [timeout: 60_000 * 10]
    )
  end

  def ask!(query, opts \\ []) do
    case ask(query, opts) do
      {:ok, output} -> output
      {:error, error} -> raise error
    end
  end

  def ask(_, opts \\ [])

  def ask(query, opts) when is_binary(query) do
    system_message_content = Keyword.get(opts, :system, nil)
    model = Keyword.get(opts, :model, "gpt-4o-mini")
    max_tokens = Keyword.get(opts, :max_tokens, 4096)
    temperature = Keyword.get(opts, :temperature, 0.7)

    messages =
      if system_message_content do
        [
          %{
            role: "system",
            content: system_message_content
          },
          %{role: "user", content: query}
        ]
      else
        [%{role: "user", content: query}]
      end

    case LiteLLM.chat(%{
           "model" => model,
           "temperature" => temperature,
           "max_tokens" => max_tokens,
           "messages" => messages
         }) do
      {:ok, %{body: %{"choices" => [%{"finish_reason" => "content_filter"}]}}} ->
        {:error, :content_filter}

      {:ok,
       %{
         body: %{
           "choices" => [%{"finish_reason" => "length", "message" => %{"content" => output}}]
         }
       }} ->
        IO.inspect(output, label: "LiteLLM Content (length)")
        {:partial, output}

      {:ok,
       %{
         body: %{
           "choices" => [%{"finish_reason" => "stop", "message" => %{"content" => output}}]
         }
       }} ->
        IO.inspect(output, label: "LiteLLM Content (stop)")
        {:ok, output}

      {:ok, %Req.Response{status: 400, body: %{"error" => %{"message" => message}} = error}} ->
        IO.inspect(message, label: "LiteLLM Error")
        {:error, error}

      {:error,
       %{
         "error" => %{
           "message" => message
         }
       } = error} ->
        cond do
          String.contains?(message, "ContentPolicyViolationError") ->
            {:error, :content_policy_violation}

          true ->
            {:error, error}
        end
    end
  end

  def ask(messages, opts) when is_list(messages) do
    model = Keyword.get(opts, :model, "gpt-4o-mini")

    case LiteLLM.chat(%{
           "model" => model,
           "messages" => messages
         }) do
      {:ok, %{body: %{"choices" => [%{"message" => %{"content" => content}}]}}} ->
        content

      {:error, error} ->
        IO.inspect(error)
        {:error, error}
    end
  end

  def get_base_url do
    AppConfig.get!(["openai", "base_url"], "OPENAI_BASE_URL")
  end

  def get_api_key do
    AppConfig.get!(["openai", "api_key"], "OPENAI_API_KEY")
  end
end
