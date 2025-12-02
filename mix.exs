defmodule Sudoku.MixProject do
  use Mix.Project

  def project do
    [
      app: :sudoku,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  defp aliases do
    [
      example_algorithm_x: ["run scripts/example_algorithm_x.exs"],
      example_backtracking: ["run scripts/example_backtracking.exs"],
      test_history: ["run scripts/test_history.exs"],
      test_visualizer_algorithm_x: ["run scripts/test_visualizer_algorithm_x.exs"],
      test_visualizer: ["run scripts/test_visualizer.exs"],
      visualize_exact_cover_matrix: ["run scripts/visualize_exact_cover_matrix.exs"]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, "~> 1.4"},
      {:ex_doc, "~> 0.31", only: :dev, runtime: false}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
