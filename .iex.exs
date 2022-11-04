alias Im.{Repo, Accounts, Messages}
alias Im.Accounts.{User}
alias Im.Messages.{Message, Room}

kasumi = Accounts.get_user_by!(username: "kasumi")
lucy = Accounts.get_user_by!(username: "lucy")
