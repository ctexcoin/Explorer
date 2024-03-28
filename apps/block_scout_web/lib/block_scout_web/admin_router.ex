defmodule BlockScoutWeb.AdminRouter do
  @moduledoc """
  Router for admin pages.
  """

  use BlockScoutWeb, :router

  alias BlockScoutWeb.Plug.FetchUserFromSession
  alias BlockScoutWeb.Plug.Admin.{CheckOwnerRegistered, RequireAdminRole}

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(BlockScoutWeb.CSPHeader)
  end

  pipeline :check_configured do
    plug(CheckOwnerRegistered)
  end

  pipeline :ensure_admin do
    plug(FetchUserFromSession)
    plug(RequireAdminRole)
  end

  scope "/setup", BlockScoutWeb.Admin do
    pipe_through([:browser])

    get("/", SetupController, :configure)
    post("/", SetupController, :configure_admin)
  end

  scope "/login", BlockScoutWeb.Admin do
    pipe_through([:browser, :check_configured])

    get("/", SessionController, :new)
    post("/", SessionController, :create)
  end

  scope "/logout", BlockScoutWeb.Admin do
    pipe_through([:browser, :check_configured])

    get("/", SessionController, :logout)
  end

  scope "/", BlockScoutWeb.Admin do
    pipe_through([:browser, :check_configured, :ensure_admin])

    get("/", DashboardController, :index)

    scope "/tasks" do
      get("/create_contract_methods", TaskController, :create_contract_methods, as: :create_contract_methods)
    end

    resources("/ads", AdsController,
      only: [:index, :new, :create, :delete, :edit, :update],
      as: :ads
    )

    resources("/menu_hearder", MenuHeaderController,
      only: [:index, :new, :create, :delete, :edit, :update],
      as: :menu_header
    )

    resources("/menu_footer", MenuFooterController,
      only: [:index, :new, :create, :delete, :edit, :update],
      as: :menu_footer
    )

    resources("/tags_manager", TagsController,
      only: [:index, :edit, :update, :delete],
      as: :tags_manager
    )

    resources("/tokens_manager", TokensManagerController,
      only: [:index, :edit, :update],
      as: :tokens_manager
    ) do
      post("/updatetick", TokensManagerController, :updatetick, as: :updatetick)
    end
  end
end
