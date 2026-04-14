defmodule Backend.Music.Song do
  use Ecto.Schema
  import Ecto.Changeset

  @energy_levels Enum.to_list(1..5)

  def energy_levels, do: @energy_levels

  schema "songs" do
    field :title, :string
    field :artist, :string
    field :audio_url, :string
    field :image_url, :string
    field :semantic_tags, {:array, :string}, default: []
    field :search_aliases, {:array, :string}, default: []
    field :energy_level, :integer, default: 3

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(song, attrs) do
    attrs = normalize_attrs(attrs)

    song
    |> cast(attrs, [
      :title,
      :artist,
      :audio_url,
      :image_url,
      :semantic_tags,
      :search_aliases,
      :energy_level
    ])
    |> update_change(:title, &normalize_text/1)
    |> update_change(:artist, &normalize_text/1)
    |> update_change(:audio_url, &normalize_text/1)
    |> update_change(:image_url, &normalize_text/1)
    |> update_change(:semantic_tags, &normalize_list/1)
    |> update_change(:search_aliases, &normalize_list/1)
    |> validate_required([:title, :artist, :audio_url, :image_url, :energy_level])
    |> validate_length(:title, min: 2, max: 120)
    |> validate_length(:artist, min: 2, max: 80)
    |> validate_length(:audio_url, min: 8, max: 500)
    |> validate_length(:image_url, min: 8, max: 500)
    |> validate_length(:semantic_tags, max: 12)
    |> validate_length(:search_aliases, max: 12)
    |> validate_number(:energy_level, greater_than_or_equal_to: 1, less_than_or_equal_to: 5)
    |> validate_inclusion(:energy_level, @energy_levels)
  end

  defp normalize_text(nil), do: nil
  defp normalize_text(value), do: String.trim(value)

  defp normalize_list(nil), do: []

  defp normalize_list(values) when is_list(values) do
    values
    |> Enum.map(&normalize_text/1)
    |> Enum.reject(&(&1 in [nil, ""]))
    |> Enum.uniq()
  end

  defp normalize_list(value) when is_binary(value) do
    value
    |> split_multiline_list()
    |> normalize_list()
  end

  defp normalize_list(_value), do: []

  defp normalize_attrs(attrs) when is_map(attrs) do
    attrs
    |> rename_key("audioUrl", "audio_url")
    |> rename_key("imageUrl", "image_url")
    |> rename_key("semanticTags", "semantic_tags")
    |> rename_key("searchAliases", "search_aliases")
    |> rename_key("energyLevel", "energy_level")
    |> rename_key(:audioUrl, :audio_url)
    |> rename_key(:imageUrl, :image_url)
    |> rename_key(:semanticTags, :semantic_tags)
    |> rename_key(:searchAliases, :search_aliases)
    |> rename_key(:energyLevel, :energy_level)
    |> normalize_list_param("semantic_tags")
    |> normalize_list_param("search_aliases")
    |> normalize_list_param(:semantic_tags)
    |> normalize_list_param(:search_aliases)
  end

  defp normalize_attrs(attrs), do: attrs

  defp rename_key(attrs, old_key, new_key) do
    cond do
      not Map.has_key?(attrs, old_key) ->
        attrs

      Map.has_key?(attrs, new_key) ->
        Map.delete(attrs, old_key)

      true ->
        attrs
        |> Map.put(new_key, Map.get(attrs, old_key))
        |> Map.delete(old_key)
    end
  end

  defp normalize_list_param(attrs, key) do
    if Map.has_key?(attrs, key) do
      Map.update!(attrs, key, &normalize_list/1)
    else
      attrs
    end
  end

  defp split_multiline_list(value) do
    value
    |> String.split(~r/[\n,]/, trim: true)
    |> Enum.map(&String.trim/1)
  end
end
