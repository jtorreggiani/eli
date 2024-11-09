defmodule EliRepl do
  @moduledoc """
  A simple REPL (Read-Eval-Print Loop) implementation with Ollama integration.
  """

  @doc """
  Starts the REPL.
  """
  def start do
    IO.puts("Welcome to EliRepl with Ollama integration!")
    IO.puts("Type 'exit' to quit.")
    client = Ollama.init()
    initial_messages = [
      %{role: "system", content: "You are a helpful assistant. When asked about the current time or any time-related questions, use the get_current_time tool to provide accurate information."}
    ]
    loop(client, initial_messages)
  end

  def hello do
    :world
  end

  defp loop(client, messages) do
    input = IO.gets("> ") |> String.trim()

    case input do
      "exit" ->
        IO.puts("Goodbye!")
      ":" <> code ->
        try do
          {result, _} = Code.eval_string(code)
          IO.inspect(result, label: "Result")
        rescue
          e ->
            IO.puts("Error: #{inspect(e)}")
        end
        loop(client, messages)
      _ ->
        updated_messages = messages ++ [%{role: "user", content: input}]
        case Ollama.chat(client, [
          model: "mistral-nemo:latest",
          messages: updated_messages,
          tools: [time_tool()]
        ]) do
          {:ok, %{"message" => %{"content" => content, "tool_calls" => tool_calls}}} ->
            handle_tool_calls(tool_calls, client, updated_messages, content)
          {:ok, %{"message" => %{"content" => content}}} ->
            IO.puts("Ollama: #{content}")
            loop(client, updated_messages ++ [%{role: "assistant", content: content}])
          {:error, error} ->
            IO.puts("Error: #{inspect(error)}")
            loop(client, updated_messages)
        end
    end
  end

  defp time_tool do
    %{
      type: "function",
      function: %{
        name: "get_current_time",
        description: "Get the current time",
        parameters: %{
          type: "object",
          properties: %{},
          required: []
        }
      }
    }
  end

  defp handle_tool_calls(nil, client, messages, content) do
    IO.puts("Ollama: #{content}")
    loop(client, messages ++ [%{role: "assistant", content: content}])
  end

  defp handle_tool_calls(tool_calls, client, messages, _content) do
    tool_results = Enum.map(tool_calls, &execute_tool_call/1)
    updated_messages = messages ++ tool_results

    case Ollama.chat(client, [
      model: "mistral-nemo:latest",
      messages: updated_messages,
      tools: [time_tool()]
    ]) do
      {:ok, %{"message" => %{"content" => content}}} ->
        IO.puts("Ollama: #{content}")
        loop(client, updated_messages ++ [%{role: "assistant", content: content}])
      {:error, error} ->
        IO.puts("Error: #{inspect(error)}")
        loop(client, updated_messages)
    end
  end

  defp execute_tool_call(%{"function" => %{"name" => "get_current_time"}}) do
    utc_now = Time.utc_now()
    est_time = utc_now
               |> Time.add(-5 * 3600) # 5 hours behind UTC
               |> Time.to_string()
    %{role: "tool", content: "Current time in EST: #{est_time}"}
  end
end
