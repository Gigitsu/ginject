defmodule Ginject.Test do
  @moduledoc """
  Helpers for accessing injected services from tests.

  This module provides a small testing-focused API to retrieve the concrete
  implementation that was injected into a module at runtime by the
  `Ginject` injection mechanism. It exposes a `__using__/1` macro that imports
  the convenience function `get_injected_service/2` and `get_injected_service/3`.

  # Example

      defmodule MyServiceTest do
        use ExUnit.Case
        use Ginject.Test

        test "calls the injected implementation" do
          impl = get_injected_service(Module.Using.The.Service, The.Service)
          assert function_exported?(impl, :call, 1)
        end
      end
  """

  @type service :: Ginject.service()

  defmacro __using__(_opts) do
    quote do
      import unquote(__MODULE__), only: [get_injected_service: 2, get_injected_service: 3]
    end
  end

  @doc """
  Returns the actual service injected into the specified module.

  ## Example

      iex> impl = get_injected_service(Module.Using.The.Service, The.Service)
  """
  @spec get_injected_service(module(), service(), ids :: any()) :: service()
  def get_injected_service(mod, service, ids \\ []), do: mod.__injected_service__(service, ids)
end
