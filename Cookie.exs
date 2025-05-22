defmodule Chat.Cookie do
  def configurar_cookie(cookie) do
    :erlang.set_cookie(node(), cookie)
    Util.mostrar_mensaje("Cookie configurada: #{cookie}")
  end

  def conectar_nodo(nodo_remoto) do
    if Node.connect(nodo_remoto) do
      Util.mostrar_mensaje("Conectado al nodo #{nodo_remoto}")
    else
      Util.mostrar_error("No se pudo conectar al nodo #{nodo_remoto}")
    end
  end
end
