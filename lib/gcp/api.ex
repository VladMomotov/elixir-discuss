defmodule GCP.Api do
  @behaviour GCP.ApiBehaviour

  def get_token(scope \\ "https://www.googleapis.com/auth/cloud-platform") do
    {:ok, goth_token} = Goth.Token.for_scope(scope)
    {:ok, %GCP.Token{expires: goth_token.expires, token: goth_token.token}}
  end
end
