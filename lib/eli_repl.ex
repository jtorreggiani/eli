defmodule EliRepl do
  @moduledoc """
  A simple REPL (Read-Eval-Print Loop) implementation.
  """

  @doc """
  Starts the REPL.
  """
  def start do
    IO.puts("Welcome to EliRepl!")
    IO.puts("Type 'exit' to quit.")
    loop()
  end

  def hello do
    :world
  end

  defp loop do
    input = IO.gets("simple_repl> ") |> String.trim()

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
        loop()
      _ ->
        IO.puts(input)
        loop()
    end
  end
end
