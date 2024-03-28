defmodule Explorer.Admin.PublicTagsRequest do
 @moduledoc """
    Module is responsible for requests for public tags
  """
  use Explorer.Schema

  alias Ecto.Changeset
  alias Explorer.Account.Identity
  alias Explorer.Chain.Hash
  alias Explorer.Repo

  alias Explorer.Tags.{AddressTag, AddressToTag}

  require Logger
  import Ecto.Changeset

  @distance_between_same_addresses 24 * 3600

  @max_public_tags_request_per_account 15
  @max_addresses_per_request 10
  @max_tags_per_request 2
  @max_tag_length 35

  schema("account_public_tags_requests") do
    field(:company, :string)
    field(:website, :string)
    field(:tags, :string)
    field(:addresses, {:array, Hash.Address})
    field(:description, :string)
    field(:additional_comment, :string)
    field(:request_type, :string)
    field(:is_owner, :boolean, default: true)
    field(:remove_reason, :string)
    field(:request_id, :string)
    field(:full_name, Explorer.Encrypted.Binary)
    field(:email, Explorer.Encrypted.Binary)
    belongs_to(:identity, Identity)
    field(:status, :integer, default: 0)

    timestamps()
  end

  @local_fields [:__meta__, :inserted_at, :updated_at, :id, :request_id]

  def to_map(%__MODULE__{} = request) do
    association_fields = request.__struct__.__schema__(:associations)
    waste_fields = association_fields ++ @local_fields

    network =
      Application.get_env(:block_scout_web, BlockScoutWeb.Endpoint)[:url][:host] <>
        Application.get_env(:block_scout_web, BlockScoutWeb.Endpoint)[:url][:path]

    request |> Map.from_struct() |> Map.drop(waste_fields) |> Map.put(:network, network)
  end
  @attrs ~w(company website description remove_reason request_id full_name email tags addresses additional_comment request_type is_owner identity_id status)a
  # @required_attrs ~w(status)a

  def changeset do
    %__MODULE__{}
    |> cast(%{}, @attrs)
  end

  @doc false
  def changeset(public_tags_request, params \\ %{}) do
    public_tags_request
    |> cast(params, @attrs)
  end


  defp trim_empty_addresses(%{addresses: addresses} = attrs) when is_list(addresses) do
    filtered_addresses = Enum.filter(addresses, fn addr -> addr != "" and !is_nil(addr) end)
    Map.put(attrs, :addresses, if(filtered_addresses == [], do: [""], else: filtered_addresses))
  end

  defp trim_empty_addresses(attrs), do: attrs

  def get_all_public_tags_requests() do
    __MODULE__
    |> order_by([request], desc: request.id)
    |> Repo.account_repo().all()
  end

  def get_all_public_tags_requests(_), do: nil

  def get_public_tags_requests_by_id_query(id) when not is_nil(id) do
    __MODULE__
    |> where([public_tags_requests], public_tags_requests.id == ^id)
  end

  def get_public_tags_requests_by_id_query(_), do: nil

  def get_public_tags_requests_by_id(id) when not is_nil(id) do
    id |> get_public_tags_requests_by_id_query() |> Repo.account_repo().one()
  end

  def get_public_tags_requests_by_id(_), do: nil

  def update(%{id: id} = attrs) do
    with tag <- get_public_tags_requests_by_id(id),
         false <- is_nil(tag) do
          tag  |> changeset(attrs) |> Repo.account_repo().update()
    else
      true ->
        {:error, %{reason: :item_not_found}}

      other ->
        other
    end
  end

  def create_new_tags(id) do
    with tag <- get_public_tags_requests_by_id(id),
         false <- is_nil(tag),
         tag_addresses <- tag.addresses,
         tags_list <- String.split(tag.tags, ";") do

         tags_list
         |> Enum.each(fn tag_name ->
            tag_id = AddressTag.get_tag_id(tag_name)
            # Logger.info("--- exits_tags -------------#{tag_id}")
            if tag_id do
              tag_addresses
              |> Enum.each(fn address ->
                  # Logger.info("--- exits_tags tag_addresses -------------#{address}")
                  AddressToTag.set_addresses_to_tag(tag_id, address)
              end)
            else
              AddressTag.set_tag(tag_name, tag_name)
              tag_id = AddressTag.get_tag_id(tag_name)
              # Logger.info("--- create_new_tags -------------#{tag_id}")
              tag_addresses
              |> Enum.each(fn address ->
                  # Logger.info("--- create_new_tags tag_addresses -------------#{address}")
                  AddressToTag.set_addresses_to_tag(tag_id, address)
              end)
            end
         end)
    else
      true ->
        {:error, %{reason: :item_not_found}}

      other ->
        other
    end

  end

  def delete_public_to_tags(id) do
    with tag <- get_public_tags_requests_by_id(id),
         false <- is_nil(tag),
         tag_addresses <- tag.addresses,
         tags_list <- String.split(tag.tags, ";") do

         tags_list
         |> Enum.each(fn tag_name ->
            tag_id = AddressTag.get_tag_id(tag_name)
            # Logger.info("--- exits_tags -------------#{tag_id}")
            if tag_id do
              tag_addresses
              |> Enum.each(fn address ->
                  # Logger.info("--- exits_tags tag_addresses -------------#{address}")
                  AddressToTag.delete_addresses_to_tag(tag_id, address)
              end)
            end
         end)
    else
      true ->
        {:error, %{reason: :item_not_found}}

      other ->
        other
    end

  end

  def delete_public_to_tags(_), do: nil

  def delete(id) when not is_nil(id) do
    delete_public_to_tags(id)
    id
    |> get_public_tags_requests_by_id_query()
    |> Repo.account_repo().delete_all()
  end

  def delete(_), do: nil
end
