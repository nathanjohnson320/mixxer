# Mixxer

Adds two mix tasks for dealing with versioning and adding dependencies found in npm.

## mix version

Equivalent to `npm version`

#### Usage

```
# Given current mix version of 0.1.0
mix version major
# mix.exs version is now 1.0.0
mix version patch
# mix.exs version is now 1.0.1
mix version minor
# mix.exs version is now 1.1.0

# git commits will exist for each version as will tags of v1.0.0, v1.0.1, and v1.1.0
```

## mix deps.add

Equivalent to `npm install --save/--save-dev`

#### Usage

```
# Add latest version of a package from hex.pm
mix deps.add --package ini

# Add specific version of a package
# Will error if version not found. Use mix hex.info <package> if you need to see existing versions
mix deps.add --package ini --version 1.0.0

# Add latest version of a package from hex.pm in specific environments
mix deps.add --package ini --only dev
{:ini, "~> 1.0.0", only: :dev}

# Add latest version of a package from hex.pm with override flag
mix deps.add --package ini --override
{:ini, "~> 1.0.0", override: true}
```


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `mixxer` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:mixxer, "~> 0.1.0", only: :dev}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/mixxer](https://hexdocs.pm/mixxer).

