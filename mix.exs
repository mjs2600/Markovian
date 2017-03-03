defmodule Markovian.Mixfile do
  use Mix.Project

  def project do
    [
      app: :markovian,
      version: "0.1.1",
      elixir: "~> 1.4",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps(),
      package: package(),
      dialyzer: [
        plt_add_deps: :transitive,
        flags: ["-Wunmatched_returns", "-Werror_handling", "-Wrace_conditions", "-Wunderspecs"],
      ],
      description: """
      A Q-learner for the BEAM.
      """,
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp package do
    [
      maintainers: ["Michael Simpson"],
      licenses: ["MPL-2.0"],
      links: %{github: "https://github.com/mjs2600/Markovian"},
     ]
  end

  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false},
      {:credo, "~> 0.5", only: [:dev, :test]},
    ]
  end
end
