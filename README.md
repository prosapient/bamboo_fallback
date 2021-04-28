# Bamboo.FallbackAdapter

An adapter for the [Bamboo](https://github.com/thoughtbot/bamboo) email app.
Allows you to compose multiple adapters to increase the guarantee of delivering.
It applies adapters one by one and fails only when all adapters fail.

## Installation

The package can be installed by adding `bamboo_fallback` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:bamboo_fallback, "~> 2.0"}
  ]
end
```

## Config
```elixir
config :myapp, MyApp.Mailer,
  adapter: Bamboo.FallbackAdapter,
  fallback_options: [
    {Bamboo.SendGridAdapter, api_key: "SENDGRID_API_KEY"},
    {Bamboo.MailgunAdapter, api_key: "MAILGUN_API_KEY", domain: "MAILGUN_DOMAIN"}
  ]
```
This example uses `SendGridAdapter` as a primary adapter and `MailgunAdapter` as a secondary one.
You can use as many adapters as you want.
