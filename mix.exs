defmodule Members.Mixfile do
  use Mix.Project

  def project do
    [
      app: :members,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Members.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto, "~> 2.0"},
      {:mariaex, ">= 0.8.2"},
      {:timex, "~> 3.0"},
      {:timex_ecto, "~> 3.0"},
    ]
  end
end
