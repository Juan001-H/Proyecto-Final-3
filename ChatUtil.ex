defmodule ChatUtils do
  @moduledoc """
  Módulo de utilidades para la gestión de usuarios, salas y mensajes.
  """

  @doc "Agrega un usuario a una sala específica."
  def join_room(username, room_name, rooms) do
    case Map.get(rooms, room_name) do
      nil -> {:error, "La sala no existe"}
      room ->
        updated_room = Map.update(room, :users, [username], fn users -> [username | users] end)
        updated_rooms = Map.put(rooms, room_name, updated_room)
        {:ok, updated_rooms}
    end
  end

  @doc "Difunde un mensaje a todos los usuarios de una sala."
  def broadcast_message(username, room_name, message, rooms) do
    case Map.get(rooms, room_name) do
      nil -> {:error, "La sala no existe"}
      %{users: users} = room ->
        Enum.each(users, fn user ->
          IO.puts("#{user} recibió: [#{username}] #{message}")
        end)
        updated_room = Map.update!(room, :messages, fn msgs -> [{username, message} | msgs] end)
        {:ok, Map.put(rooms, room_name, updated_room)}
    end
  end
end

