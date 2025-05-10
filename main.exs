Code.require_file("ChatUtil.ex")
Code.require_file("serverchat.ex")

defmodule Main do
  def run do
    # Inicia el servidor
    {:ok, _pid} = ChatServer.start_link([])

    # Registro y autenticación de usuarios
    IO.inspect(ChatServer.register_user("usuario1", "password1"), label: "Registro de usuario1")
    IO.inspect(ChatServer.register_user("usuario2", "password2"), label: "Registro de usuario2")
    IO.inspect(ChatServer.register_user("usuario1", "password123"), label: "Intento de registro duplicado")

    IO.inspect(ChatServer.authenticate_user("usuario1", "password1"), label: "Autenticación exitosa de usuario1")
    IO.inspect(ChatServer.authenticate_user("usuario1", "wrongpassword"), label: "Autenticación fallida de usuario1")
    IO.inspect(ChatServer.authenticate_user("usuario3", "password3"), label: "Autenticación de usuario no registrado")

    # Creación de salas
    IO.inspect(ChatServer.create_room("general"), label: "Creación de sala general")
    IO.inspect(ChatServer.create_room("tecnologia"), label: "Creación de sala tecnología")
    IO.inspect(ChatServer.create_room("general"), label: "Intento de crear sala duplicada")

    # Listar salas
    IO.inspect(ChatServer.list_rooms(), label: "Salas disponibles")

    # Envío de mensajes
    ChatServer.broadcast_message("usuario1", "general", "¡Hola a todos!")
    ChatServer.broadcast_message("usuario2", "general", "¡Hola usuario1!")
  end
end

Main.run()
