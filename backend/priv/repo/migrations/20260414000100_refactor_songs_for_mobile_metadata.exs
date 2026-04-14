defmodule Backend.Repo.Migrations.RefactorSongsForMobileMetadata do
  use Ecto.Migration

  def up do
    columns =
      repo().query!("PRAGMA table_info(songs)").rows
      |> Enum.map(fn [_cid, name | _rest] -> name end)
      |> MapSet.new()

    execute("DROP INDEX IF EXISTS songs_status_index")
    execute("DROP TABLE IF EXISTS songs_new")

    execute("""
    CREATE TABLE songs_new (
      id INTEGER PRIMARY KEY,
      title TEXT,
      artist TEXT,
      audio_url TEXT NOT NULL DEFAULT '',
      image_url TEXT NOT NULL DEFAULT '',
      semantic_tags TEXT NOT NULL DEFAULT '[]',
      search_aliases TEXT NOT NULL DEFAULT '[]',
      energy_level INTEGER NOT NULL DEFAULT 3,
      inserted_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )
    """)

    execute(copy_sql(columns))
    execute("DROP TABLE songs")
    execute("ALTER TABLE songs_new RENAME TO songs")
  end

  def down do
    execute("DROP TABLE IF EXISTS songs_old")

    execute("""
    CREATE TABLE songs_old (
      id INTEGER PRIMARY KEY,
      title TEXT,
      artist TEXT,
      album TEXT,
      status TEXT NOT NULL DEFAULT 'draft',
      duration_seconds INTEGER NOT NULL DEFAULT 180,
      featured INTEGER NOT NULL DEFAULT 0,
      inserted_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )
    """)

    execute("""
    INSERT INTO songs_old (
      id,
      title,
      artist,
      album,
      status,
      duration_seconds,
      featured,
      inserted_at,
      updated_at
    )
    SELECT
      id,
      title,
      artist,
      '',
      'draft',
      180,
      CASE WHEN energy_level >= 4 THEN 1 ELSE 0 END,
      inserted_at,
      updated_at
    FROM songs
    """)

    execute("DROP TABLE songs")
    execute("ALTER TABLE songs_old RENAME TO songs")
    create(index(:songs, [:status]))
  end

  defp copy_sql(columns) do
    if MapSet.member?(columns, "audio_url") do
      """
      INSERT INTO songs_new (
        id,
        title,
        artist,
        audio_url,
        image_url,
        semantic_tags,
        search_aliases,
        energy_level,
        inserted_at,
        updated_at
      )
      SELECT
        id,
        title,
        artist,
        COALESCE(NULLIF(audio_url, ''), 'https://cdn.example.com/audio/' || lower(replace(replace(title, ' ', '-'), ',', '')) || '.mp3'),
        COALESCE(NULLIF(image_url, ''), 'https://cdn.example.com/images/' || lower(replace(replace(title, ' ', '-'), ',', '')) || '.jpg'),
        COALESCE(NULLIF(semantic_tags, ''), json_array(lower(replace(artist, ' ', '-')), lower(replace(title, ' ', '-')))),
        COALESCE(NULLIF(search_aliases, ''), json_array(title, artist)),
        COALESCE(energy_level, 3),
        inserted_at,
        updated_at
      FROM songs
      """
    else
      """
      INSERT INTO songs_new (
        id,
        title,
        artist,
        audio_url,
        image_url,
        semantic_tags,
        search_aliases,
        energy_level,
        inserted_at,
        updated_at
      )
      SELECT
        id,
        title,
        artist,
        'https://cdn.example.com/audio/' || lower(replace(replace(title, ' ', '-'), ',', '')) || '.mp3',
        'https://cdn.example.com/images/' || lower(replace(replace(title, ' ', '-'), ',', '')) || '.jpg',
        json_array(lower(replace(artist, ' ', '-')), lower(replace(title, ' ', '-'))),
        json_array(title, artist, coalesce(album, '')),
        CASE WHEN featured = 1 THEN 4 ELSE 3 END,
        inserted_at,
        updated_at
      FROM songs
      """
    end
  end
end
