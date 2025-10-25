defmodule Ginject do
  @moduledoc """
  Ginject is a lightweight, flexible dependency injection framework for Elixir applications.
  It provides a clean and intuitive way to manage dependencies between modules while promoting
  loose coupling and better testability.

  ## Features

  * Simple and declarative dependency injection
  * Configuration-based injection strategies
  * Compile-time service resolution

  ## Service Injection Methods

  There are two ways to inject services into a module:

  ### Using the `:services` option

      defmodule Your.Module do
        use Ginject, services: [
          Your.ServiceA,
          {Your.ServiceB, as: B}
        ]

        def run do
          ServiceA.foo()
          B.foo()
        end
      end

  ### Using the `service` macro

      defmodule Your.Module do
        use Ginject

        service Your.ServiceA
        service Your.ServiceB, as: B

        def run do
          ServiceA.foo()
          B.foo()
        end
      end

  ## Strategies

  A strategy in Ginject defines how a service implementation is resolved. The default strategy
  is `Ginject.Strategy.BehaviourAsDefault`, which uses modules that defines the behaviour  as its
  implementation.

  For more details about strategies, see `Ginject.Strategy`.

  ## Configuration

  Ginject can be configured in your application config:

      config :ginject,
        # The strategy to use for resolving service implementations
        strategy: Ginject.Strategy.BehaviourAsDefault,

        # Service implementation mappings
        services: [
          {Your.Module, [
            %{service: Your.ServiceA, impl: Your.ServiceA.Impl},
            %{service: Your.ServiceB, impl: Your.ServiceB.Impl}
          ]}
        ]

  ## Best Practices

  1. Define service interfaces using behaviours
  2. Keep service implementations isolated
  3. Use meaningful aliases for better code readability
  4. Configure service implementations in your application config
  5. Use different implementations for testing

  """

  @type service :: module()

  defmacro __using__(opts \\ []), do: Ginject.DI.__init__(opts, __CALLER__)
end
