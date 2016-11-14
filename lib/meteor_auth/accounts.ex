defmodule MeteorAuth.Accounts do

  def login(socket, %{
              "user" => %{"username" => username},
              "password" => password
            }) when is_binary(username) and is_binary(password) do
    socket
    |> attempt_login(%{query: %{"profile.username" => username}}, password)
  end

  def login(socket, %{
              "user" => %{"email" => email},
              "password" => password
            }) when is_binary(email) and is_binary(password) do
    socket
    |> attempt_login(%{query: %{"emails.0.address": email}}, password)
  end

  defp attempt_login(socket, %{query: query}, password) do
    user = get_user_from_query(query)
    valid? = valid_credentials?(user, password)
    log_in_user(valid?, socket, user)
  end

  defp valid_credentials?(nil, _), do: false
  defp valid_credentials?(%{"services" => %{"password" => %{"bcrypt" => bcrypt}}},
                      password) do
    password
    |> get_password_string
    |> Comeonin.Bcrypt.checkpw(bcrypt)
  end

  defp log_in_user(true, socket, user) do
    auth_socket = Phoenix.Socket.assign(socket, :user, user)
    {:ok, %{"id" => user["_id"]}, auth_socket}
  end

  defp log_in_user(false, _socket, _user) do
    {:error}
  end

  defp get_user_from_query(query) do
    MongoPool
    |> Mongo.find("users", query)
    |> Enum.to_list
    |> List.first
  end

  defp get_password_string(password) do
    :crypto.hash(:sha256, password)
    |> Base.encode16
    |> String.downcase
  end

end
