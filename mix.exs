defmodule Bamboo.FallbackAdapter.MixProject do
  use Mix.Project

  def project do
    [
      app: :bamboo_fallback,
      version: "0.3.1",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp package do
    [
      licenses: ["Apache 2"],
      links: %{
        GitHub: "https://github.com/fuelen/bamboo_fallback"
      }
    ]
  end

  defp description do
    """
    Allows you to use multiple adapters for the Bamboo email app to increase the guarantee of emails delivering.
    """
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:bamboo, "~> 2.1"},
      {:mox, "~> 1.0", only: :test},
      {:ex_doc, "~> 0.24", only: :dev}
    ]
  end
end
