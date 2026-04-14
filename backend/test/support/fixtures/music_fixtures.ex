defmodule Backend.MusicFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Backend.Music` context.
  """

  @doc """
  Generate a song.
  """
  def song_fixture(attrs \\ %{}) do
    {:ok, song} =
      attrs
      |> Enum.into(%{
        artist: "The Weeknd",
        audio_url: "https://cdn.example.com/audio/blinding-lights.mp3",
        energy_level: 4,
        image_url: "https://cdn.example.com/images/blinding-lights.jpg",
        search_aliases: ["blinding lights", "weeknd"],
        semantic_tags: ["pop", "night-drive"],
        title: "Blinding Lights"
      })
      |> Backend.Music.create_song()

    song
  end
end
