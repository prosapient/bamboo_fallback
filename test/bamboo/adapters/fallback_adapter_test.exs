defmodule Bamboo.Adapters.FallbackAdapterTest do
  use ExUnit.Case, async: true
  alias Bamboo.{FallbackAdapter, MockAdapter}
  import Mox
  import ExUnit.CaptureLog

  setup :set_mox_from_context
  setup :verify_on_exit!

  test "handle_config/1" do
    config = %{
      fallback_options: [
        {MockAdapter, a: 1, b: 2},
        {MockAdapter, c: 3}
      ]
    }

    MockAdapter
    |> expect(:handle_config, & &1)
    |> expect(:handle_config, & &1)

    assert %{
             fallback_options: [
               {MockAdapter, %{a: 1, b: 2}},
               {MockAdapter, %{c: 3}}
             ]
           } == FallbackAdapter.handle_config(config)
  end

  test "deliver/2" do
    email = Bamboo.Email.new_email()

    config = %{
      fallback_options: [
        {MockAdapter, %{a: 1, b: 2}},
        {MockAdapter, %{c: 3}}
      ]
    }

    MockAdapter
    |> expect(:deliver, fn _email, _config -> {:ok, email} end)

    assert {:ok, email} == FallbackAdapter.deliver(email, config)

    MockAdapter
    |> expect(:deliver, fn _email, _config ->
      {:error, Bamboo.ApiError.build_api_error("ooops")}
    end)
    |> expect(:deliver, fn _email, _config ->
      {:ok, email}
    end)

    assert capture_log(fn ->
             assert {:ok, email} == FallbackAdapter.deliver(email, config)
           end) == ""

    MockAdapter
    |> expect(:deliver, fn _email, _config ->
      {:error, Bamboo.ApiError.build_api_error("ooops1")}
    end)
    |> expect(:deliver, fn _email, _config ->
      {:error, Bamboo.ApiError.build_api_error("ooops2")}
    end)

    assert {:error,
            %Bamboo.ApiError{
              message: "None of given providers sent an email\nooops2\n\nooops1\n"
            }} = FallbackAdapter.deliver(email, config)
  end
end
