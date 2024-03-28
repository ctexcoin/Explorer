defmodule Explorer.Admin.Menu do
  @moduledoc """
  Represents a user with administrative privileges.
  """

  use Explorer.Schema

  import Ecto.Changeset

  alias Explorer.Admin.Menu
  alias Explorer.Repo
  alias Explorer.ThirdPartyIntegrations.AirTable

  @type t :: %Menu{
    title: String.t(),
    link: String.t(),
    type: String.t(),
    status: integer(),
    parent: integer(),
    order: integer(),
  }

  schema "menu" do
    field(:title, :string)
    field(:link, :string)
    field(:type, :string)
    field(:status, :integer)
    field(:parent, :integer)
    field(:order, :integer)
    timestamps()
  end

  @attrs ~w(link parent)a
  @required_attrs ~w(title type status order)a

  def changeset do
    %__MODULE__{}
    |> cast(%{}, @attrs ++ @required_attrs)
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @attrs ++ @required_attrs)
    |> validate_required(@required_attrs)
  end

  @spec create(:invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}) :: any
  def create(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
    |> Repo.account_repo().insert()
  end

  def get_list_menu(type) when not is_nil(type) do
    __MODULE__
    |> where([menu], menu.type == ^type)
    |> order_by([menu], desc: menu.id)
    |> Repo.account_repo().all()
    |> render_list_menu()
  end

  def get_list_menu(_), do: nil

  def render_list_menu(list) do
    if list != [] do
      Enum.map(list, fn x -> %{
        id: x.id,
        title: x.title,
        link: x.link,
        parent: x.parent,
        parent_name: get_parent_name(x.parent),
        status: x.status,
        order: x.order
      } end)
    end
  end

  def get_parent_name(id) when not is_nil(id) do
    menu = get_menu_by_id(id)
    if menu != nil do
      menu.title
    else
      nil
    end
  end

  def get_parent_name(_), do: nil

  def get_menu_by_id_query(id) when not is_nil(id) do
    __MODULE__
    |> where([menu], menu.id == ^id)
  end

  def get_menu_by_id_query(_), do: nil

  def get_menu_by_id(id) when not is_nil(id) do
    id |> get_menu_by_id_query() |> Repo.account_repo().one()
  end

  def get_menu_by_id(_), do: nil

  def update(%{id: id} = attrs) do
    with menu <- get_menu_by_id(id),
         false <- is_nil(menu),
         {:ok, changeset} <-
           menu |> changeset(Map.put(attrs, :request_type, "edit")) |> Repo.account_repo().update() do
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
    |> get_menu_by_id_query()
    |> Repo.account_repo().delete_all()
  end

  def delete(_), do: nil

  def get_menu_by_type_query(type) when not is_nil(type) do
    __MODULE__
    |> where([menu], menu.type == ^type and menu.status == 1)
    |> order_by([menu], fragment("RANDOM()"))
    |> limit(1)
  end

  def get_menu_by_type_query(_), do: nil

  def get_menu_by_type(type) when not is_nil(type) do
    type |> get_menu_by_type_query() |> Repo.account_repo().one()
  end

  def get_menu_by_type(_), do: nil

  def get_list_parent_by_option_query(id, type) when not is_nil(id) do
    __MODULE__
    |> where([menu], menu.type == ^type and menu.id != ^id)
    |> order_by([menu], asc: menu.order)
  end

  def get_list_parent_by_option_query(_, type) do
    __MODULE__
    |> where([menu], menu.type == ^type)
    |> order_by([menu], asc: menu.order)
  end

  def get_list_parent_by_option(id, type) when not is_nil(type) do
    id
    |> get_list_parent_by_option_query(type)
    |> Repo.account_repo().all()
  end

  def get_list_parent_by_option(_, _), do: nil

  def get_list_item_child(type, parent) when not is_nil(type) and not is_nil(parent) do
    __MODULE__
    |> where([menu], menu.type == ^type and menu.parent == ^parent and menu.status == 1)
    |> order_by([menu], asc: menu.order)
    |> Repo.account_repo().all()
    |> render_show_menu(type)
  end

  def get_list_item_child(_, _), do: nil

  def get_menu_show(type) when not is_nil(type) do
    __MODULE__
    |> where([menu], menu.type == ^type and is_nil(menu.parent) and menu.status == 1)
    |> order_by([menu], asc: menu.order)
    |> Repo.account_repo().all()
    |> render_show_menu(type)
  end

  def get_menu_show(_), do: nil

  def render_show_menu(list, type) do
    if list != [] do
      Enum.map(list, fn x -> %{
        id: x.id,
        title: x.title,
        link: x.link,
        list_child: get_list_item_child(type, x.id)
      } end)
    end
  end

end
