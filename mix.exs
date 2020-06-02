defmodule(Mixxer.MixProject) do
  use(Mix.Project)

  def(project()) do
    [
      app: :mixxer,
      version: "1.0.1",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package()
    ]
  end

  def(application()) do
    [extra_applications: [:logger]]
  end

  defp(deps()) do
    [{:ex_doc, "~> 0.22.1", [only: :dev, runtime: false]}, {:hex_core, "~> 0.6.9"}]
  end

  defp(package()) do
    [licenses: ["MIT"], links: %{"GitHub" => "https://github.com/nathanjohnson320/mixxer"}]
  end
end