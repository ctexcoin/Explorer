defmodule Explorer.Repo.Account.Migrations.TokensStick do
  use Ecto.Migration

  def change do
    alter table(:tokens) do
      add(:sticked, :boolean, default: false, null: false)
    end
  end
end
