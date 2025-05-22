defmodule Util do
  def mostrar_mensaje(mensaje) do
    IO.puts("[INFO] #{mensaje}")
  end

  def mostrar_error(mensaje) do
    IO.puts("[ERROR] #{mensaje}")
  end

  def ingresar_texto(mensaje, :texto) do
    mensaje
    |> IO.gets()
    |> String.trim()
  end

  def ingresar_entero(mensaje, :entero), do: ingresar(mensaje, &String.to_integer/1, :entero)

  def ingresar_real(mensaje, :real), do: ingresar(mensaje, &String.to_float/1, :real)

  defp ingresar(mensaje, parser, tipo_dato) do
    try do
      mensaje
      |> ingresar_texto(:texto)
      |> parser.()
    rescue
      ArgumentError ->
        mostrar_error("Error, se espera que ingrese un número #{tipo_dato}")
        ingresar(mensaje, parser, tipo_dato)
    end
  end
end
