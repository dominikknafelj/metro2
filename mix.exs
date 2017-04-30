defmodule Metro2.Mixfile do
  use Mix.Project

  def project do
    [app: :metro_2,
     version: "0.1.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     preferred_cli_env: [espec: :test],
     package: package(),
     description: description()

   ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [applications: [:timex], extra_applications: [:logger]]
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
    [{:timex, "~> 3.0"},
    {:espec, "~> 1.3.0", only: :test},
    {:credo, "~> 0.7", only: [:dev, :test]},
    {:ex_doc, "~> 0.14", only: :dev, runtime: false}]
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
end
