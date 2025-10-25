defmodule Ginject.Strategy.BehaviourAsDefault do
  @moduledoc """
  A resolution strategy that uses behaviour modules as service implementations
  with support for tagged implementations.

  This strategy provides a simple way to resolve service implementations with the following features:

  * Uses the behaviour module as its default implementation
  * Supports tagged implementations for contextual resolution
  * Allows configuration-based implementation mapping

  ## How It Works

  1. The strategy first looks for configured implementations that match the service
  2. If tagged implementations exist, they are ranked based on tag similarity
  3. If no matching implementation is found, falls back to the behaviour module itself

  ## Configuration

  You can configure implementations in your application config:

      config :dependency_injection,
        strategy: Ginject.Strategy.BehaviourAsDefault,
        services: [
          {MyApp.Module, [
            %{
              service: MyApp.UserService,
              impl: MyApp.UserService.PostgresImpl,
              tags: [:postgres, :production]
            },
            %{
              service: MyApp.UserService,
              impl: MyApp.UserService.InMemoryImpl,
              tags: [:memory, :test]
            }
          ]}
        ]

  ## Tag-Based Resolution

  Tags allow for contextual service resolution. The strategy ranks implementations
  based on how well their tags match the requested tags:

  ## Examples

      # Basic usage with default implementation
      service MyApp.UserService

      # With specific tags
      service MyApp.UserService, tag: :postgres
      service MyApp.UserService, tags: [:postgres, :production]

      # With custom default
      service MyApp.UserService, default: MyApp.UserService.DefaultImpl

  ## Implementation Selection

  The strategy selects implementations in this order:

  1. Configured implementation with highest tag similarity score
  2. Custom default implementation if specified
  3. The behaviour module itself as a last resort

  This provides a flexible yet predictable way to resolve service implementations
  while maintaining good defaults.
  """

  @behaviour Ginject.Strategy

  @impl true
  def get_implementation(service, module, opts) do
    tags = opts |> Keyword.get(:tags, Keyword.get(opts, :tag)) |> List.wrap()
    default = Keyword.get(opts, :default, service)

    ranked_services =
      opts
      |> Keyword.get(:services, [])
      |> Keyword.get(module, [])
      |> rank_service(service, tags)

    case ranked_services do
      [{rank, %{impl: implementation}} | _] when rank >= 0 -> {implementation, tags}
      _ -> {default, tags}
    end
  end

  defp rank_service(services, service, tags) do
    services
    |> rank_service(service)
    |> Enum.map(&{tags_similarity(&1[:tags] || [], tags), &1})
    |> Enum.sort(:desc)
  end

  defp rank_service(services, service),
    do: for(%{service: ^service} = config <- services, do: config)

  defp tags_similarity(t1, t2) when length(t1) > length(t2),
    do: tags_similarity(t2, t1)

  defp tags_similarity([], tags), do: -length(tags)
  defp tags_similarity(tags, tags), do: length(tags)

  defp tags_similarity(tags1, tags2) do
    Enum.reduce(tags1, 0, fn t, acc ->
      if t in tags2, do: acc + 1, else: acc
    end)
  end
end
