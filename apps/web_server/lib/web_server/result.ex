defmodule WebServer.Result do
  @moduledoc false

  @derive Jason.Encoder
  defstruct [:code, :message, :data]

  def result(reason_type, message, data \\ nil) when is_atom(reason_type) do
    %__MODULE__{
      code: error_code(reason_type),
      message: message,
      data: data
    }
  end

  @errors general: 5000,
          header_invalid: 8001,
          not_found: 7002,
          params_deficiency: 6001
  def error_code(reason_type) do
    @errors[reason_type] || @errors[:general]
  end
end
