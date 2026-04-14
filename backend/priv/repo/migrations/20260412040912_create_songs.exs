defmodule Backend.Repo.Migrations.CreateSongs do
  use Ecto.Migration

  def change do
    create table(:songs) do
      add :title, :string, null: false
      add :artist, :string, null: false
      add :album, :string
      add :status, :string, default: "draft", null: false
      add :duration_seconds, :integer, null: false
      add :featured, :boolean, default: false, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:songs, [:status])
    create index(:songs, [:inserted_at])
  end
end
