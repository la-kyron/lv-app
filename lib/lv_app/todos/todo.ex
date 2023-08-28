defmodule LvApp.Todos.Todo do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "todos" do
    field :id, :binary_id, primary_key: true
    field :description, :string
    field :title, :string

    timestamps()
  end

  @doc false
  def changeset(todo, attrs) do
    todo
    |> cast(attrs, [:id, :title, :description])
    |> validate_required([:id, :title, :description])
  end
end
