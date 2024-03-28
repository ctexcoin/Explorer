defmodule Explorer.Admin.Ads do
  @moduledoc """
  Represents a user with administrative privileges.
  """

  use Explorer.Schema

  import Ecto.Changeset

  alias Explorer.Accounts.User
  alias Explorer.Admin.Ads
  alias Explorer.Repo
  alias Explorer.ThirdPartyIntegrations.AirTable

  @type t :: %Ads{
    title: String.t(),
    link: String.t(),
    type: String.t(),
    url_ads: String.t(),
    content_ads: String.t(),
    status: integer(),
    user: User.t() | %Ecto.Association.NotLoaded{}
  }

  schema "administrators_ads" do
    field(:title, :string)
    field(:link, :string)
    field(:type, :string)
    field(:url_ads, :string)
    field(:content_ads, :string)
    field(:status, :integer)
    belongs_to(:user, User)

    timestamps()
  end

  @attrs ~w(link url_ads content_ads)a
  @required_attrs ~w(title type status user_id)a

  def changeset do
    %__MODULE__{}
    |> cast(%{}, @attrs ++ @required_attrs)
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @attrs ++ @required_attrs)
    |> validate_required(@required_attrs)
    |> assoc_constraint(:user)
  end

  @spec create(:invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}) :: any
  def create(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
    |> Repo.account_repo().insert()
  end

  def get_list_ads() do
    __MODULE__
    |> order_by([ads], desc: ads.id)
    |> Repo.account_repo().all()
  end

  def get_list_ads(_), do: nil

  def get_ads_by_id_query(id) when not is_nil(id) do
    __MODULE__
    |> where([ads], ads.id == ^id)
  end

  def get_ads_by_id_query(_), do: nil

  def get_ads_by_id(id) when not is_nil(id) do
    id |> get_ads_by_id_query() |> Repo.account_repo().one()
  end

  def get_ads_by_id(_), do: nil

  def update(%{id: id} = attrs) do
    with ads <- get_ads_by_id(id),
         false <- is_nil(ads),
         {:ok, changeset} <-
           ads |> changeset(Map.put(attrs, :request_type, "edit")) |> Repo.account_repo().update() do
      AirTable.submit({:ok, changeset})
    else
      true ->
        {:error, %{reason: :item_not_found}}

      other ->
        other
    end
  end

  def delete(id) when not is_nil(id) do
    id
    |> get_ads_by_id_query()
    |> Repo.account_repo().delete_all()
  end

  def delete(_), do: nil

  def get_ads_by_type_query(type) when not is_nil(type) do
    __MODULE__
    |> where([ads], ads.type == ^type and ads.status == 1)
    |> order_by([ads], fragment("RANDOM()"))
    |> limit(1)
  end

  def get_ads_by_type_query(_), do: nil

  def get_ads_by_type(type) when not is_nil(type) do
    type |> get_ads_by_type_query() |> Repo.account_repo().one()
  end

  def get_ads_by_type(_), do: nil

end
