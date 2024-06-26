# credo:disable-for-this-file
defmodule BlockScoutWeb.AddressContractController do
  use BlockScoutWeb, :controller

  import BlockScoutWeb.Account.AuthController, only: [current_user: 1]
  import BlockScoutWeb.Models.GetAddressTags, only: [get_address_tags: 2]

  alias BlockScoutWeb.AccessHelpers
  alias BlockScoutWeb.AddressContractVerificationController, as: VerificationController
  alias Explorer.{Chain, Market}
  alias Explorer.ExchangeRates.Token
  alias Indexer.Fetcher.CoinBalanceOnDemand
  alias Explorer.Admin.Ads

  def index(conn, %{"address_id" => address_hash_string} = params) do
    address_options = [
      necessity_by_association: %{
        :contracts_creation_internal_transaction => :optional,
        :names => :optional,
        :smart_contract => :optional,
        :token => :optional,
        :contracts_creation_transaction => :optional
      }
    ]

    with {:ok, address_hash} <- Chain.string_to_address_hash(address_hash_string),
         {:ok, false} <- AccessHelpers.restricted_access?(address_hash_string, params),
         _ <- VerificationController.check_and_verify(address_hash_string),
         {:ok, address} <- Chain.find_contract_address(address_hash, address_options, true) do
      render(
        conn,
        "index.html",
        address: address,
        coin_balance_status: CoinBalanceOnDemand.trigger_fetch(address),
        exchange_rate: Market.get_exchange_rate(Explorer.coin()) || Token.null(),
        counters_path: address_path(conn, :address_counters, %{"id" => address_hash_string}),
        tags: get_address_tags(address_hash, current_user(conn)),
        ads_all: Ads.get_ads_by_type("all"),
        ads_address: Ads.get_ads_by_type("address")
      )
    else
      {:restricted_access, _} ->
        not_found(conn)

      :error ->
        not_found(conn)

      {:error, :not_found} ->
        not_found(conn)
    end
  end
end
