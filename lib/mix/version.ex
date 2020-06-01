defmodule Mix.Tasks.Version do
  @moduledoc """
  Adds a package to your deps

  ## Usage

  $ mix version --major

  ## Parameters

  --patch   Bumps last part of semver
  --minor   Bumps middle part of semver
  --major   Bumps first part of semver

  """

  use Mix.Task

  require Logger

  @file_path Path.expand("./mix.exs")

  @shortdoc "Updates version in mix.exs by given semver and adds git tag"
  def run(args) do
    {params, _unmatched, _invalid} =
      OptionParser.parse(args,
        strict: [major: :boolean, minor: :boolean, patch: :boolean]
      )

    with {:ok, mixfile} <-
           File.read!(@file_path)
           |> Code.string_to_quoted(),
         updated <-
           Macro.prewalk(mixfile, fn
             {:version, current} ->
               current = Version.parse!(current)
               new = bump_version!(current, params)
               git_tag(new)
               {:version, new |> to_string()}

             node ->
               node
           end),
         formatted <-
           updated
           |> Macro.to_string()
           |> Code.format_string!() do
      File.write!(@file_path, formatted)
    else
      nil ->
        Logger.error("usage: mix version --minor")

      e ->
        Logger.error(inspect(e))
    end
  end

  defp bump_version!(current, major: true), do: %{current | major: current.major + 1}
  defp bump_version!(current, minor: true), do: %{current | minor: current.minor + 1}
  defp bump_version!(current, patch: true), do: %{current | patch: current.patch + 1}

  defp bump_version!(_curent, _params) do
    Logger.error("usage: mix version --minor")
    raise "Invalid params"
  end

  defp git_tag(version) do
    version = "v#{version}"
    System.cmd("git", ["add", "-u"])
    System.cmd("git", ["commit", "-m", version])
    System.cmd("git", ["tag", version])
  end
end
