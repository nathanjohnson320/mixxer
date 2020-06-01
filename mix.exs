defmodule(Mixxer.MixProject) do
  use(Mix.Project)

  def(project) do
    [
      app: :mixxer,
      version: "0.2.2",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def(application) do
    [extra_applications: [:logger]]
  end

  defp(deps) do
    [hex_core: "~> 0.6.9"]
  end
end