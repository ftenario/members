defmodule MembersTest do
  use ExUnit.Case
  doctest Members

  test "greets the world" do
    assert Members.hello() == :world
  end
end
