defmodule Mix.Tasks.Deps.Add do
  @moduledoc """
  Adds a package to your deps

  ## Usage

  $ mix deps.add --package ini

  ## Parameters

  --package   The package to lookup and add

  --version   A specific version to add, will error if it does not exist in hex.

  --only      Only add this dependency in these environments

  --override  Overrides any other version in other dependencies

  --runtime   Is this package runtime only

  """

  use Mix.Task

  require Logger

  @config :hex_core.default_config()
  @file_path Path.expand("./mix.exs")

  @shortdoc "adds a dependency"
  def run(args) do
    {params, _unmatched, _invalid} =
      OptionParser.parse(args,
        strict: [
          version: :string,
          package: :string,
          only: :string,
          override: :boolean,
          runtime: :boolean
        ]
      )

    with package when not is_nil(package) <- params[:package],
         {:ok, version} <- get_version(package, params[:version]),
         {:ok, mixfile} <-
           File.read!(@file_path)
           |> Code.string_to_quoted(),
         {updated, _} <-
           Macro.prewalk(mixfile, false, fn
             {:deps, _, []} = node, false ->
               {node, true}

             {:application, _, []} = node, true ->
               {node, false}

             {:do, deps}, true ->
               dep = build_dep(package, version, params)
               Logger.info("Added #{dep |> Macro.to_string()}")
               {{:do, [dep | deps]}, false}

             node, acc ->
               {node, acc}
           end),
         formatted <-
           updated
           |> Macro.to_string()
           |> Code.format_string!() do
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

  defp get_version(package, search_version) when not is_nil(search_version) do
    {:ok, {200, _headers, %{"releases" => releases}}} = :hex_api_package.get(@config, package)
    version = Enum.find(releases, &(Map.get(&1, "version") == search_version))

    if is_nil(version) do
      {:error, :no_version, "#{package} version #{version} not found"}
    else
      {:ok, version["version"]}
    end
  end

  defp get_version(package, _version) do
    {:ok, {200, _headers, %{"releases" => releases}}} = :hex_api_package.get(@config, package)
    %{"version" => version} = List.first(releases)

    {:ok, "~> #{version}"}
  end

  defp build_dep(package, version, params) do
    extra_args =
      [
        if params[:override] do
          {:override, true}
        end,
        if params[:only] do
          {:only, params[:only] |> String.to_atom()}
        end,
        if not is_nil(params[:runtime]) and not params[:runtime] do
          {:runtime, false}
        end
      ]
      |> Enum.filter(&(not is_nil(&1)))

    quote do
      {unquote(String.to_atom(package)), unquote(version), unquote(extra_args)}
    end
  end
end
