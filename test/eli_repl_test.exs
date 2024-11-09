defmodule EliReplTest do
  use ExUnit.Case
  doctest EliRepl

  test "greets the world" do
    assert EliRepl.hello() == :world
  end
end
