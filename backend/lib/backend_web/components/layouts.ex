defmodule BackendWeb.Layouts do
  @moduledoc """
  Layouts and shared shells for the backend interface.
  """
  use BackendWeb, :html

  alias Phoenix.LiveView.JS

  embed_templates "layouts/*"

  attr :flash, :map, required: true, doc: "the map of flash messages"

  attr :current_scope, :map,
    default: nil,
    doc: "the current [scope](https://hexdocs.pm/phoenix/scopes.html)"

  attr :active_nav, :string, default: "dashboard"

  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <div class="admin-shell">
      <aside class="admin-sidebar">
        <div class="admin-brand">
          <div class="admin-brand__mark">
            <.icon name="hero-musical-note" class="size-6" />
          </div>

          <div class="admin-brand__copy">
            <p class="admin-brand__eyebrow">Song Admin</p>
            <h1 class="admin-brand__title">Catalog</h1>
          </div>
        </div>

        <nav class="admin-nav" aria-label="Sidebar">
          <.admin_nav_link
            navigate={~p"/admin"}
            active={@active_nav == "dashboard"}
            icon="hero-squares-2x2"
            label="Overview"
            caption="Số liệu"
          />
          <.admin_nav_link
            navigate={~p"/admin/songs"}
            active={@active_nav == "songs"}
            icon="hero-queue-list"
            label="Songs"
            caption="Metadata"
          />
        </nav>

        <div class="admin-sidebar__footer">
          <p class="admin-sidebar__caption">Quick note</p>
          <p class="admin-sidebar__text">Audio, cover, tags, aliases.</p>
        </div>
      </aside>

      <div class="admin-main">
        <header class="admin-topbar">
          <div class="admin-topbar__copy">
            <p class="admin-topbar__eyebrow">Metadata</p>
            <h2 class="admin-topbar__title">Song management</h2>
          </div>

          <div class="admin-topbar__actions">
            <.link navigate={~p"/admin/songs/new"} class="md-button md-button-primary">
              <.icon name="hero-plus" class="size-4" /> Thêm bài hát
            </.link>
            <.theme_toggle />
          </div>
        </header>

        <main class="admin-content">
          {render_slot(@inner_block)}
        </main>
      </div>

      <.flash_group flash={@flash} />
    </div>
    """
  end

  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} class="flash-stack" aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        title={gettext("We can't find the internet")}
        phx-disconnected={show(".phx-client-error #client-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={show(".phx-server-error #server-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
      </.flash>
    </div>
    """
  end

  def theme_toggle(assigns) do
    ~H"""
    <div class="theme-switcher" role="group" aria-label="Theme switcher">
      <button
        type="button"
        class="theme-switcher__button"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="system"
      >
        <.icon name="hero-computer-desktop" class="size-4" />
      </button>
      <button
        type="button"
        class="theme-switcher__button"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="light"
      >
        <.icon name="hero-sun" class="size-4" />
      </button>
      <button
        type="button"
        class="theme-switcher__button"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="dark"
      >
        <.icon name="hero-moon" class="size-4" />
      </button>
    </div>
    """
  end

  attr :navigate, :string, required: true
  attr :icon, :string, required: true
  attr :label, :string, required: true
  attr :caption, :string, required: true
  attr :active, :boolean, default: false

  defp admin_nav_link(assigns) do
    ~H"""
    <.link
      navigate={@navigate}
      class={["admin-nav__link", @active && "is-active"]}
    >
      <div class={["admin-nav__icon", @active && "is-active"]}>
        <.icon name={@icon} class="size-5" />
      </div>

      <div class="admin-nav__copy">
        <span class="admin-nav__label">{@label}</span>
        <span class="admin-nav__caption">{@caption}</span>
      </div>
    </.link>
    """
  end
end
