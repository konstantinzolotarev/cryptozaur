defmodule Cryptozaur.MixProject do
  use Mix.Project

  def project do
    [
      app: :cryptozaur,
      version: "1.0.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    extra_applications =
      [
        :logger
      ] ++ if Mix.env() == "dev", do: [:remix], else: []

    [
      extra_applications: extra_applications
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:optimus, "~> 0.1.0"},
      {:remix, "~> 0.0.2", only: :dev},
      {:oauther, "~> 1.1"},
      {:poison, "~> 3.1"},
      {:socket, "~> 0.3"},
      {:ok, "~> 1.9"},
      {:math, "~> 0.3.0"},
      {:poolboy, ">= 0.0.0"},
      {:httpoison, "~> 0.12"},
      {:cowboy, "~> 1.1.2"},
      {:plug, "~> 1.3.0"},
      {:gen_retry, "~> 1.0.1"},
      {:credo, "~> 0.5", only: [:test, :dev]},
      {:ex_doc, ">= 0.0.0", only: [:dev]},
      {:ex_rated, "~> 1.3.1"},
      {:exconstructor, ">= 1.1.0"},
      {:deep_merge, "~> 0.1.0"},
      {:exvcr, "~> 0.8", only: :test},
      {:mock, "~> 0.2.0", only: :test},
      {:timex, "~> 3.0"},
      {:ecto, "~> 2.1"},
      {:apex, "~> 1.1.0"},
      {:table_rex, "~> 0.10"},
      {:csv, "~> 2.0.0"},
      {:postgrex, ">= 0.12.2"},
      {:signaturex, "~> 1.3.0"},
      {:mix_test_watch, "~> 0.6", only: :dev, runtime: false},
      {:pre_commit, "~> 0.2", only: :dev}
    ]
  end

  defp aliases do
    [
      strat: ["start"],
      start: ["run --no-halt"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"],
      prepare: ["format", "clean", "compile"]
    ]
  end
end