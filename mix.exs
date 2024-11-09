defmodule EliRepl.MixProject do
  use Mix.Project

  def project do
    [
      app: :eli,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: escript()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [{:ollama, "0.7.1"}]
  end

  defp escript do
    [main_module: EliRepl.CLI]
  end
end
