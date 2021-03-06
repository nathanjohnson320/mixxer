defmodule Mix.Tasks.Version do
  @moduledoc """
  Adds a package to your deps

  ## Usage

  $ mix version major

  ## Parameters

  patch   Bumps last part of semver
  minor   Bumps middle part of semver
  major   Bumps first part of semver

  """

  use Mix.Task

  require Logger

  @shortdoc "Updates version in mix.exs by given semver and adds git tag"
  def run(args) do
    {_params, [params], _invalid} =
      OptionParser.parse(args,
        strict: [major: :boolean, minor: :boolean, patch: :boolean]
      )

    with {:ok, mixfile} <-
           File.read!(file_path())
           |> Code.string_to_quoted(),
         {updated, new_version} <-
           Macro.prewalk(mixfile, "", fn
             {:version, current}, _acc ->
               current = Version.parse!(current)
               new = bump_version!(current, params)

               {{:version, new |> to_string()}, new}

             node, acc ->
               {node, acc}
           end),
         formatted <-
           updated
           |> Macro.to_string()
           |> Code.format_string!() do
      File.write!(file_path(), formatted)
      git_tag(new_version)
      Logger.info("Updated and tagged version #{new_version}")
    else
      nil ->
        Logger.error("usage: mix version --minor")

      e ->
        Logger.error(inspect(e))
    end
  end

  defp bump_version!(current, "major"),
    do: %{current | major: current.major + 1, minor: 0, patch: 0}

  defp bump_version!(current, "minor"), do: %{current | minor: current.minor + 1, patch: 0}
  defp bump_version!(current, "patch"), do: %{current | patch: current.patch + 1}

  defp bump_version!(_curent, _params) do
    Logger.error("usage: mix version --minor")
    raise "Invalid params"
  end

  defp git_tag(version) do
    version = "v#{version}"
    {_, 0} = System.cmd("git", ["add", "."])
    {_, 0} = System.cmd("git", ["commit", "-m", version])
    {_, 0} = System.cmd("git", ["tag", version])
  end

  defp file_path() do
    Path.expand("#{File.cwd!()}/mix.exs")
  end
end
