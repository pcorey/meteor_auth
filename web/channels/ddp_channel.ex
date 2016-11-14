defmodule MeteorAuth.DDPChannel do

  use Phoenix.Channel

  def join("ddp", _, socket) do
    {:ok, socket}
  end

  def handle_in("login", params, socket) do
    case MeteorAuth.Accounts.login(socket, params) do
      {:ok, res, auth_socket} ->
        {:reply, {:ok, res}, auth_socket}
      {:error} ->
        {:reply, :error, socket}
    end
  end

  def handle_in("foo", _, socket) do
    user = socket.assigns[:user] |> IO.inspect
    case user do
      nil ->
        {:reply, :ok, socket}
      %{"_id" => id} ->
        {:reply, {:ok, %{"id" => id}}, socket}
    end
  end

end
