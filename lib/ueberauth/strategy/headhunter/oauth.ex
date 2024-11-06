defmodule Ueberauth.Strategy.Headhunter.OAuth do
  @moduledoc """
  OAuth2 for Headhunter.

  Add `:client_id` and `:client_secret` to your configuration:

      config :ueberauth, Ueberauth.Strategy.Headhunter.OAuth,
        client_id: System.get_env("HEADHUNTER_CLIENT_ID"),
        client_secret: System.get_env("HEADHUNTER_CLIENT_SECRET")

  """
  use OAuth2.Strategy

  @defaults [
    strategy: __MODULE__,
    authorize_url: "https://hh.ru/oauth/authorize",
    token_url: "https://api.hh.ru/token"
  ]

  @doc """
  Construct a client for requests to Headhunter.

  This will be setup automatically for you in `Ueberauth.Strategy.Headhunter`.

  These options are only useful for usage outside the normal callback phase of Ueberauth.
  """
  def client(opts \\ []) do
    config = Application.get_env(:ueberauth, __MODULE__, [])
    opts = @defaults |> Keyword.merge(opts) |> Keyword.merge(config) |> resolve_values()
    json_library = Ueberauth.json_library()

    client = OAuth2.Client.new(opts)

    client
    |> OAuth2.Client.put_header("User-Agent", "ElixirApp/0.1 (glibin.v@gmail.com)")
    |> OAuth2.Client.put_serializer("application/json", json_library)
  end

  @doc """
  Provides the authorize url for the request phase of Ueberauth.
  No need to call this usually.
  """
  def authorize_url!(params \\ [], opts \\ []) do
    opts
    |> client
    |> OAuth2.Client.authorize_url!(params)
  end

  def get(token, url, headers \\ [], opts \\ []) do
    [token: token]
    |> client
    |> put_param("client_secret", client().client_secret)
    |> OAuth2.Client.get(url, headers, opts)
  end

  def get_token!(params \\ [], options \\ []) do
    headers = Keyword.get(options, :headers, [])
    options = Keyword.get(options, :options, [])
    client_options = Keyword.get(options, :client_options, [])
    client = OAuth2.Client.get_token!(client(client_options), params, headers, options)
    client.token
  end

  # Strategy Callbacks

  def authorize_url(client, params) do
    OAuth2.Strategy.AuthCode.authorize_url(client, params)
  end

  def get_token(client, params, headers) do
    client
    |> put_param("client_secret", client.client_secret)
    |> put_header("Accept", "application/json")
    |> OAuth2.Strategy.AuthCode.get_token(params, headers)
  end

  defp resolve_values(list) do
    for {key, value} <- list do
      {key, resolve_value(value)}
    end
  end

  defp resolve_value({m, f, a}) when is_atom(m) and is_atom(f), do: apply(m, f, a)
  defp resolve_value(v), do: v
end
