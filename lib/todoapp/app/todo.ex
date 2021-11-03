defmodule Todoapp.App.Todo do
  use Ecto.Schema
  import Ecto.Changeset

  schema "todos" do
    field :completion_status, :boolean, default: false
    field :description, :string
    field :title, :string

    timestamps()
  end

  @doc false
  def changeset(todo, attrs) do
    todo
    |> cast(attrs, [:title, :description, :completion_status])
    |> validate_required([:title, :completion_status])
  end
end
