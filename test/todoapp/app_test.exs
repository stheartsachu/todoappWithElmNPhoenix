defmodule Todoapp.AppTest do
  use Todoapp.DataCase

  alias Todoapp.App

  describe "todos" do
    alias Todoapp.App.Todo

    @valid_attrs %{completion_status: true, description: "some description", title: "some title"}
    @update_attrs %{completion_status: false, description: "some updated description", title: "some updated title"}
    @invalid_attrs %{completion_status: nil, description: nil, title: nil}

    def todo_fixture(attrs \\ %{}) do
      {:ok, todo} =
        attrs
        |> Enum.into(@valid_attrs)
        |> App.create_todo()

      todo
    end

    test "list_todos/0 returns all todos" do
      todo = todo_fixture()
      assert App.list_todos() == [todo]
    end

    test "get_todo!/1 returns the todo with given id" do
      todo = todo_fixture()
      assert App.get_todo!(todo.id) == todo
    end

    test "create_todo/1 with valid data creates a todo" do
      assert {:ok, %Todo{} = todo} = App.create_todo(@valid_attrs)
      assert todo.completion_status == true
      assert todo.description == "some description"
      assert todo.title == "some title"
    end

    test "create_todo/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = App.create_todo(@invalid_attrs)
    end

    test "update_todo/2 with valid data updates the todo" do
      todo = todo_fixture()
      assert {:ok, %Todo{} = todo} = App.update_todo(todo, @update_attrs)
      assert todo.completion_status == false
      assert todo.description == "some updated description"
      assert todo.title == "some updated title"
    end

    test "update_todo/2 with invalid data returns error changeset" do
      todo = todo_fixture()
      assert {:error, %Ecto.Changeset{}} = App.update_todo(todo, @invalid_attrs)
      assert todo == App.get_todo!(todo.id)
    end

    test "delete_todo/1 deletes the todo" do
      todo = todo_fixture()
      assert {:ok, %Todo{}} = App.delete_todo(todo)
      assert_raise Ecto.NoResultsError, fn -> App.get_todo!(todo.id) end
    end

    test "change_todo/1 returns a todo changeset" do
      todo = todo_fixture()
      assert %Ecto.Changeset{} = App.change_todo(todo)
    end
  end
end
