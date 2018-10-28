defmodule ElixirStuff.MixProject do
  use Mix.Project

  def project do
    [
      app: :elixir_stuff,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :alpha,
      deps: deps()
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [{:nostrum, git: "https://github.com/Kraigie/nostrum.git"}]
  end
end
