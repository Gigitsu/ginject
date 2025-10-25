defmodule Ginject.Strategy do
  @moduledoc """
  Defines the behaviour for dependency resolution strategies.

  A strategy in Ginject is responsible for determining how a service implementation
  is resolved from a service definition. Strategies provide flexibility in how
  dependencies are mapped to their concrete implementations, allowing for different
  resolution patterns based on your application's needs.

  ## Purpose of Strategies

  Strategies serve several key purposes in dependency injection:

  1. **Decoupling**: They separate the logic of how implementations are found from
     where they are used, making the system more flexible and maintainable.

  2. **Configuration**: They allow changing how dependencies are resolved without
     modifying the code that uses them.

  3. **Testing**: They make it easy to swap implementations for testing by using
     different strategies in different environments.

  4. **Runtime Flexibility**: They can provide different implementations based on
     runtime conditions or configuration.

  ## Implementing a Strategy

  To create a custom strategy, implement the `get_implementation/3` callback:

      defmodule MyApp.CustomStrategy do
        @behaviour Ginject.Strategy

        @impl true
        def get_implementation(service, module, opts) do
          # Your implementation resolution logic
          impl = find_implementation(service, opts)
          {impl, []}
        end
      end

  ## Built-in Strategies

  Ginject comes with some built-in strategies:

  * `Ginject.Strategy.BehaviourAsDefault` (default) - Uses behaviour modules as
    service interfaces and looks up their implementations
  * Other strategies can be added based on common patterns

  ## Using Strategies

  Strategies can be configured globally or per-service:

      # In config.exs
      config :ginject,
        strategy: MyApp.CustomStrategy,
        services: [
          {MyApp.Module, [
            %{service: MyApp.Service, impl: MyApp.Service.Impl}
          ]}
        ]

  ## Strategy Response

  Strategies must return a tuple `{implementation, identifiers}`:
  * `implementation`: The module that implements the service
  * `identifiers`: Any additional identification info (used internally)
  """

  @doc """
  Resolves the implementation module for a given service.

  This callback is called by Ginject whenever it needs to resolve a service implementation.
  The strategy must determine which module should be used to implement the requested service
  based on the service module, the requesting module, and any provided options.

  ## Parameters

    * `service` - The service module to resolve (typically a behaviour defining the interface)
    * `module` - The module requesting the service implementation
    * `opts` - A keyword list of options that may include:
      * `:services` - A list of configured service implementations
      * `:default` - A default implementation to use if none is found
      * `:tag` or `:tags` - Tags for contextual resolution
      * Other strategy-specific options

  ## Returns

  A tuple containing:
    * `{implementation, identifiers}`
      * `implementation` - The module that implements the service
      * `identifiers` - Any additional identification info (like tags) used for caching or debugging

  ## Example Implementation

      @impl true
      def get_implementation(service, module, opts) do
        case find_implementation(service, module, opts) do
          nil -> {opts[:default] || service, []}
          impl -> {impl, opts[:tags] || []}
        end
      end

  ## Error Handling

  The implementation should:
    * Always return a valid module as the implementation
    * Never return nil or undefined values
    * Use the service module itself or a configured default as fallback
    * Raise an error only in cases of invalid configuration

  ## Best Practices

    * Cache expensive lookups when possible
    * Provide meaningful identifiers for debugging
    * Handle all edge cases gracefully
    * Document any strategy-specific options
  """
  @callback get_implementation(service :: module(), module :: module(), opts :: keyword()) ::
              {impl :: module(), ids :: any()}
end
