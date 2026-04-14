defmodule BackendWeb.AdminDashboardLive do
  use BackendWeb, :live_view

  alias Backend.Music

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Admin Dashboard")
     |> assign(:summary, Music.dashboard_summary())
     |> assign(:recent_songs, Music.recent_songs(6))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_nav="dashboard">
      <section class="admin-hero">
        <div class="admin-hero__content">
          <span class="admin-kicker">Overview</span>
          <h2 class="admin-hero__title">Song metadata cho app Flutter.</h2>
          <p class="admin-hero__subtitle">Gọn, rõ và tập trung vào dữ liệu cần dùng.</p>
        </div>

        <div class="admin-hero__actions">
          <.button navigate={~p"/admin/songs/new"} variant="primary">
            <.icon name="hero-plus" class="size-4" /> Thêm bài hát
          </.button>
          <.button navigate={~p"/admin/songs"} variant="secondary">Mở catalog</.button>
        </div>
      </section>

      <section class="metric-grid">
        <.metric_card
          label="Tổng bài hát"
          value={@summary.total_songs}
          icon="hero-musical-note"
          tone="primary"
          hint="Tất cả bản ghi"
        />
        <.metric_card
          label="Đủ metadata"
          value={@summary.complete_songs}
          icon="hero-check-badge"
          tone="success"
          hint="Audio, cover, tags, aliases"
        />
        <.metric_card
          label="Có cover"
          value={@summary.image_ready_songs}
          icon="hero-photo"
          tone="neutral"
          hint="Image URL đã nhập"
        />
        <.metric_card
          label="Có alias"
          value={@summary.searchable_songs}
          icon="hero-magnifying-glass"
          tone="warning"
          hint="Tìm kiếm tốt hơn"
        />
      </section>

      <section class="admin-grid admin-grid--dashboard">
        <article class="admin-panel">
          <div class="section-heading">
            <div>
              <p class="section-kicker">Recent</p>
              <h3 class="section-title">Mới cập nhật</h3>
            </div>
            <.link navigate={~p"/admin/songs"} class="section-link">Xem tất cả</.link>
          </div>

          <div :if={@recent_songs == []}>
            <.empty_state
              icon="hero-musical-note"
              title="Chưa có bài hát"
              subtitle="Thêm bài hát đầu tiên để bắt đầu."
            />
          </div>

          <div :if={@recent_songs != []} class="stack-list">
            <article :for={song <- @recent_songs} class="stack-list__row">
              <div class="stack-list__lead">
                <.song_avatar song={song} />
                <div>
                  <p class="stack-list__title">{song.title}</p>
                  <p class="stack-list__meta">{song.artist}</p>
                </div>
              </div>

              <div class="stack-list__tail">
                <.energy_badge value={song.energy_level} />
                <.link navigate={~p"/admin/songs/#{song}"} class="table-link">Chi tiết</.link>
              </div>
            </article>
          </div>
        </article>

        <article class="admin-panel">
          <div class="section-heading">
            <div>
              <p class="section-kicker">Health</p>
              <h3 class="section-title">Tình trạng metadata</h3>
            </div>
          </div>

          <div class="insight-list">
            <div class="insight-row">
              <span>Có audio URL</span>
              <strong>{@summary.audio_ready_songs}</strong>
            </div>
            <div class="insight-row">
              <span>Có image URL</span>
              <strong>{@summary.image_ready_songs}</strong>
            </div>
            <div class="insight-row">
              <span>Có semantic tags</span>
              <strong>{@summary.tagged_songs}</strong>
            </div>
            <div class="insight-row">
              <span>Năng lượng trung bình</span>
              <strong>{format_energy(@summary.average_energy_level)}</strong>
            </div>
          </div>
        </article>
      </section>
    </Layouts.app>
    """
  end

  defp format_energy(value) when is_float(value), do: :erlang.float_to_binary(value, decimals: 1)
  defp format_energy(value) when is_integer(value), do: Integer.to_string(value)
  defp format_energy(_value), do: "0.0"
end
