defmodule KinoLiveAudio.MixProject do
  use Mix.Project

  def project do
    [
      app: :kino_live_audio,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description:
        "A Kino designed to record a raw audio stream (no client-side encoding) and emit events.",
      source_url: "https://github.com/acalejos/kino_live_audio",
      package: package(),
      preferred_cli_env: [
        docs: :docs,
        "hex.publish": :docs
      ],
      docs: docs()
    ]
  end

  def application do
    []
  end

  defp package do
    [
      maintainers: ["Andres Alejos"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/acalejos/kino_live_audio"}
    ]
  end

  defp deps do
    [
      {:kino, "~> 0.12"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp docs do
    [
      main: "KinoLiveAudio",
      extras: [
        "notebooks/vad.livemd"
      ],
      groups_for_extras: [
        Notebooks: Path.wildcard("notebooks/*.livemd")
      ]
    ]
  end
end
