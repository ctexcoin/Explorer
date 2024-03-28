defmodule BlockScoutWeb.Admin.MenuFooterController do
  use BlockScoutWeb, :controller

  alias Ecto.Changeset
  alias Explorer.Admin.Menu

  def index(conn, _) do
    list_menu = Menu.get_list_menu("footer")
    render(conn, "index.html", list_menu: list_menu)
  end

  def new(conn, _params) do
    list_parent = Menu.get_list_parent_by_option(nil, "footer")
    render(conn, "form.html", method: :create, menu: new_menu(), list_parent: list_parent)
  end

  def create(conn, %{"menu" => menu}) do
    list_parent = Menu.get_list_parent_by_option(nil, "footer")
    case Menu.create(%{
            title: menu["title"],
            link: menu["link"],
            type: "footer",
            status: menu["status"],
            parent: menu["parent"],
            order: menu["order"]
          }) do
      {:ok, _} ->
        redirect(conn, to: AdminRoutes.menu_footer_path(conn, :index))

      {:error, invalid_menu} ->
        render(conn, "form.html", method: :create, menu: invalid_menu, list_parent: list_parent)
    end
  end

  def create(conn, _) do
    redirect(conn, to: AdminRoutes.menu_footer_path(conn, :index))
  end

  defp new_menu, do: Menu.changeset()

  def edit(conn, %{"id" => id}) do
    list_parent = Menu.get_list_parent_by_option(id, "footer")
    case Menu.get_menu_by_id(id) do
      nil ->
        not_found(conn)

      %Menu{} = menu ->
        render(conn, "form.html",
          method: :update,
          menu: Menu.changeset(menu),
          list_parent: list_parent
        )
    end
  end

  def update(conn, %{
    "id" => id,
    "menu" => menu
  }) do
    list_parent = Menu.get_list_parent_by_option(id, "footer")
    case Menu.update(%{
          id: id,
          title: menu["title"],
          link: menu["link"],
          type: "footer",
          status: menu["status"],
          parent: menu["parent"],
          order: menu["order"],
        }) do
      {:error, %Changeset{} = menu} ->
        render(conn, "form.html", method: :update, menu: menu, list_parent: list_parent)

      _ ->
        redirect(conn, to: AdminRoutes.menu_footer_path(conn, :index))
    end
  end

  def update(conn, _) do
    redirect(conn, to: AdminRoutes.menu_footer_path(conn, :index))
  end

  def delete(conn, %{"id" => id}) do
    Menu.delete(id)

    redirect(conn, to: AdminRoutes.menu_footer_path(conn, :index))
  end

end
