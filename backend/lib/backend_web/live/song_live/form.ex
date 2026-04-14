defmodule BackendWeb.SongLive.Form do
  use BackendWeb, :live_view

  alias Backend.Music
  alias Backend.Music.Song

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> assign(:energy_options, Music.song_energy_options())
     |> apply_action(socket.assigns.live_action, params)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_nav="songs">
      <section class="admin-hero admin-hero--compact">
        <div class="admin-hero__content">
          <span class="admin-kicker">Editor</span>
          <h2 class="admin-hero__title">{@page_title}</h2>
          <p class="admin-hero__subtitle">Một form duy nhất cho metadata app.</p>
        </div>

        <div class="admin-hero__actions">
          <.button navigate={return_path(@return_to, @song)} variant="secondary">Quay lại</.button>
        </div>
      </section>

      <section class="admin-grid admin-grid--form">
        <article class="admin-panel">
          <.header>
            Metadata
            <:subtitle>Giữ dữ liệu gọn, rõ và đúng với model mobile.</:subtitle>
          </.header>

          <.form for={@form} id="song-form" phx-change="validate" phx-submit="save" class="song-form">
            <div class="song-form__grid">
              <.input
                field={@form[:title]}
                type="text"
                label="Title"
                placeholder="Ví dụ: Blinding Lights"
              />
              <.input
                field={@form[:artist]}
                type="text"
                label="Artist"
                placeholder="Ví dụ: The Weeknd"
              />
              <.input
                field={@form[:audio_url]}
                type="url"
                label="Audio URL"
                placeholder="https://..."
              />
              <.input
                field={@form[:image_url]}
                type="url"
                label="Image URL"
                placeholder="https://..."
              />
              <.input
                field={@form[:energy_level]}
                type="select"
                label="Energy level"
                options={@energy_options}
                prompt="Chọn mức năng lượng"
              />
            </div>

            <div class="song-form__stack">
              <.input
                field={@form[:semantic_tags]}
                type="textarea"
                label="Semantic tags"
                value={textarea_value(@form, :semantic_tags)}
                placeholder="Mỗi dòng hoặc mỗi dấu phẩy là một tag"
              />
              <.input
                field={@form[:search_aliases]}
                type="textarea"
                label="Search aliases"
                value={textarea_value(@form, :search_aliases)}
                placeholder="Tên khác, từ khóa, alias tìm kiếm"
              />
            </div>

            <footer class="form-actions">
              <.button phx-disable-with="Đang lưu..." variant="primary">Lưu bài hát</.button>
              <.button navigate={return_path(@return_to, @song)} variant="ghost">Hủy</.button>
            </footer>
          </.form>
        </article>

        <aside class="admin-panel">
          <div class="section-heading">
            <div>
              <p class="section-kicker">Preview</p>
              <h3 class="section-title">Xem nhanh</h3>
            </div>
          </div>

          <div class="preview-card">
            <div class="preview-cover">
              <img
                :if={present?(preview_value(@form, :image_url, nil))}
                src={preview_value(@form, :image_url, nil)}
                alt="Preview cover"
              />
              <div
                :if={!present?(preview_value(@form, :image_url, nil))}
                class="preview-cover__placeholder"
              >
                {preview_initials(@form)}
              </div>
            </div>

            <div class="song-row">
              <div>
                <p class="song-row__title">{preview_value(@form, :title, "Untitled song")}</p>
                <p class="song-row__meta">{preview_value(@form, :artist, "Unknown artist")}</p>
              </div>
            </div>

            <div class="preview-card__meta">
              <div class="preview-card__meta-row">
                <span>Energy</span>
                <.energy_badge value={preview_energy(@form)} />
              </div>
              <div class="preview-card__meta-row">
                <span>Assets</span>
                <div class="asset-pills">
                  <.asset_pill label="Audio" active={present?(preview_value(@form, :audio_url, nil))} />
                  <.asset_pill label="Cover" active={present?(preview_value(@form, :image_url, nil))} />
                </div>
              </div>
            </div>

            <div class="meta-section">
              <p class="meta-section__label">Semantic tags</p>
              <.tag_list items={preview_list(@form, :semantic_tags)} empty="Chưa có tag" />
            </div>

            <div class="meta-section">
              <p class="meta-section__label">Search aliases</p>
              <.tag_list items={preview_list(@form, :search_aliases)} empty="Chưa có alias" />
            </div>
          </div>
        </aside>
      </section>
    </Layouts.app>
    """
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    song = Music.get_song!(id)

    socket
    |> assign(:page_title, "Chỉnh sửa bài hát")
    |> assign(:song, song)
    |> assign(:form, to_form(Music.change_song(song)))
  end

  defp apply_action(socket, :new, _params) do
    song = %Song{energy_level: 3}

    socket
    |> assign(:page_title, "Tạo bài hát")
    |> assign(:song, song)
    |> assign(:form, to_form(Music.change_song(song)))
  end

  @impl true
  def handle_event("validate", %{"song" => song_params}, socket) do
    changeset = Music.change_song(socket.assigns.song, song_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"song" => song_params}, socket) do
    save_song(socket, socket.assigns.live_action, song_params)
  end

  defp save_song(socket, :edit, song_params) do
    case Music.update_song(socket.assigns.song, song_params) do
      {:ok, song} ->
        {:noreply,
         socket
         |> put_flash(:info, "Cập nhật bài hát thành công")
         |> push_navigate(to: return_path(socket.assigns.return_to, song))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_song(socket, :new, song_params) do
    case Music.create_song(song_params) do
      {:ok, song} ->
        {:noreply,
         socket
         |> put_flash(:info, "Tạo bài hát thành công")
         |> push_navigate(to: return_path(socket.assigns.return_to, song))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("index", _song), do: ~p"/admin/songs"
  defp return_path("show", song), do: ~p"/admin/songs/#{song}"

  defp textarea_value(form, field) do
    form
    |> preview_list(field)
    |> Enum.join("\n")
  end

  defp preview_value(form, field, fallback) do
    case form[field].value do
      nil -> fallback
      "" -> fallback
      [] -> fallback
      value -> value
    end
  end

  defp preview_list(form, field) do
    case form[field].value do
      values when is_list(values) ->
        Enum.reject(values, &(&1 in [nil, ""]))

      value when is_binary(value) ->
        value
        |> String.split(~r/[\n,]/, trim: true)
        |> Enum.map(&String.trim/1)
        |> Enum.reject(&(&1 == ""))

      _ ->
        []
    end
  end

  defp preview_initials(form) do
    [preview_value(form, :title, "S"), preview_value(form, :artist, "O")]
    |> Enum.map(&String.first/1)
    |> Enum.reject(&is_nil/1)
    |> Enum.join()
    |> String.upcase()
  end

  defp preview_energy(form) do
    case form[:energy_level].value do
      value when is_integer(value) -> value
      value when is_binary(value) and value != "" -> String.to_integer(value)
      _ -> 3
    end
  end

  defp present?(value) when is_binary(value), do: String.trim(value) != ""
  defp present?(nil), do: false
  defp present?(_value), do: true
end
