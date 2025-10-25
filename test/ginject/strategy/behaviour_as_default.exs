defmodule Ginject.Strategy.BehaviourAsDefaultTest do
  use ExUnit.Case, async: true

  alias Ginject.Strategy.BehaviourAsDefault

  defmodule SimpleModule do
  end

  defmodule Behaviour1 do
  end

  defmodule Behaviour1.ImplA do
  end

  defmodule Behaviour1.ImplB do
  end

  describe "get_implementation/3" do
    test "should return behaviour as default" do
      assert {Behaviour1, []} ==
               BehaviourAsDefault.get_implementation(Behaviour1, SimpleModule, [])
    end

    test "should return behaviour should return the correct tag or default if no tag match" do
      config = [
        services: [
          {SimpleModule,
           [
             %{service: Behaviour1, impl: Behaviour1.ImplA, tags: [:impl_a]},
             %{service: Behaviour1, impl: Behaviour1.ImplB, tags: [:impl_b]}
           ]}
        ]
      ]

      assert {Behaviour1, []} ==
               BehaviourAsDefault.get_implementation(Behaviour1, SimpleModule, config)

      assert {Behaviour1.ImplA, [:impl_a]} ==
               BehaviourAsDefault.get_implementation(
                 Behaviour1,
                 SimpleModule,
                 Keyword.put(config, :tag, :impl_a)
               )

      assert {Behaviour1.ImplB, [:impl_b]} ==
               BehaviourAsDefault.get_implementation(
                 Behaviour1,
                 SimpleModule,
                 Keyword.put(config, :tag, :impl_b)
               )
    end
  end
end
