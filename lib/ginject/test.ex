defmodule Ginject.Test do
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
