defmodule LvAppWeb.TodoLive.Index do
  import Ecto.Changeset

  use LvAppWeb, :live_view
  use Tesla

  plug Tesla.Middleware.BaseUrl, "http://todo_api-phoenix-1:4000"
  plug Tesla.Middleware.Headers, [{
    "X-ApiKey",
    Application.get_env(:lv_app, :lv_app_api_key)
  }]
  plug Tesla.Middleware.Logger
  plug Tesla.Middleware.JSON

  alias LvApp.Todos
  alias LvApp.Todos.Todo

  @impl true
  def mount(_params, _session, socket) do

    with {:ok, result} <- get("/api/todos")
    do
      todos =
      result.body["data"]
      |>Enum.map(fn x -> Todo.changeset(%Todo{}, x) |> apply_changes() end)
      {:ok, stream(socket, :todos, todos)}
    end
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    with {:ok, result} <- get("/api/todos/" <>id),
          todo_changesets = result.body["data"],
          todo = Todo.changeset(%Todo{}, todo_changesets),
          response = apply_changes(todo)
        do
          socket
          |> assign(:page_title, "Edit Todo")
          |> assign(:todo, response)
        end
  end

  defp apply_action(socket, :update, %{"id" => id}) do
    IO.inspect(socket)
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Todo")
    |> assign(:todo, %Todo{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Todos")
    |> assign(:todo, nil)
  end

  @impl true
  def handle_info({LvAppWeb.TodoLive.FormComponent, {:saved, todo}}, socket) do
    {:noreply, stream_insert(socket, :todos, todo)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    # todo_map= %{
    #   :id => id
    # }
    client = Tesla.client([
      {Tesla.Middleware.BaseUrl, "http://todo_api-phoenix-1:4000"},
      Tesla.Middleware.JSON,
      {Tesla.Middleware.Headers, [{"Content-Type", "application/json"}]},
      Tesla.Middleware.PathParams,
      Tesla.Middleware.Logger
    ])
    path = "/api/todos/" <> id
    todo = Tesla.delete(client, path)

    {:noreply, stream_delete(socket, :todos, todo)}
  end
end
