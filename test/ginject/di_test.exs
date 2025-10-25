defmodule Ginject.DITest do
  use ExUnit.Case

  doctest Ginject.DI

  defmodule SimpleService do
    @callback hello() :: :world
  end

  defmodule SimpleFromMacro do
    use Ginject

    service Ginject.DITest.SimpleService, as: Svc

    def get_service, do: Svc
  end

  defmodule SimpleFromOpts do
    use Ginject,
      services: [
        {Ginject.DITest.SimpleService, as: SvcOpts}
      ]

    def get_service, do: SvcOpts
  end

  test "Injected service" do
    assert SimpleFromMacro.get_service() ==
             SimpleFromMacro.__injected_service__(Ginject.DITest.SimpleService, [])

    assert SimpleFromOpts.get_service() ==
             SimpleFromOpts.__injected_service__(Ginject.DITest.SimpleService, [])
  end
end
