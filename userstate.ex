defmodule UserState do
  use Agent

  def start_link(_) do
    Agent.start_link(fn -> %{users: %{}, rooms: %{}} end, name: __MODULE__)
  end

  def register_user(username, password) do
    Agent.get_and_update(__MODULE__, fn state ->
      if Map.has_key?(state.users, username) do
        {{:error, :user_exists}, state}
      else
        new_users = Map.put(state.users, username, %{password: password, socket: nil, room: nil})
        {{:ok, :registered}, %{state | users: new_users}}
      end
    end)
  end

  def authenticate_user(username, password, socket) do
    Agent.get_and_update(__MODULE__, fn state ->
      case Map.get(state.users, username) do
        %{password: ^password} = user ->
          updated_user = Map.put(user, :socket, socket)
          new_users = Map.put(state.users, username, updated_user)
          {{:ok, :authenticated}, %{state | users: new_users}}

        _ -> {{:error, :invalid_credentials}, state}
      end
    end)
  end

  def join_room(username, room_name) do
    Agent.get_and_update(__MODULE__, fn state ->
      user = Map.get(state.users, username)
      if user do
        new_users = Map.put(state.users, username, Map.put(user, :room, room_name))
        new_rooms = Map.update(state.rooms, room_name, [username], &[username | &1])
        {{:ok, :joined}, %{state | users: new_users, rooms: new_rooms}}
      else
        {{:error, :no_user}, state}
      end
    end)
  end

  def get_users_in_room(room) do
    Agent.get(__MODULE__, fn state ->
      Enum.map(Map.get(state.rooms, room, []), fn user ->
        Map.get(state.users, user)
      end)
    end)
  end
end
