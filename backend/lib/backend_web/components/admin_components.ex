defmodule BackendWeb.AdminComponents do
  use Phoenix.Component

  import BackendWeb.CoreComponents, only: [icon: 1]

  attr :label, :string, required: true
  attr :value, :any, required: true
  attr :hint, :string, default: nil
  attr :icon, :string, required: true
  attr :tone, :string, default: "primary", values: ~w(primary success warning neutral)

  def metric_card(assigns) do
    ~H"""
    <article class="metric-card">
      <div class={["metric-card__icon", "metric-card__icon--#{@tone}"]}>
        <.icon name={@icon} class="size-5" />
      </div>

      <div class="metric-card__body">
        <p class="metric-card__label">{@label}</p>
        <p class="metric-card__value">{@value}</p>
        <p :if={@hint} class="metric-card__hint">{@hint}</p>
      </div>
    </article>
    """
  end

  attr :value, :any, required: true

  def energy_badge(assigns) do
    ~H"""
    <span class={["energy-pill", "energy-pill--#{energy_tone(@value)}"]}>
      Energy {@value || 0}
    </span>
    """
  end

  attr :title, :string, required: true
  attr :subtitle, :string, default: nil
  attr :icon, :string, required: true

  def empty_state(assigns) do
    ~H"""
    <div class="empty-state">
      <div class="empty-state__icon">
        <.icon name={@icon} class="size-6" />
      </div>
      <div>
        <h3 class="empty-state__title">{@title}</h3>
        <p :if={@subtitle} class="empty-state__subtitle">{@subtitle}</p>
      </div>
    </div>
    """
  end

  attr :items, :list, default: []
  attr :empty, :string, default: "Chưa có"
  attr :limit, :integer, default: 4

  def tag_list(assigns) do
    assigns =
      assigns
      |> assign(:visible_items, Enum.take(assigns.items, assigns.limit))
      |> assign(:remaining_count, max(length(assigns.items) - assigns.limit, 0))

    ~H"""
    <div :if={@items != []} class="tag-list">
      <span :for={item <- @visible_items} class="tag-chip">{item}</span>
      <span :if={@remaining_count > 0} class="tag-chip tag-chip--muted">
        +{@remaining_count}
      </span>
    </div>
    <span :if={@items == []} class="muted-copy">{@empty}</span>
    """
  end

  attr :label, :string, required: true
  attr :active, :boolean, default: false

  def asset_pill(assigns) do
    ~H"""
    <span class={["asset-pill", @active && "is-active"]}>
      {@label}
    </span>
    """
  end

  attr :song, :map, required: true

  def song_avatar(assigns) do
    ~H"""
    <div class="song-avatar">
      <img :if={present?(@song.image_url)} src={@song.image_url} alt={@song.title} />
      <span :if={!present?(@song.image_url)}>{initials(@song.title, @song.artist)}</span>
    </div>
    """
  end

  defp energy_tone(value) when value in [1, 2], do: "calm"
  defp energy_tone(value) when value == 3, do: "balanced"
  defp energy_tone(value) when value in [4, 5], do: "high"
  defp energy_tone(_value), do: "muted"

  defp present?(value) when is_binary(value), do: String.trim(value) != ""
  defp present?(nil), do: false
  defp present?(_value), do: true

  defp initials(nil, nil), do: "SO"

  defp initials(title, artist) do
    [title || "", artist || ""]
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
    |> Enum.flat_map(&(String.split(&1, ~r/\s+/, trim: true) |> Enum.take(1)))
    |> Enum.take(2)
    |> Enum.map(&String.first/1)
    |> Enum.reject(&is_nil/1)
    |> Enum.join()
    |> case do
      "" -> "SO"
      value -> String.upcase(value)
    end
  end
end
