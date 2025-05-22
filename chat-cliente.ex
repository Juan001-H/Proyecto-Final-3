defmodule ChatClient do
  def start do
    start(~c"localhost", 4040) # Cambiado a charlist
  end

  def start(host, port) do
    case :gen_tcp.connect(host, port, [:binary, packet: :line, active: false]) do
      {:ok, socket} ->
        IO.puts("Conectado al servidor en #{host}:#{port}")
        spawn(fn -> receive_messages(socket) end)
        send_messages(socket)

      {:error, reason} ->
        IO.puts("Error al conectar con el servidor: #{reason}")
    end
  end

  defp receive_messages(socket) do
    IO.puts("Esperando mensajes...")
    case :gen_tcp.recv(socket, 0) do
      {:ok, data} ->
        IO.write(data)
        receive_messages(socket)

      {:error, :closed} ->
        IO.puts("Conexión cerrada por el servidor")

      {:error, reason} ->
        IO.puts("Error al recibir datos: #{reason}")
    end
  end

  defp send_messages(socket) do
    IO.puts("Escribe un mensaje:")
    input = IO.gets("") |> String.trim()
    case :gen_tcp.send(socket, input <> "\n") do
      :ok -> send_messages(socket)
      {:error, :closed} ->
        IO.puts("No se pudo enviar el mensaje. La conexión está cerrada.")
      {:error, reason} ->
        IO.puts("Error al enviar mensaje: #{reason}")
    end
  end
end

ChatClient.start()

# A esteban le gustan las ñemas
