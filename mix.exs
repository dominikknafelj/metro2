defmodule Metro2.Mixfile do
  use Mix.Project

  def project do
    [
      app: :metro_2,
      version: "0.2.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      description: description(),
      docs: docs()
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:timex, "~> 3.7"},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.31", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      name: :metro2,
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Dominik Knafelj"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/dominikknafelj/metro2"}
    ]
  end

  defp description do
    """
    This library follows the METRO 2 ® data reporting format, which is a data reporting format for consumer credit account data furnishers.
    """
  end

  defp docs do
    [
      main: "Metro2",
      extras: ["README.md"]
    ]
  end
end
