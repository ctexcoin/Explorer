defmodule BlockScoutWeb.Admin.TagsController do
  use BlockScoutWeb, :controller

  alias Ecto.Changeset
  alias Explorer.Admin.PublicTagsRequest

  def index(conn, _) do
    render(conn, "index.html", list_tags: PublicTagsRequest.get_all_public_tags_requests())
  end

  def edit(conn, %{"id" => id}) do
    case PublicTagsRequest.get_public_tags_requests_by_id(id) do
      nil ->
        not_found(conn)

      %PublicTagsRequest{} = public_tags_request ->
        render(conn, "form.html",
          method: :update,
          public_tags_request: PublicTagsRequest.changeset(public_tags_request)
        )
    end
  end

  def update(conn, %{
        "id" => id,
        "status" => status,
        "is_owner" => is_owner
      }) do

      if (is_owner == "true") do
        case PublicTagsRequest.create_new_tags(id) do
            :ok ->
              case PublicTagsRequest.update(%{
                id: id,
                status: status
              }) do
                {:error} ->
                  redirect(conn, to: AdminRoutes.tags_manager_path(conn, :edit, id))

                _ ->
                  redirect(conn, to: AdminRoutes.tags_manager_path(conn, :index))
              end

            {:error, %Changeset{} = id} ->
              redirect(conn, to: AdminRoutes.tags_manager_path(conn, :edit, id))
        end
      else
        case PublicTagsRequest.delete_public_to_tags(id) do
          :ok ->
            case PublicTagsRequest.update(%{
              id: id,
              status: status
            }) do
              {:error} ->
                redirect(conn, to: AdminRoutes.tags_manager_path(conn, :edit, id))

              _ ->
                redirect(conn, to: AdminRoutes.tags_manager_path(conn, :index))
            end

          {:error, %Changeset{} = id} ->
            redirect(conn, to: AdminRoutes.tags_manager_path(conn, :edit, id))
        end
      end
  end

  def update(conn, _) do
    redirect(conn, to: AdminRoutes.tags_manager_path(conn, :index))
  end

  def delete(conn, %{
        "id" => id
      }) do
      PublicTagsRequest.delete(id)
      redirect(conn, to: AdminRoutes.tags_manager_path(conn, :index))
  end

  def delete(conn, _) do
    redirect(conn, to: AdminRoutes.tags_manager_path(conn, :index))
  end

end
