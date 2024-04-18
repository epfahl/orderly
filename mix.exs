defmodule Orderly.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :orderly,
      version: @version,
      elixir: "~> 1.16",
      description: description(),
      package: package(),
      docs: docs(),
      source_url: "https://github.com/epfahl/orderly",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.32.1", only: :dev, runtime: false}
    ]
  end

  defp description() do
    "Elixir implementations of a sorted map and a sorted set based on Erlang's gb_trees and gb_sets."
  end

  defp package() do
    [
      files: ["lib", "mix.exs", "README.md", "LICENSE.md"],
      maintainers: ["Eric Pfahl"],
      licenses: ["MIT"],
      links: %{
        GitHub: "https://github.com/epfahl/orderly"
      }
    ]
  end

  defp docs() do
    [
      main: "Orderly",
      extras: ["README.md"]
    ]
  end
end
