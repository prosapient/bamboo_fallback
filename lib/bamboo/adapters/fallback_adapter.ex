defmodule Bamboo.FallbackAdapter do
  @moduledoc """
  This adapter allows you to compose multiple adapters to increase the guarantee of delivering.
  It applies adapters one by one and fails only when all adapters fail.

  Config example:

      config :myapp, MyApp.Mailer,
        adapter:  Bamboo.FallbackAdapter,
        fallback_options: [
          {Bamboo.SendGridAdapter, api_key: "SENDGRID_API_KEY"},
          {Bamboo.MailgunAdapter, api_key: "MAILGUN_API_KEY", domain: "MAILGUN_DOMAIN"}
        ]
  """
  @behaviour Bamboo.Adapter

  def handle_config(config) do
    config
    |> Map.update!(:fallback_options, fn adapter_configs ->
      adapter_configs
      |> Enum.map(fn {adapter, config} ->
        {
          adapter,
          config |> Enum.into(%{}) |> adapter.handle_config()
        }
      end)
    end)
  end

  def deliver(email, %{fallback_options: adapter_configs}) do
    adapter_configs
    |> Enum.reduce_while([], fn {adapter, config}, errors ->
      case adapter.deliver(email, config) do
        {:ok, email} ->
          {:halt, email}

        {:error, e} ->
          {:cont, [e | errors]}
      end
    end)
    |> case do
      errors when is_list(errors) ->
        api_error =
          Bamboo.ApiError.build_api_error("""
          None of given providers sent an email
          #{errors |> Enum.map(& &1.message) |> Enum.join("\n\n")}
          """)

        {:error, api_error}

      email ->
        {:ok, email}
    end
  end

  def supports_attachments?, do: true
end
