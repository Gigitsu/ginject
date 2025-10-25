defmodule GinjectTest do
  use ExUnit.Case

  doctest Ginject

  defmodule SimpleService do
    @callback hello() :: :world
  end

  defmodule SimpleModule do
    use Ginject
    service GinjectTest.SimpleService
  end

  test "use Ginject" do
    assert function_exported?(SimpleModule, :__injected_services__, 0)
  end
end
