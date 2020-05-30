defmodule MixxerTest do
  use ExUnit.Case
  doctest Mixxer

  test "greets the world" do
    assert Mixxer.hello() == :world
  end
end
