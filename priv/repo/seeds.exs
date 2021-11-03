# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Todoapp.Repo.insert!(%Todoapp.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias Todoapp.Repo

alias Todoapp.App.Todo

Repo.insert!(%Todo{
  title: "Elm",
  description: "Learn Elm",
  completion_status: true
})

Repo.insert!(%Todo{
  title: "Elixir",
  description: "Learn Elixir",
  completion_status: true
})

Repo.insert!(%Todo{
  title: "phoenix",
  description: "Learn phoenix",
  completion_status: true
})

Repo.insert!(%Todo{
  title: "new",
  description: "new",
  completion_status: true
})
