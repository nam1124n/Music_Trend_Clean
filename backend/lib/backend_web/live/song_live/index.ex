defmodule BackendWeb.SongLive.Index do
  use BackendWeb, :live_view

  alias Backend.Music

  @impl true
  def mount(_params, _session, socket) do
    filters = default_filters()

    {:ok,
     socket
     |> assign(:page_title, "Songs")
     |> assign_listing(filters)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_nav="songs">
      <section class="admin-hero admin-hero--compact">
        <div class="admin-hero__content">
          <span class="admin-kicker">Catalog</span>
          <h2 class="admin-hero__title">Song catalog</h2>
          <p class="admin-hero__subtitle">{@songs_count} bài hát trong thư viện.</p>
        </div>

        <div class="admin-hero__actions">
          <.button navigate={~p"/admin/songs/new"} variant="primary">
            <.icon name="hero-plus" class="size-4" /> Thêm bài hát
          </.button>
        </div>
      </section>

      <section class="metric-grid metric-grid--compact">
        <.metric_card
          label="Đủ metadata"
          value={@summary.complete_songs}
          icon="hero-check-badge"
          tone="success"
        />
        <.metric_card
          label="Có tags"
          value={@summary.tagged_songs}
          icon="hero-tag"
          tone="primary"
        />
        <.metric_card
          label="Có audio"
          value={@summary.audio_ready_songs}
          icon="hero-speaker-wave"
          tone="neutral"
        />
      </section>

      <section class="admin-panel">
        <.form
          for={@filter_form}
          id="song-filters"
          phx-change="filter"
          class="filter-grid filter-grid--minimal"
        >
          <.input
            field={@filter_form[:query]}
            type="text"
            label="Tìm kiếm"
            placeholder="Title, artist, tag, alias"
            phx-debounce="250"
          />
          <.input
            field={@filter_form[:energy_level]}
            type="select"
            label="Energy"
            options={energy_filter_options()}
          />

          <div class="filter-grid__actions">
            <.button type="button" phx-click="reset_filters" variant="ghost">Xóa lọc</.button>
          </div>
        </.form>

        <div :if={@songs_count == 0}>
          <.empty_state
            icon="hero-musical-note"
            title="Không có kết quả"
            subtitle="Thử đổi từ khóa hoặc thêm bài hát mới."
          />
        </div>

        <div :if={@songs_count > 0} class="admin-table-shell">
          <table class="admin-table">
            <thead>
              <tr>
                <th>Bài hát</th>
                <th>Tags</th>
                <th>Energy</th>
                <th>Assets</th>
                <th class="admin-table__actions-heading">Tác vụ</th>
              </tr>
            </thead>
            <tbody id="songs" phx-update="stream">
              <tr :for={{dom_id, song} <- @streams.songs} id={dom_id}>
                <td>
                  <div class="song-row">
                    <.song_avatar song={song} />
                    <div>
                      <p class="song-row__title">{song.title}</p>
                      <p class="song-row__meta">{song.artist}</p>
                    </div>
                  </div>
                </td>
                <td>
                  <.tag_list items={song.semantic_tags || []} empty="Chưa có tag" limit={2} />
                </td>
                <td>
                  <.energy_badge value={song.energy_level} />
                </td>
                <td>
                  <div class="asset-pills">
                    <.asset_pill label="Audio" active={present?(song.audio_url)} />
                    <.asset_pill label="Cover" active={present?(song.image_url)} />
                  </div>
                </td>
                <td class="admin-table__actions">
                  <div class="admin-table__action-links">
                    <.link navigate={~p"/admin/songs/#{song}"} class="table-link">View</.link>
                    <.link navigate={~p"/admin/songs/#{song}/edit"} class="table-link">Edit</.link>
                    <.link
                      phx-click="delete"
                      phx-value-id={song.id}
                      data-confirm="Xóa bài hát này?"
                      class="table-link table-link--danger"
                    >
                      Delete
                    </.link>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </section>
    </Layouts.app>
    """
  end

  @impl true
  def handle_event("filter", %{"filters" => filters}, socket) do
    {:noreply, assign_listing(socket, normalize_filters(filters))}
  end

  def handle_event("reset_filters", _params, socket) do
    {:noreply, assign_listing(socket, default_filters())}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    song = Music.get_song!(id)
    {:ok, _} = Music.delete_song(song)

    {:noreply,
     socket
     |> put_flash(:info, "Đã xóa bài hát")
     |> assign_listing(socket.assigns.filters)}
  end

  defp assign_listing(socket, filters) do
    songs = Music.list_songs(filters)

    socket
    |> assign(:filters, filters)
    |> assign(:filter_form, to_form(filters, as: :filters))
    |> assign(:songs_count, length(songs))
    |> assign(:summary, Music.dashboard_summary())
    |> stream(:songs, songs, reset: true)
  end

  defp default_filters do
    %{"query" => "", "energy_level" => "all"}
  end

  defp normalize_filters(filters) do
    %{
      "query" => String.trim(filters["query"] || ""),
      "energy_level" => filters["energy_level"] || "all"
    }
  end

  defp energy_filter_options do
    [
      {"Tất cả", "all"}
      | Enum.map(Music.song_energy_levels(), fn level ->
          {"Mức #{level}", Integer.to_string(level)}
        end)
    ]
  end

  defp present?(value) when is_binary(value), do: String.trim(value) != ""
  defp present?(nil), do: false
  defp present?(_value), do: true
end
