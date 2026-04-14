defmodule Backend.MusicTest do
  use Backend.DataCase

  alias Backend.Music

  describe "songs" do
    alias Backend.Music.Song

    import Backend.MusicFixtures

    @invalid_attrs %{
      title: nil,
      artist: nil,
      audio_url: nil,
      image_url: nil,
      semantic_tags: nil,
      search_aliases: nil,
      energy_level: nil
    }

    test "list_songs/0 returns all songs" do
      song = song_fixture()
      assert Music.list_songs() == [song]
    end

    test "get_song!/1 returns the song with given id" do
      song = song_fixture()
      assert Music.get_song!(song.id) == song
    end

    test "create_song/1 with valid data creates a song" do
      valid_attrs = %{
        title: "Starboy",
        artist: "The Weeknd",
        audio_url: "https://cdn.example.com/audio/starboy.mp3",
        image_url: "https://cdn.example.com/images/starboy.jpg",
        semantic_tags: ["dark-pop", "anthem"],
        search_aliases: ["starboy", "the weeknd"],
        energy_level: 5
      }

      assert {:ok, %Song{} = song} = Music.create_song(valid_attrs)
      assert song.title == "Starboy"
      assert song.artist == "The Weeknd"
      assert song.audio_url == "https://cdn.example.com/audio/starboy.mp3"
      assert song.image_url == "https://cdn.example.com/images/starboy.jpg"
      assert song.semantic_tags == ["dark-pop", "anthem"]
      assert song.search_aliases == ["starboy", "the weeknd"]
      assert song.energy_level == 5
    end

    test "create_song/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Music.create_song(@invalid_attrs)
    end

    test "update_song/2 with valid data updates the song" do
      song = song_fixture()

      update_attrs = %{
        title: "Save Your Tears",
        artist: "The Weeknd",
        audio_url: "https://cdn.example.com/audio/save-your-tears.mp3",
        image_url: "https://cdn.example.com/images/save-your-tears.jpg",
        semantic_tags: ["retro-pop"],
        search_aliases: ["save your tears", "weeknd"],
        energy_level: 3
      }

      assert {:ok, %Song{} = song} = Music.update_song(song, update_attrs)
      assert song.title == "Save Your Tears"
      assert song.artist == "The Weeknd"
      assert song.audio_url == "https://cdn.example.com/audio/save-your-tears.mp3"
      assert song.image_url == "https://cdn.example.com/images/save-your-tears.jpg"
      assert song.semantic_tags == ["retro-pop"]
      assert song.search_aliases == ["save your tears", "weeknd"]
      assert song.energy_level == 3
    end

    test "update_song/2 with invalid data returns error changeset" do
      song = song_fixture()
      assert {:error, %Ecto.Changeset{}} = Music.update_song(song, @invalid_attrs)
      assert song == Music.get_song!(song.id)
    end

    test "delete_song/1 deletes the song" do
      song = song_fixture()
      assert {:ok, %Song{}} = Music.delete_song(song)
      assert_raise Ecto.NoResultsError, fn -> Music.get_song!(song.id) end
    end

    test "change_song/1 returns a song changeset" do
      song = song_fixture()
      assert %Ecto.Changeset{} = Music.change_song(song)
    end

    test "dashboard_summary/0 returns aggregate stats" do
      song_fixture()

      song_fixture(%{
        title: "Less Than Zero",
        audio_url: "https://cdn.example.com/audio/less-than-zero.mp3",
        image_url: "https://cdn.example.com/images/less-than-zero.jpg",
        semantic_tags: [],
        search_aliases: [],
        energy_level: 2
      })

      summary = Music.dashboard_summary()

      assert summary.total_songs == 2
      assert summary.complete_songs == 1
      assert summary.audio_ready_songs == 2
      assert summary.image_ready_songs == 2
      assert summary.tagged_songs == 1
      assert summary.searchable_songs == 1
      assert summary.average_energy_level == 3.0
    end
  end
end
