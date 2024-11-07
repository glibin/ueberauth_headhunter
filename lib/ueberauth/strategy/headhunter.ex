defmodule Ueberauth.Strategy.Headhunter do
  @moduledoc """
  Headhunter Strategy for Überauth.
  """

  use Ueberauth.Strategy,
    default_scope: "",
    uid_field: :id,
    send_redirect_uri: true,
    oauth2_module: Ueberauth.Strategy.Headhunter.OAuth

  alias Ueberauth.Auth.Info
  alias Ueberauth.Auth.Credentials
  alias Ueberauth.Auth.Extra

  @doc """
  Handles the initial redirect to the headhunter authentication page.
  """

  def handle_request!(conn) do
    opts =
      []
      |> with_state_param(conn)
      |> with_redirect_uri(conn)

    module = option(conn, :oauth2_module)
    redirect!(conn, apply(module, :authorize_url!, [opts]))
  end

  @doc """
  Handles the callback from Headhunter.
  When there is a failure from Headhunter the failure is included in the
  `ueberauth_failure` struct. Otherwise the information returned from Headhunter is
  returned in the `Ueberauth.Auth` struct.
  """
  def handle_callback!(%Plug.Conn{params: %{"code" => code}} = conn) do
    module = option(conn, :oauth2_module)
    token = apply(module, :get_token!, [[code: code, redirect_uri: callback_url(conn)]])

    if token.access_token == nil do
      set_errors!(conn, [
        error(token.other_params["error"], token.other_params["error_description"])
      ])
    else
      fetch_user(conn, token)
    end
  end

  @doc false
  def handle_callback!(conn) do
    set_errors!(conn, [error("missing_code", "No code received")])
  end

  @doc """
  Cleans up the private area of the connection used for passing the raw Headhunter
  response around during the callback.
  """
  def handle_cleanup!(conn) do
    conn
    |> put_private(:headhunter_user, nil)
    |> put_private(:headhunter_token, nil)
  end

  @doc """
  Fetches the `:uid` field from the Headhunter response.
  This defaults to the option `:uid_field` which in-turn defaults to `:id`
  """
  def uid(conn) do
    conn |> option(:uid_field) |> to_string() |> fetch_uid(conn)
  end

  @doc """
  Includes the credentials from the Headhunter response.
  """
  def credentials(conn) do
    token = conn.private.headhunter_token

    %Credentials{
      token: token.access_token,
      refresh_token: token.refresh_token,
      expires_at: (DateTime.utc_now() |> DateTime.to_unix()) + token.expires_at,
      token_type: token.token_type,
      expires: !!token.expires_at,
    }
  end

  @doc """
  Fetches the fields to populate the info section of the `Ueberauth.Auth`
  struct.
  """
  def info(conn) do
    user = conn.private.headhunter_user

    %Info{
      first_name: user["first_name"],
      last_name: user["last_name"],
      email: user["email"],
      phone: user["phone"],
      urls: %{}
    }
  end

  @doc """
  Stores the raw information (including the token) obtained from the Headhunter
  callback.
  """
  def extra(conn) do
    %Extra{
      raw_info: %{
        token: conn.private.headhunter_token,
        user: conn.private.headhunter_user
      }
    }
  end

  defp fetch_uid(field, conn) do
    conn.private.headhunter_user[field]
  end

  defp fetch_user(conn, token) do
    conn = put_private(conn, :headhunter_token, token)

    case Ueberauth.Strategy.Headhunter.OAuth.get(
           token,
           "https://api.hh.ru/me"
         ) do
      {:ok, %OAuth2.Response{status_code: 401, body: _body}} ->
        set_errors!(conn, [error("token", "unauthorized")])

      {:ok, %OAuth2.Response{status_code: status_code, body: user}}
      when status_code in 200..399 ->
        put_private(conn, :headhunter_user, user)

      {:error, %OAuth2.Error{reason: reason}} ->
        set_errors!(conn, [error("OAuth2", reason)])

      {:error, %OAuth2.Response{body: %{"message" => reason}}} ->
        set_errors!(conn, [error("OAuth2", reason)])

      {:error, error} ->
        set_errors!(conn, [error("OAuth2", "uknown error")])
    end
  end

  defp option(conn, key) do
    Keyword.get(options(conn), key, Keyword.get(default_options(), key))
  end

  defp with_redirect_uri(opts, conn) do
    if option(conn, :send_redirect_uri) do
      opts |> Keyword.put(:redirect_uri, callback_url(conn))
    else
      opts
    end
  end
end
