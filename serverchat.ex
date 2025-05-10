defmodule ChatServer do
  def start(port \\ 4040) do
    UserState.start_link(nil)
    {:ok, socket} = :gen_tcp.listen(port, [:binary, packet: :line, active: false, reuseaddr: true])
    IO.puts("Servidor iniciado en puerto #{port}")
    loop_acceptor(socket)
  end

  defp loop_acceptor(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    spawn(fn -> handle_client(client) end)
    loop_acceptor(socket)
  end

  defp handle_client(socket) do
    :gen_tcp.send(socket, "Usuario: ")
    {:ok, username} = :gen_tcp.recv(socket, 0)
    username = String.trim(username)

    :gen_tcp.send(socket, "Contraseña: ")
    {:ok, password} = :gen_tcp.recv(socket, 0)
    password = String.trim(password)

    case UserState.register_user(username, password) do
      {:ok, :registered} -> :ok
      {:error, :user_exists} ->
        case UserState.authenticate_user(username, password, socket) do
          {:ok, :authenticated} -> :ok
          _ -> :gen_tcp.send(socket, "Error de autenticación\n"); exit(:normal)
        end
    end

    UserState.authenticate_user(username, password, socket)
    :gen_tcp.send(socket, "Sala a la que deseas unirte o crear: ")
    {:ok, room} = :gen_tcp.recv(socket, 0)
    room = String.trim(room)

    UserState.join_room(username, room)
    :gen_tcp.send(socket, "Entraste a la sala #{room}. Escribe para chatear:\n")

    loop_recv(socket, username, room)
  end

  defp loop_recv(socket, username, room) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, msg} ->
        broadcast(username, room, msg)
        loop_recv(socket, username, room)

      {:error, :closed} ->
        IO.puts("Cliente #{username} desconectado")
    end
  end

  defp broadcast(from, room, msg) do
    message = "[#{from}] #{msg}"
    UserState.get_users_in_room(room)
    |> Enum.each(fn %{socket: s} ->
      if s, do: :gen_tcp.send(s, message)
    end)
  end
end

ChatServer.start()
