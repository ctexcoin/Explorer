defmodule BlockScoutWeb.Admin.AdsController do
  use BlockScoutWeb, :controller

  alias Ecto.Changeset
  alias Explorer.Admin.Ads

  def index(conn, _) do
    render(conn, "index.html", list_ads: Ads.get_list_ads())
  end

  def new(conn, _params) do
    render(conn, "form.html", method: :create, ads: new_ads())
  end

  def create(conn, %{"ads" => ads}) do
    user_id = get_session(conn, :user_id)
    case Ads.create(%{
            title: ads["title"],
            link: ads["link"],
            type: ads["type"],
            url_ads: ads["url_ads"],
            content_ads: ads["content_ads"],
            status: ads["status"],
            user_id: user_id
          }) do
      {:ok, _} ->
        redirect(conn, to: AdminRoutes.ads_path(conn, :index))

      {:error, invalid_ads} ->
        render(conn, "form.html", method: :create, ads: invalid_ads)
    end
  end

  def create(conn, _) do
    redirect(conn, to: AdminRoutes.ads_path(conn, :index))
  end

  defp new_ads, do: Ads.changeset()

  def edit(conn, %{"id" => id}) do
    case Ads.get_ads_by_id(id) do
      nil ->
        not_found(conn)

      %Ads{} = ads ->
        render(conn, "form.html",
          method: :update,
          ads: Ads.changeset(ads)
        )
    end
  end

  def update(conn, %{
    "id" => id,
    "ads" => ads
  }) do

    case Ads.update(%{
          id: id,
          title: ads["title"],
          link: ads["link"],
          type: ads["type"],
          url_ads: ads["url_ads"],
          content_ads: ads["content_ads"],
          status: ads["status"]
        }) do
      {:error, %Changeset{} = ads} ->
        render(conn, "form.html", method: :update, ads: ads)

      _ ->
        redirect(conn, to: AdminRoutes.ads_path(conn, :index))
    end
  end

  def update(conn, _) do
    redirect(conn, to: AdminRoutes.ads_path(conn, :index))
  end

  def delete(conn, %{"id" => id}) do
    Ads.delete(id)

    redirect(conn, to: AdminRoutes.ads_path(conn, :index))
  end

end
