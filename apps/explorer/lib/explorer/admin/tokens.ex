defmodule Explorer.Admin.Tokens do
  @moduledoc """
     Module is responsible for requests for public tags
   """
   use Explorer.Schema

  import Ecto.{Changeset, Query}

  alias Ecto.Changeset
  alias Explorer.Chain.{Address, Hash, Token}
  alias Explorer.Repo
  alias Explorer.SmartContract.Helper

  @typedoc """
  * `name` - Name of the token
  * `symbol` - Trading symbol of the token
  * `total_supply` - The total supply of the token
  * `decimals` - Number of decimal places the token can be subdivided to
  * `type` - Type of token
  * `calatoged` - Flag for if token information has been cataloged
  * `contract_address` - The `t:Address.t/0` of the token's contract
  * `contract_address_hash` - Address hash foreign key
  * `holder_count` - the number of `t:Explorer.Chain.Address.t/0` (except the burn address) that have a
    `t:Explorer.Chain.CurrentTokenBalance.t/0` `value > 0`.  Can be `nil` when data not migrated.
  """
  @type t :: %Token{
          name: String.t(),
          symbol: String.t(),
          total_supply: Decimal.t(),
          decimals: non_neg_integer(),
          type: String.t(),
          cataloged: boolean(),
          contract_address: %Ecto.Association.NotLoaded{} | Address.t(),
          contract_address_hash: Hash.Address.t(),
          holder_count: non_neg_integer() | nil,
          skip_metadata: boolean()
        }

  @derive {Poison.Encoder,
           except: [
             :__meta__,
             :contract_address,
             :inserted_at,
             :updated_at
           ]}

  @derive {Jason.Encoder,
           except: [
             :__meta__,
             :contract_address,
             :inserted_at,
             :updated_at
           ]}

  @primary_key false
  schema "tokens" do
    field(:name, :string)
    field(:symbol, :string)
    field(:total_supply, :decimal)
    field(:decimals, :decimal)
    field(:type, :string)
    field(:cataloged, :boolean)
    field(:holder_count, :integer)
    field(:skip_metadata, :boolean)
    field(:sticked, :boolean)

    belongs_to(
      :contract_address,
      Address,
      foreign_key: :contract_address_hash,
      primary_key: true,
      references: :hash,
      type: Hash.Address
    )

    timestamps()
  end

  @required_attrs ~w(contract_address_hash type)a
  @optional_attrs ~w(cataloged decimals name symbol total_supply skip_metadata sticked)a

  def get_token_by_address_query(contract_address_hash) when not is_nil(contract_address_hash) do
    __MODULE__
    |> where([tokens], tokens.contract_address_hash == ^contract_address_hash)
  end

  def get_token_by_address_query(_), do: nil

  def get_token_by_address(contract_address_hash) when not is_nil(contract_address_hash) do
    contract_address_hash |> get_token_by_address_query() |> Repo.account_repo().one()
  end

  def get_token_by_address(_), do: nil

  def set_ticker(contract_address_hash) do
    with token <- get_token_by_address(contract_address_hash),
        false <- is_nil(token) do
          if token.sticked do
            token
              |> change(%{sticked: false})
              |> Repo.update()
          else
            token
              |> change(%{sticked: true})
              |> Repo.update()
          end
    else
      _ ->
        nil
    end
  end

 end
