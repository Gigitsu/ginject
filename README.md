# Ginject

> A lightweight, flexible dependency injection framework for Elixir.

![Elixir](https://img.shields.io/badge/Elixir-elixir?logo=elixir&color=%234B275F)
[![Hex.pm](https://img.shields.io/hexpm/v/ginject.svg)](https://hex.pm/packages/ginject)
[![Documentation](https://img.shields.io/badge/hex-docs-blue.svg)](https://hexdocs.pm/ginject)
[![Elixir CI](https://github.com/Gigitsu/ginject/workflows/CI/badge.svg)](https://github.com/Gigitsu/ginject/actions)
[![License](https://img.shields.io/hexpm/l/ginject.svg)](https://github.com/Gigitsu/ginject/blob/main/LICENSE)
[![Hex.pm Download Total](https://img.shields.io/hexpm/dt/ginject.svg)](https://hex.pm/packages/ginject)

## About

Ginject is a thoughtfully designed dependency injection framework for Elixir applications that embraces the philosophy of explicit over implicit. It provides a clean, declarative way to manage dependencies while maintaining the flexibility and power that Elixir developers expect.

### Why Ginject?

* **Elixir-centric Design**: Built from the ground up with Elixir's patterns and practices in mind
* **Compile-time Resolution**: Catch configuration issues early with compile-time dependency resolution
* **Flexible Strategy System**: Easily adapt to different dependency resolution needs through configurable strategies
* **Testing First**: First-class support for testing with mock implementations and strategy swapping
* **Zero Runtime Overhead**: All the dependency wiring happens at compile time
* **Safety**: Leverages Elixir behaviours for interface definitions

## Installation

Add `ginject` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ginject, "~> 0.1.0"}
  ]
end
```

## Usage

### Basic Usage

There are two ways to inject services into a module:

#### Using the `use` directive with `:services` option

```elixir
defmodule YourApp.UserController do
  use Ginject, services: [
    YourApp.UserService,
    {YourApp.AuthService, as: Auth}
  ]

  def create_user(params) do
    with {:ok, user} <- UserService.create(params),
         {:ok, token} <- Auth.generate_token(user) do
      {:ok, %{user: user, token: token}}
    end
  end
end
```

#### Using the `service` macro

```elixir
defmodule YourApp.UserController do
  use Ginject

  service YourApp.UserService
  service YourApp.AuthService, as: Auth

  def create_user(params) do
    with {:ok, user} <- UserService.create(params),
         {:ok, token} <- Auth.generate_token(user) do
      {:ok, %{user: user, token: token}}
    end
  end
end
```

### Configuration

Configure Ginject in your application config:

```elixir
# config/config.exs
config :ginject, Ginject.DI,
  strategy: Ginject.Strategy.BehaviourAsDefault,
  services: [
    {YourApp.UserController, [
      %{service: YourApp.UserService, impl: YourApp.UserService.Impl},
      %{service: YourApp.AuthService, impl: YourApp.AuthService.Impl}
    ]}
  ]
```

## Best Practices

### 1. Define Service Interfaces Using Behaviours

```elixir
defmodule YourApp.UserService do
  @callback create(params :: map()) :: {:ok, User.t()} | {:error, term()}
  @callback update(id :: integer(), params :: map()) :: {:ok, User.t()} | {:error, term()}
end
```

### 2. Keep Service Implementations Isolated

```elixir
defmodule YourApp.UserService.Impl do
  @behaviour YourApp.UserService
  
  @impl true
  def create(params) do
    # Implementation
  end

  @impl true
  def update(id, params) do
    # Implementation
  end
end
```

### 3. Use Meaningful Aliases

Choose clear and concise aliases that make the code more readable:

```elixir
# Good
service UserManagement.AuthenticationService, as: Auth
service UserManagement.AuthorizationService, as: Permissions

# Avoid
service UserManagement.AuthenticationService, as: A
service UserManagement.AuthorizationService, as: Auth2
```

## Testing

Add `Hammox` dependency in your `mix.exs`:


```elixir
def deps do
  [
    ...,
    {:hammox, "~> 0.7", only: :test}
  ]
end
```

Use the builtin Mox behaviour:

```elixir
# config/test.exs
config :ginject, Ginject.Di, strategy: Ginject.Strategy.Mox
```

While in your test use:

```elixir
defmodule MyTest do
  use ExUnit.Case
  use Ginject.Test

  test "..." do
    mock = get_injected_service(MyModule, MyService)

    expect(mock, :function_name, fn ->
      # assertions
    end)
  end
end
```

See `Mox` or `Hammox` documentation to learn how to set expectations.

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

Make sure to:
- Write tests for new features
- Update documentation as needed
- Follow the existing coding style
- Write good commit messages

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Credits

Created and maintained by [Gigitsu](https://github.com/Gigitsu).
