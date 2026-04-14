defmodule BackendWeb.SongLive.Show do
  use BackendWeb, :live_view

  alias Backend.Music

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Song Details")
     |> assign(:song, Music.get_song!(id))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_nav="songs">
      <section class="admin-hero admin-hero--compact">
        <div class="admin-hero__content">
          <span class="admin-kicker">Detail</span>
          <h2 class="admin-hero__title">{@song.title}</h2>
          <p class="admin-hero__subtitle">{@song.artist}</p>
        </div>

        <div class="admin-hero__actions">
          <.button navigate={~p"/admin/songs"} variant="secondary">
            <.icon name="hero-arrow-left" class="size-4" /> Danh sách
          </.button>
          <.button variant="primary" navigate={~p"/admin/songs/#{@song}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" class="size-4" /> Chỉnh sửa
          </.button>
        </div>
      </section>

      <section class="admin-grid admin-grid--details">
        <article class="admin-panel">
          <div class="section-heading">
            <div>
              <p class="section-kicker">Metadata</p>
              <h3 class="section-title">Thông tin chính</h3>
            </div>
          </div>

          <.list>
            <:item title="Title">{@song.title}</:item>
            <:item title="Artist">{@song.artist}</:item>
            <:item title="Energy"><.energy_badge value={@song.energy_level} /></:item>
            <:item title="Audio URL">
              <.link href={@song.audio_url} class="table-link" target="_blank" rel="noreferrer">
                Mở audio
              </.link>
            </:item>
            <:item title="Image URL">
              <.link href={@song.image_url} class="table-link" target="_blank" rel="noreferrer">
                Mở hình
              </.link>
            </:item>
            <:item title="Created">{format_datetime(@song.inserted_at)}</:item>
            <:item title="Updated">{format_datetime(@song.updated_at)}</:item>
          </.list>
        </article>

        <article class="admin-panel">
          <div class="section-heading">
            <div>
              <p class="section-kicker">Preview</p>
              <h3 class="section-title">Snapshot</h3>
            </div>
          </div>

          <div class="preview-card">
            <div class="preview-cover">
              <img :if={present?(@song.image_url)} src={@song.image_url} alt={@song.title} />
              <div :if={!present?(@song.image_url)} class="preview-cover__placeholder">
                {initials(@song.title, @song.artist)}
              </div>
            </div>

            <div class="song-row">
              <div>
                <p class="song-row__title">{@song.title}</p>
                <p class="song-row__meta">{@song.artist}</p>
              </div>
            </div>

            <div class="meta-section">
              <p class="meta-section__label">Semantic tags</p>
              <.tag_list items={@song.semantic_tags || []} empty="Chưa có tag" />
            </div>

            <div class="meta-section">
              <p class="meta-section__label">Search aliases</p>
              <.tag_list items={@song.search_aliases || []} empty="Chưa có alias" />
            </div>
          </div>
        </article>
      </section>
    </Layouts.app>
    """
  end

  defp format_datetime(nil), do: "-"

  defp format_datetime(datetime) do
    Calendar.strftime(datetime, "%d/%m/%Y %H:%M")
  end

  defp initials(title, artist) do
    [title || "", artist || ""]
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
    |> Enum.take(2)
    |> Enum.map(&String.first/1)
    |> Enum.reject(&is_nil/1)
    |> Enum.join()
    |> case do
      "" -> "SO"
      value -> String.upcase(value)
    end
  end

  defp present?(value) when is_binary(value), do: String.trim(value) != ""
  defp present?(nil), do: false
  defp present?(_value), do: true
end
