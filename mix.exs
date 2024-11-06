defmodule Ueberauth.Headhunter.Mixfile do
  use Mix.Project

  @source_url "https://github.com/glibin/ueberauth_headhunter"
  @version "0.0.1"

  def project do
    [
      app: :ueberauth_headhunter,
      version: @version,
      name: "Überauth Headhunter",
      elixir: "~> 1.3",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      package: package(),
      deps: deps(),
      docs: docs()
    ]
  end

  def application do
    [
      applications: [:logger, :oauth2, :ueberauth]
    ]
  end

  defp deps do
    [
      {:ueberauth, "~> 0.10"},
      {:oauth2, "~> 2.0"},
      {:jason, "~> 1.4"},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false},
      {:mock, "~> 0.3.0", only: :test}
    ]
  end

  defp docs do
    [
      extras: [
        "CHANGELOG.md",
        "CONTRIBUTING.md",
        {:LICENSE, [title: "License"]},
        "README.md"
      ],
      main: "readme",
      source_url: @source_url,
      source_ref: "v#{@version}",
      homepage_url: @source_url,
      formatters: ["html"]
    ]
  end

  defp package do
    [
      description: "An Überauth strategy for Headhunter authentication.",
      files: ["lib", "mix.exs", "README.md", "CHANGELOG.md", "CONTRIBUTING.md", "LICENSE"],
      maintainers: ["Vitaly Glibin"],
      licenses: ["MIT"],
      links: %{
        Changelog: "https://hexdocs.pm/ueberauth_headhunter/changelog.html",
        GitHub: @source_url
      }
    ]
  end
end
