defmodule LvApp.TodosFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `LvApp.Todos` context.
  """

  @doc """
  Generate a todo.
  """
  def todo_fixture(attrs \\ %{}) do
    {:ok, todo} =
      attrs
      |> Enum.into(%{
        description: "some description",
        title: "some title"
      })
      |> LvApp.Todos.create_todo()

    todo
  end
end
