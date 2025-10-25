ExUnit.start()

Application.put_env(:ginject, Ginject.DI, strategy: Ginject.Strategy.Mox)
