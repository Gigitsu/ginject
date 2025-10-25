defmodule Ginject.DI do
  @moduledoc """
  The core dependency injection module that handles service registration and resolution.

  This module provides the underlying implementation for Ginject's dependency injection
  system. It manages:

  * Service registration and tracking
  * Implementation resolution through configurable strategies
  * Compile-time alias creation
  * Runtime service resolution

  ## Architecture

  The DI system works in several layers:

  1. **Service Registration**: Through the use of `service/2` macro
  2. **Implementation Resolution**: Using configurable strategies (default: `Ginject.Strategy.BehaviourAsDefault`)
  3. **Alias Creation**: For convenient access to resolved implementations
  4. **Runtime Resolution**: For dynamic service resolution through `get_service!/3`

  This module is primarily used internally by `Ginject` and shouldn't be used
  directly in most cases. Use the `Ginject` module's public interface instead.
  """

  @default_strategy Ginject.Strategy.BehaviourAsDefault

  def __init__(opts, caller) do
    services = opts |> Keyword.get(:services, []) |> expand_services(caller)

    quote do
      Module.register_attribute(__MODULE__, :injected_services, accumulate: true)
      import unquote(__MODULE__), only: [service: 1, service: 2]
      unquote(services)

      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def __injected_services__, do: @injected_services
    end
  end

  @doc """
  Injects a service into the current module.

  This macro provides a declarative way to inject dependencies. It creates an alias
  for the resolved service implementation and registers the service in the module's
  injected services list.

  ## Options

    * `:as` - The alias to use for the injected service. If not provided,
      the last part of the service's module name will be used.

  ## Examples

      defmodule MyModule do
        use Ginject

        # Basic usage
        service MyApp.UserService

        # With custom alias
        service MyApp.AuthenticationService, as: Auth
      end

  """
  defmacro service(service, opts \\ []), do: gen_alias(service, opts, __CALLER__)

  @doc """
  Returns the implementation module for a given service at runtime.

  This function is similar to the `service` macro but instead of creating an alias,
  it returns the resolved implementation module directly. This is useful when you need
  to resolve service implementations dynamically at runtime.

  ## Parameters

    * `service` - The service module to resolve
    * `module` - The module requesting the service implementation
    * `opts` - Additional options to pass to the strategy

  ## Returns

    * The resolved implementation module for the service

  ## Examples

      # Get implementation for UserService
      impl = Ginject.get_service!(MyApp.UserService, MyModule)
      impl.some_function()

      # With additional options
      impl = Ginject.get_service!(MyApp.AuthService, MyModule, custom_opt: :value)

  ## Error Handling

  Raises an `ArgumentError` if no valid implementation can be resolved for the service.
  """
  @spec get_service!(Ginject.service(), opts :: any()) :: Ginject.service()
  def get_service!(service, module, opts \\ []) do
    {impl, _} = find_service_implementation!(service, module, opts)
    impl
  end

  defp expand_services(services, env), do: Enum.map(services, &expand_service(&1, env))

  defp expand_service({service, opts}, env), do: gen_alias(service, opts, env)
  defp expand_service(service, env), do: gen_alias(service, [], env)

  defp gen_alias(service, opts, env) do
    service = Macro.expand(service, env)
    {impl, ids} = find_service_implementation!(service, env.module, opts)

    as = Keyword.get(opts, :as, get_name(service))

    quote do
      Module.put_attribute(
        __MODULE__,
        :injected_services,
        {{unquote(service), unquote(ids)}, unquote(impl)}
      )

      alias unquote(impl), as: unquote(as)
      def __injected_service__(unquote(service), unquote(ids)), do: unquote(impl)
    end
  end

  defp find_service_implementation!(service, module, opts) do
    config = Application.get_env(:ginject, __MODULE__, [])
    strategy = Keyword.get(config, :strategy, @default_strategy)

    {impl, ids} = strategy.get_implementation(service, module, Keyword.merge(config, opts))

    unless is_atom(impl) do
      raise ArgumentError,
            ~s(Expected a valid implementation for service `#{service}`, got `#{inspect(impl)}`)
    end

    {impl, ids}
  end

  defp get_name(mod),
    do: mod |> Module.split() |> Enum.reverse() |> List.first() |> List.wrap() |> Module.concat()
end
