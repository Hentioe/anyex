defmodule WebServer.Error do
  defexception [:reason_type, :message]

  def error(reason_type, message \\ "") do
    [reason_type: reason_type, message: message]
  end

  @impl true
  def exception(reason_type: reason_type, message: message) do
    %__MODULE__{reason_type: reason_type, message: message}
  end
end
