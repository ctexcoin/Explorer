defmodule Explorer.ExchangeRates.Source.CoinCtex do
  @moduledoc """
  Adapter for fetching exchange rates from https://ctexscan.com/api/
  """

  alias Explorer.ExchangeRates.{Source, Token}

  import Source, only: [to_decimal: 1]

  require Logger

  @behaviour Source

  @impl Source
  def format_data(json_data) do
    lastPrice = json_data["data"]["liveTokenRate"]
    [
      %Token{
        available_supply: to_decimal(0),
        total_supply: to_decimal(0),
        btc_value: to_decimal(0),
        id: nil,
        last_updated: nil,
        market_cap_usd: to_decimal(0),
        name: Explorer.coin_name(),
        symbol: Explorer.coin(),
        usd_value: to_decimal(lastPrice),
        volume_24h_usd: to_decimal(0),
        percent_change_24h: to_decimal(0),
        eth_value: to_decimal(0)
      }
    ]
  end

  @impl Source
  def format_data(_), do: []

  @impl Source
  def source_url do
    symbol = ""
    if symbol, do: "#{api_quotes_latest_url()}", else: nil
  end

  @impl Source
  def headers do
    []
  end

  defp base_url do
    config(:base_url) || "https://ctexscan.com/api"
  end

  defp api_quotes_latest_url do
    "#{base_url()}/LiveTokenRateApi/LiveCoinRateApi"
  end

  @spec config(atom()) :: term
  defp config(key) do
    Application.get_env(:explorer, __MODULE__, [])[key]
  end
end
