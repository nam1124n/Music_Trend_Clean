defmodule Backend.Music do
  @moduledoc """
  The Music context.
  """

  import Ecto.Query, warn: false
  alias Backend.Repo

  alias Backend.Music.Song

  def song_energy_levels, do: Song.energy_levels()

  def song_energy_options do
    Enum.map(song_energy_levels(), fn level -> {"Mức #{level}", level} end)
  end

  @doc """
  Returns the list of songs.

  ## Examples

      iex> list_songs()
      [%Song{}, ...]

  """
  def list_songs(filters \\ %{}) do
    Song
    |> order_by([song], desc: song.inserted_at)
    |> maybe_filter_query(filters[:query] || filters["query"])
    |> maybe_filter_energy(filters[:energy_level] || filters["energy_level"])
    |> Repo.all()
  end

  @doc """
  Gets a single song.

  Raises `Ecto.NoResultsError` if the Song does not exist.

  ## Examples

      iex> get_song!(123)
      %Song{}

      iex> get_song!(456)
      ** (Ecto.NoResultsError)

  """
  def get_song!(id), do: Repo.get!(Song, id)

  def recent_songs(limit \\ 5) do
    Song
    |> order_by([song], desc: song.inserted_at)
    |> limit(^limit)
    |> Repo.all()
  end

  def count_songs do
    Repo.aggregate(Song, :count, :id)
  end

  def dashboard_summary do
    songs = Repo.all(Song)

    %{
      total_songs: length(songs),
      complete_songs: Enum.count(songs, &complete_song?/1),
      audio_ready_songs: Enum.count(songs, &present?(&1.audio_url)),
      image_ready_songs: Enum.count(songs, &present?(&1.image_url)),
      tagged_songs: Enum.count(songs, &Enum.any?(&1.semantic_tags || [])),
      searchable_songs: Enum.count(songs, &Enum.any?(&1.search_aliases || [])),
      average_energy_level: average_energy_level(songs)
    }
  end

  @doc """
  Creates a song.

  ## Examples

      iex> create_song(%{field: value})
      {:ok, %Song{}}

      iex> create_song(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_song(attrs) do
    %Song{}
    |> Song.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a song.

  ## Examples

      iex> update_song(song, %{field: new_value})
      {:ok, %Song{}}

      iex> update_song(song, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_song(%Song{} = song, attrs) do
    song
    |> Song.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a song.

  ## Examples

      iex> delete_song(song)
      {:ok, %Song{}}

      iex> delete_song(song)
      {:error, %Ecto.Changeset{}}

  """
  def delete_song(%Song{} = song) do
    Repo.delete(song)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking song changes.

  ## Examples

      iex> change_song(song)
      %Ecto.Changeset{data: %Song{}}

  """
  def change_song(%Song{} = song, attrs \\ %{}) do
    Song.changeset(song, attrs)
  end

  defp maybe_filter_query(query, nil), do: query
  defp maybe_filter_query(query, ""), do: query

  defp maybe_filter_query(query, search_term) do
    pattern = "%" <> String.downcase(String.trim(search_term)) <> "%"

    where(
      query,
      [song],
      like(fragment("lower(?)", song.title), ^pattern) or
        like(fragment("lower(?)", song.artist), ^pattern) or
        like(fragment("lower(coalesce(?, ''))", song.semantic_tags), ^pattern) or
        like(fragment("lower(coalesce(?, ''))", song.search_aliases), ^pattern)
    )
  end

  defp maybe_filter_energy(query, nil), do: query
  defp maybe_filter_energy(query, ""), do: query
  defp maybe_filter_energy(query, "all"), do: query

  defp maybe_filter_energy(query, energy_level) when is_binary(energy_level) do
    case Integer.parse(energy_level) do
      {parsed_level, ""} -> maybe_filter_energy(query, parsed_level)
      _ -> query
    end
  end

  defp maybe_filter_energy(query, energy_level) when energy_level in 1..5 do
    where(query, [song], song.energy_level == ^energy_level)
  end

  defp maybe_filter_energy(query, _energy_level), do: query

  defp average_energy_level([]), do: 0.0

  defp average_energy_level(songs) do
    songs
    |> Enum.map(& &1.energy_level)
    |> Enum.reject(&is_nil/1)
    |> case do
      [] ->
        0.0

      levels ->
        levels
        |> Enum.sum()
        |> Kernel./(length(levels))
        |> Float.round(1)
    end
  end

  defp complete_song?(song) do
    present?(song.audio_url) and
      present?(song.image_url) and
      Enum.any?(song.semantic_tags || []) and
      Enum.any?(song.search_aliases || [])
  end

  defp present?(value) do
    case value do
      nil -> false
      "" -> false
      value when is_binary(value) -> String.trim(value) != ""
      _ -> true
    end
  end
end
