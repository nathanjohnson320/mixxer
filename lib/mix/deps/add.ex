defmodule Mix.Tasks.Deps.Add do
  @moduledoc """
  Adds a package to your deps

  ## Usage

  $ mix deps.add --package ini

  ## Parameters

  --package   The package to lookup and add

  --version   A specific version to add, will error if it does not exist in hex.

  """

  use Mix.Task

  require Logger

  @config :hex_core.default_config()
  @file_path Path.expand("./mix.exs")

  @shortdoc "adds a dependency"
  def run(args) do
    {params, _unmatched, _invalid} =
      OptionParser.parse(args, strict: [version: :string, package: :string])

    with package when not is_nil(package) <- params[:package],
         {:ok, version} <- get_version(params),
         {:ok, mixfile} <-
           File.read!(@file_path)
           |> Code.string_to_quoted(),
         {updated, _} <-
           Macro.prewalk(mixfile, false, fn
             {:deps, _, nil} = node, false ->
               {node, true}

             {:do, deps}, true ->
               {{:do, [{String.to_atom(package), version} | deps]}, false}

             node, acc ->
               {node, acc}
           end),
         formatted <-
           updated
           |> Macro.to_string()
           |> Code.format_string!() do
      Logger.info("Added #{inspect({String.to_atom(package), version})}")
      File.write!(@file_path, formatted)
    else
      nil ->
        Logger.error("usage: mix deps.add --package ini")

      {:error, :no_version, msg} ->
        Logger.error(msg)

      e ->
        Logger.error(inspect(e))
    end
  end

  defp get_version(package: package, version: search_version) do
    {:ok, {200, _headers, %{"releases" => releases}}} = :hex_api_package.get(@config, package)
    version = Enum.find(releases, &(Map.get(&1, "version") == search_version))

    if is_nil(version) do
      {:error, :no_version, "#{package} version #{version} not found"}
    else
      {:ok, version}
    end
  end

  defp get_version(package: package) do
    {:ok, {200, _headers, %{"releases" => releases}}} = :hex_api_package.get(@config, package)
    %{"version" => version} = List.first(releases)

    {:ok, "~> #{version}"}
  end
end
