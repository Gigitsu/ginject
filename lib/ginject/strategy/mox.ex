if Code.ensure_loaded?(Mox) do
  defmodule Ginject.Strategy.Mox do
    @moduledoc """
    A strategy that automatically creates mock implementations using the Hammox library
    for testing purposes.

    This strategy is particularly useful in test environments where you want to:
    * Automatically mock service behaviors
    * Create unique mock implementations for each test
    * Avoid manual mock setup and teardown

    ## Features

    * Automatic mock creation for behaviours
    * Unique mock names to prevent conflicts
    * Integration with Hammox for type-checked mocks
    * Zero-configuration mock setup

    ## Usage

    1. Add Hammox to your dependencies:

        ```elixir
        # mix.exs
        defp deps do
          [
            {:hammox, "~> 0.7", only: :test}
          ]
        end
        ```

    2. Configure Ginject to use this strategy in test:

        ```elixir
        # config/test.exs
        config :dependency_injection,
          strategy: Ginject.Strategy.Hammox
        ```

    3. Use in your tests:

        ```elixir
        defmodule MyApp.UserServiceTest do
          use ExUnit.Case
          import Mox

          setup do
            # Your service will automatically get a mock implementation
            service MyApp.UserService
            :ok
          end

          test "creates a user" do
            expect(MyApp.UserService.Mox, :create_user, fn params ->
              {:ok, %User{name: params.name}}
            end)

            assert {:ok, user} = MyService.create_user(%{name: "John"})
          end
        end
        ```

    ## How It Works

    When a service is requested, this strategy:
    1. Generates a unique mock name for the service
    2. Creates a new mock implementation using Hammox
    3. Returns the mock module for injection

    The mock name is guaranteed to be unique through the use of
    `:erlang.unique_integer()`, preventing any potential naming conflicts
    in your test suite.

    ## Benefits

    * **Type Safety**: Hammox provides type checking for your mocks
    * **Automatic Setup**: No need to manually define mocks
    * **Isolation**: Each mock is unique, preventing test interference
    * **Simplicity**: Zero configuration required beyond strategy selection

    ## Note

    This strategy is only available when Hammox is loaded (typically in
    test environment). Make sure to have Hammox in your dependencies
    before using this strategy.
    """
    import Mox

    @behaviour Ginject.Strategy

    @impl true
    def get_implementation(service, _module, _opts) do
      module_mock = Module.concat(service, "Mox#{:erlang.unique_integer()}")
      {defmock(module_mock, for: service), []}
    end
  end
end
