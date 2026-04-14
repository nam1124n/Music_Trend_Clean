defmodule BackendWeb.SongLiveTest do
  use BackendWeb.ConnCase

  import Phoenix.LiveViewTest
  import Backend.MusicFixtures

  @create_attrs %{
    title: "Die For You",
    artist: "The Weeknd",
    audio_url: "https://cdn.example.com/audio/die-for-you.mp3",
    image_url: "https://cdn.example.com/images/die-for-you.jpg",
    semantic_tags: "r&b\nromantic",
    search_aliases: "die for you\nstarboy",
    energy_level: 3
  }

  @update_attrs %{
    title: "I Feel It Coming",
    artist: "The Weeknd",
    audio_url: "https://cdn.example.com/audio/i-feel-it-coming.mp3",
    image_url: "https://cdn.example.com/images/i-feel-it-coming.jpg",
    semantic_tags: "funk\nnight-drive",
    search_aliases: "i feel it coming\ndaft punk",
    energy_level: 4
  }

  @invalid_attrs %{
    title: nil,
    artist: nil,
    audio_url: nil,
    image_url: nil,
    semantic_tags: nil,
    search_aliases: nil,
    energy_level: ""
  }

  defp create_song(_) do
    song = song_fixture()
    %{song: song}
  end

  describe "Index" do
    setup [:create_song]

    test "lists all songs", %{conn: conn, song: song} do
      {:ok, _index_live, html} = live(conn, ~p"/admin/songs")

      assert html =~ "Song catalog"
      assert html =~ song.title
    end

    test "saves new song", %{conn: conn} do
      {:ok, form_live, _html} = live(conn, ~p"/admin/songs/new")

      assert render(form_live) =~ "Tạo bài hát"

      assert form_live
             |> form("#song-form", song: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#song-form", song: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/admin/songs")

      html = render(index_live)
      assert html =~ "Tạo bài hát thành công"
      assert html =~ "Die For You"
    end

    test "updates song in listing", %{conn: conn, song: song} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/songs")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#songs-#{song.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/admin/songs/#{song}/edit")

      assert render(form_live) =~ "Chỉnh sửa bài hát"

      assert form_live
             |> form("#song-form", song: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#song-form", song: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/admin/songs")

      html = render(index_live)
      assert html =~ "Cập nhật bài hát thành công"
      assert html =~ "I Feel It Coming"
    end

    test "deletes song in listing", %{conn: conn, song: song} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/songs")

      assert index_live |> element("#songs-#{song.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#songs-#{song.id}")
    end
  end

  describe "Show" do
    setup [:create_song]

    test "displays song", %{conn: conn, song: song} do
      {:ok, _show_live, html} = live(conn, ~p"/admin/songs/#{song}")

      assert html =~ "Metadata"
      assert html =~ song.title
    end

    test "updates song and returns to show", %{conn: conn, song: song} do
      {:ok, show_live, _html} = live(conn, ~p"/admin/songs/#{song}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Chỉnh sửa")
               |> render_click()
               |> follow_redirect(conn, ~p"/admin/songs/#{song}/edit?return_to=show")

      assert render(form_live) =~ "Chỉnh sửa bài hát"

      assert form_live
             |> form("#song-form", song: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#song-form", song: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/admin/songs/#{song}")

      html = render(show_live)
      assert html =~ "Cập nhật bài hát thành công"
      assert html =~ "I Feel It Coming"
    end
  end
end
