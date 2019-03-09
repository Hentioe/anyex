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

  @errors general: 5000,
          invalid_header: 8001
  def error_code(reason_type) do
    @errors[reason_type] || @errors[:general]
  end
end
