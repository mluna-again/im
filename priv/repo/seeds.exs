# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Im.Repo.insert!(%Im.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Im.{Repo, Accounts}
alias Im.Accounts.{Friend}

usernames = ["lucy", "kasumi", "alex"]

for user <- usernames do
  {:ok, _user} = Accounts.create_user(%{username: user, password: "asdfasdf"})
end
