defmodule BlockScoutWeb.Admin.TokensManagerController do
  use BlockScoutWeb, :controller

  import BlockScoutWeb.Chain,
    only: [paging_options: 1, next_page_params: 3, split_list_by_page: 1, fetch_page_number: 1]


  alias BlockScoutWeb.{Controller}
  alias BlockScoutWeb.Admin.TokensManagerView
  alias Explorer.Admin.Tokens
  alias Explorer.{Chain}
  alias Phoenix.View
  require Logger


  def index(conn, %{"type" => "JSON"} = params) do
    filter =
      if Map.has_key?(params, "filter") do
        Map.get(params, "filter")
      else
        nil
      end

    paging_params =
      params
      |> paging_options()

    tokens = Chain.list_top_tokens(filter, paging_params)

    {tokens_page, next_page} = split_list_by_page(tokens)

    next_page_path =
      case next_page_params(next_page, tokens_page, params) do
        nil ->
          nil

        next_page_params ->
          AdminRoutes.tokens_manager_path(
            conn,
            :index,
            Map.delete(next_page_params, "type")
          )
      end

    items_count_str = Map.get(params, "items_count")

    items_count =
      if items_count_str do
        {items_count, _} = Integer.parse(items_count_str)
        items_count
      else
        0
      end

    items =
      tokens_page
      |> Enum.with_index(1)
      |> Enum.map(fn {token, index} ->
        View.render_to_string(
          TokensManagerView,
          "_tile.html",
          token: token,
          index: items_count + index,
          # tokens_manager_path: AdminRoutes.tokens_manager_path(conn, :update, token.contract_address_hash),
          token_tick_path: AdminRoutes.tokens_manager_updatetick_path(conn, :updatetick, token.contract_address_hash),
          conn: conn
        )
      end)

    json(
      conn,
      %{
        items: items,
        next_page_path: next_page_path
      }
    )
  end

  def index(conn, _params) do
    render(conn, "index.html", current_path: Controller.current_full_path(conn))
  end

  def update(conn, %{
    "contract_address_hash" => contract_address_hash,
    "sticked" => sticked,
  }) do

    Logger.info("--- contract_address_hash -------------#{contract_address_hash} ---------sticked----- #{sticked}")
    redirect(conn, to: AdminRoutes.current_full_path(conn, :index))
  end

  def update(conn, _) do
    render(conn, "index.html", current_path: Controller.current_full_path(conn))
  end

  def updatetick(conn, %{
    "tokens_manager_id" => tokens_manager_id
  }) do

    Logger.info("--- updatetick -------------#{tokens_manager_id}")
    Tokens.set_ticker(tokens_manager_id)
    case Tokens.get_token_by_address(tokens_manager_id) do
      nil ->
        json(
          conn,
          %{
            success: false,
            msg: "Not found contract address"
          }
        )

      %Tokens{} = token ->
        json(
          conn,
          %{
            success: true,
            contract_address: token.contract_address_hash,
            sticked: token.sticked,
          }
        )
    end
    # token = Tokens.get_token_by_address(tokens_manager_id)
    # json(
    #   conn,
    #   %{
    #     success: true,
    #     contract_address: token.contract_address,
    #     sticked: token.sticked,
    #   }
    # )
  end

  def updatetick(conn, _) do
    Logger.info("--- updatetick ---")
    json(
      conn,
      %{
        success: false,
        msg: "Invalid contract address"
      }
    )
  end

end
