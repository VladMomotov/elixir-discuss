defmodule Discuss.AuthController do
    use Discuss.Web, :controller
    plug Ueberauth

    alias Discuss.User

    def callback(%{assigns: %{ueberauth_auth: auth}} = conn, params) do
        user_params = %{
            token: auth.credentials.token,
            email: auth.info.email,
            provider: auth.provider
        }
        changeset = User.changeset(%User{}, user_params)

        get_or_insert_user(changeset)
    end

    defp get_or_insert_user(changeset) do
      case Repo.get_by(User, email: changeset.changes.email) do
        nil -> 
          Repo.insert(changeset)
        user -> 
          {:ok, user}  
      end
    end
end
