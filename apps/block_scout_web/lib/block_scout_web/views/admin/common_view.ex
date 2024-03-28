defmodule BlockScoutWeb.Admin.CommonView do
  use BlockScoutWeb, :view

  import BlockScoutWeb.AdminRouter.Helpers

  def nav_class(active_item, item) do
    if active_item == item do
      "dropdown-item active fs-14"
    else
      "dropdown-item fs-14"
    end
  end
end
