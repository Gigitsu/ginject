defmodule Ginject.MixProject do
  use Mix.Project

  def project do
    [
      app: :ginject,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps(),
      package: package(),
      description: "An elixir dependency injection library",
      source_url: "https://github.com/gigitsu/ginject",
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:hammox, "~> 0.7", optional: true},
      {:ex_doc, "~> 0.27", only: :dev, runtime: false},
      {:credo, "~> 1.7", only: [:dev], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev], runtime: false},

      # Test
      {:excoveralls, "~> 0.10", only: :test}
    ]
  end

  def package do
    [
      name: :ginject,
      description: "A lightweight, flexible dependency injection framework for Elixir",
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/Gigitsu/ginject"
      }
    ]
  end

  defp docs() do
    [
      main: "readme",
      name: "ginject",
      canonical: "http://hexdocs.pm/ginject",
      source_url: "https://github.com/gigitsu/ginject",
      extras: ["README.md", "LICENSE"],
      groups_for_modules: [
        Strategies: [
          Ginject.Strategy,
          Ginject.Strategy.BehaviourAsDefault,
          Ginject.Strategy.Mox
        ],
        Testing: [
          Ginject.Test
        ]
      ]
    ]
  end
end
