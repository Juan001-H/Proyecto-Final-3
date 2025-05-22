defmodule Servidor.Chat do
  use GenServer

  # Estado inicial del servidor
  def start_link(_) do
    GenServer.start_link(_MODULE_, %{
      usuarios: %{},
      salas: %{},
      historial: %{}
    }, name: _MODULE_)
  end

  def init(state), do: {:ok, state}

  # Registrar usuario
  def registrar_usuario(nombre) do
    GenServer.call(_MODULE_, {:registrar_usuario, nombre})
  end

  # Crear sala
  def crear_sala(nombre_sala) do
    GenServer.call(_MODULE_, {:crear_sala, nombre_sala})
  end

  # Unirse a sala
  def unirse_a_sala(nombre_usuario, nombre_sala) do
    GenServer.call(_MODULE_, {:unirse_a_sala, nombre_usuario, nombre_sala})
  end

  # Manejar mensajes
  def manejar_mensajes(sala, mensaje) do
    GenServer.call(_MODULE_, {:mensaje, sala, mensaje})
  end

  # Consultar historial
  def consultar_historial(sala) do
    GenServer.call(_MODULE_, {:consultar_historial, sala})
  end

  # Listar usuarios conectados
  def listar_usuarios do
    GenServer.call(_MODULE_, :listar_usuarios)
  end

  # Lógica del servidor
  def handle_call({:registrar_usuario, nombre}, _from, state) do
    usuarios = Map.put(state.usuarios, nombre, self())
    {:reply, :ok, %{state | usuarios: usuarios}}
  end

  def handle_call({:crear_sala, nombre_sala}, _from, state) do
    if Map.has_key?(state.salas, nombre_sala) do
      {:reply, {:error, :sala_existente}, state}
    else
      salas = Map.put(state.salas, nombre_sala, [])
      historial = Map.put(state.historial, nombre_sala, [])
      {:reply, :ok, %{state | salas: salas, historial: historial}}
    end
  end

  def handle_call({:unirse_a_sala, nombre_usuario, nombre_sala}, _from, state) do
    if Map.has_key?(state.salas, nombre_sala) do
      salas = Map.update!(state.salas, nombre_sala, &([nombre_usuario | &1]))
      {:reply, :ok, %{state | salas: salas}}
    else
      {:reply, {:error, :sala_no_existe}, state}
    end
  end

  def handle_call({:mensaje, sala, mensaje}, _from, state) do
    case Map.fetch(state.salas, sala) do
      {:ok, usuarios} ->
        for usuario <- usuarios do
          send(state.usuarios[usuario], {:mensaje, sala, mensaje})
        end
        historial = Map.update!(state.historial, sala, &([mensaje | &1]))
        {:reply, :ok, %{state | historial: historial}}
      :error ->
        {:reply, {:error, :sala_no_existe}, state}
    end
  end

  def handle_call({:consultar_historial, sala}, _from, state) do
    case Map.fetch(state.historial, sala) do
      {:ok, mensajes} ->
        {:reply, Enum.reverse(mensajes), state}
      :error ->
        {:reply, {:error, :sala_no_existe}, state}
    end
  end

  def handle_call(:listar_usuarios, _from, state) do
    {:reply, Map.keys(state.usuarios), state}
  end
end
