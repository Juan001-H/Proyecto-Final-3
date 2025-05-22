defmodule Cliente.Chat do
  def start_cliente(nombre) do
    Servidor.Chat.registrar_usuario(nombre)
    loop(nombre)
  end

  defp loop(nombre) do
    Util.mostrar_mensaje("Comandos disponibles: /list, /join, /create, /history, /exit")
    comando = IO.gets("\n> ") |> String.trim()

    case String.split(comando) do
      ["/list"] ->
        IO.inspect(Servidor.Chat.listar_usuarios(), label: "Usuarios conectados")
      ["/create", sala] ->
        case Servidor.Chat.crear_sala(sala) do
          :ok -> Util.mostrar_mensaje("Sala '#{sala}' creada exitosamente.")
          {:error, :sala_existente} -> Util.mostrar_error("La sala ya existe.")
        end
      ["/join", sala] ->
        case Servidor.Chat.unirse_a_sala(nombre, sala) do
          :ok -> Util.mostrar_mensaje("Te has unido a la sala '#{sala}'.")
          {:error, :sala_no_existe} -> Util.mostrar_error("La sala no existe.")
        end
      ["/history", sala] ->
        case Servidor.Chat.consultar_historial(sala) do
          {:error, :sala_no_existe} -> Util.mostrar_error("La sala no existe.")
          mensajes -> IO.inspect(mensajes, label: "Historial de mensajes")
        end
      ["/exit"] ->
        Util.mostrar_mensaje("Saliendo del chat...")
        :ok
      _ ->
        Util.mostrar_error("Comando no reconocido.")
    end

    loop(nombre)
  end
end
