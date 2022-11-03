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

alias Im.Accounts
alias Im.Repo

usernames = ["lucy", "kasumi", "alex", "mari", "ruby", "sofia", "haru", "liah", "reah"]

users =
  for user <- usernames do
    {:ok, user} = Accounts.create_user(%{username: user, password: "asdfasdf"})
    user
  end

kasumi = Repo.get_by!(Accounts.User, username: "kasumi")

for user <- users do
  unless user.username == "kasumi" do
    Accounts.send_friend_request(user, kasumi)
  end
end
