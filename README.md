# Überauth Headhunter

[![Module Version](https://img.shields.io/hexpm/v/ueberauth_headhunter.svg)](https://hex.pm/packages/ueberauth_headhunter)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/ueberauth_headhunter/)
[![License](https://img.shields.io/hexpm/l/ueberauth_headhunter.svg)](https://github.com/glibin/ueberauth_headhunter/blob/main/LICENSE.md)

> Headhunter OAuth2 strategy for Überauth.

## Installation

1.  Setup your application at https://headhunter.readme.io/docs/marketplace-oauth-authorization.

2.  Add `:ueberauth_headhunter` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [
        {:ueberauth_headhunter, "~> 0.0.1"}
      ]
    end
    ```

3.  Add Headhunter to your Überauth configuration:

    ```elixir
    config :ueberauth, Ueberauth,
      providers: [
        headhunter: {Ueberauth.Strategy.Headhunter, []}
      ]
    ```

4.  Update your provider configuration:

    Use that if you want to read client ID/secret from the environment
    variables in the compile time:

    ```elixir
    config :ueberauth, Ueberauth.Strategy.Headhunter.OAuth,
      client_id: System.get_env("HEADHUNTER_CLIENT_ID"),
      client_secret: System.get_env("HEADHUNTER_CLIENT_SECRET")
    ```

    Use that if you want to read client ID/secret from the environment
    variables in the run time:

    ```elixir
    config :ueberauth, Ueberauth.Strategy.Headhunter.OAuth,
      client_id: {System, :get_env, ["HEADHUNTER_CLIENT_ID"]},
      client_secret: {System, :get_env, ["HEADHUNTER_CLIENT_SECRET"]}
    ```

5.  Include the Überauth plug in your controller:

    ```elixir
    defmodule MyApp.AuthController do
      use MyApp.Web, :controller
      plug Ueberauth
      ...
    end
    ```

6.  Create the request and callback routes if you haven't already:

    ```elixir
    scope "/auth", MyApp do
      pipe_through :browser

      get "/:provider", AuthController, :request
      get "/:provider/callback", AuthController, :callback
    end
    ```

7.  Your controller needs to implement callbacks to deal with `Ueberauth.Auth` and `Ueberauth.Failure` responses.

For an example implementation see the [Überauth Example](https://github.com/ueberauth/ueberauth_example) application.

## Calling

Depending on the configured url you can initiate the request through:

    /auth/headhunter


## Copyright and License

Copyright (c) 2022 Vitaly Glibin

Released under the MIT License, which can be found in the repository in [LICENSE](https://github.com/ueberauth/ueberauth_headhunter/blob/main/LICENSE).