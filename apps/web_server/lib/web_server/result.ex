defmodule WebServer.Result do
  @moduledoc false

  @derive Jason.Encoder
  defstruct [:code, :message, :data]

  def result(code, message, data \\ nil) do
    %__MODULE__{
      code: code,
      message: message,
      data: data
    }
  end
end
