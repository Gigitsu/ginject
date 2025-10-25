defmodule Ginject.Case do
  @moduledoc """
  This module defines the test case to be used by
  every tests in discoup apps.

  This common test case defines some common imports and
  configuration, such as the ones for Hammox mocking lib.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      import unquote(__MODULE__)
    end
  end

  def to_struct(kind, data),
    do: struct(kind, Map.new(data, fn {k, v} -> {String.to_atom(k), v} end))
end
