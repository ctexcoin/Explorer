defmodule Explorer.Repo.Account.Migrations.CreateAdministratorsAds do
  use Ecto.Migration

  def change do
    create table(:administrators_ads) do
      add(:title, :string)
      add(:link, :string, null: true)
      add(:type, :string)
      add(:url_ads, :string, null: true)
      add(:content_ads, :text, null: true)
      add(:status, :integer)
      add(:user_id, references(:users, column: :id, on_delete: :delete_all), null: false)

      timestamps
    end
  end
end
