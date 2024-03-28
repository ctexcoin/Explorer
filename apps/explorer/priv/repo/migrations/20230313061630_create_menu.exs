defmodule Explorer.Repo.Migrations.CreateMenu do
  use Ecto.Migration

  def change do
    create table(:menu) do
      add(:title, :string)
      add(:link, :string, null: true)
      add(:type, :string)
      add(:status, :integer)
      add(:parent, :integer, null: true)
      add(:order, :integer)
      timestamps()
    end
  end
end
