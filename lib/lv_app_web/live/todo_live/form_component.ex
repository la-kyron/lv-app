defmodule LvAppWeb.TodoLive.FormComponent do
  import Ecto.Changeset
  use LvAppWeb, :live_component
  use Tesla

  alias LvApp.Todos
  alias LvApp.Todos.Todo

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage todo records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="todo-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:title]} type="text" label="Title" />
        <.input field={@form[:description]} type="text" label="Description" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Todo</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{todo: todo} = assigns, socket) do
    IO.inspect(assigns)
    changeset = Todos.change_todo(todo)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}

  end

  @impl true
  def handle_event("validate", %{"todo" => todo_params}, socket) do
    changeset =
      socket.assigns.todo
      |> Todos.change_todo(todo_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"todo" => todo_params}, socket) do
    save_todo(socket, socket.assigns.action, todo_params)
  end

  defp save_todo(socket, :edit, todo_params) do
    todo_map = %{
      "todo" => %{
        "title" =>  Map.get(todo_params, "title"),
        "description" => Map.get(todo_params, "description")
      }
    }
    client = Tesla.client([
      {Tesla.Middleware.BaseUrl, "http://todo_api-phoenix-1:4000"},
      Tesla.Middleware.JSON,
      {Tesla.Middleware.Headers, [{"Content-Type", "application/json"}]},
      Tesla.Middleware.PathParams,
      Tesla.Middleware.Logger
    ])
    path = "/api/todos/" <> socket.assigns.todo.id

    with {:ok, result} <- Tesla.put(client, path, todo_map),
         todo_changesets <- result.body["data"],
         todo <- Todo.changeset(%Todo{}, todo_changesets),
         response = apply_changes(todo)
    do
      notify_parent({:saved, response})
    {:noreply,
          socket
          |> put_flash(:info, "Todo updated successfully")
          |> push_patch(to: socket.assigns.patch)}
    end
  end

  defp save_todo(socket, :new, todo_params) do
    todo_map = %{
      "todo" => %{
        "title" =>  Map.get(todo_params, "title"),
        "description" => Map.get(todo_params, "description")
      }
    }
    client = Tesla.client([
      {Tesla.Middleware.BaseUrl, "http://todo_api-phoenix-1:4000"},
      Tesla.Middleware.JSON,
      {Tesla.Middleware.Headers, [{"Content-Type", "application/json"}]},
      Tesla.Middleware.PathParams,
      Tesla.Middleware.Logger
    ])
    path = "/api/todos/"
    todo = Tesla.post(client, path, todo_map)

    case todo do
      {:ok, todo} ->
        notify_parent({:saved, todo})

        {:noreply,
         socket
         |> put_flash(:info, "Todo created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
