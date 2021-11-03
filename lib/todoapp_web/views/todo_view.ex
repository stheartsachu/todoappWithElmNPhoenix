defmodule TodoappWeb.TodoView do
  use TodoappWeb, :view
  alias TodoappWeb.TodoView

  def render("index.json", %{todos: todos}) do
    render_many(todos, TodoView, "todo.json")
  end

  def render("show.json", %{todo: todo}) do
    %{data: render_one(todo, TodoView, "todo.json")}
  end

  def render("todo.json", %{todo: todo}) do
    %{
      id: todo.id,
      title: todo.title,
      description: todo.description || "",
      completion_status: todo.completion_status
    }
  end
end
