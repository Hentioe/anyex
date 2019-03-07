defmodule WebServer.Common do
  @moduledoc false

  alias WebServer.Config.Store, as: ConfigStore

  defmacro unix_now do
    DateTime.to_unix(DateTime.utc_now())
  end

  def get_path(raw, name_or_title) do
    case ConfigStore.get(:web_server, :path_strategy) do
      :raw -> raw
      :uuid -> UUID.uuid4()
      :fixed -> path_fixed(raw)
      :auto -> path_fixed(name_or_title)
      _ -> nil
    end
  end

  @re ~r/-{1,}/
  def path_fixed(raw) do
    if is_nil(raw) do
      nil
    else
      raw
      |> String.replace(" ", "-")
      |> String.replace(",", "-")
      |> String.replace("，", "-")
      |> String.replace(":", "-")
      |> String.replace("：", "-")
      |> String.replace("/", "")
      |> String.replace("\\", "")
      |> String.replace("\"", "")
      |> String.replace("“", "")
      |> String.replace("”", "")
      |> String.replace("?", "-")
      |> String.replace("？", "-")
      |> String.replace("!", "-")
      |> String.replace("！", "-")
      |> String.replace(".", "-")
      |> String.replace("。", "-")
      |> String.replace("&", "")
      |> String.replace("’", "-")
      |> String.replace("'", "-")
      |> (fn s -> Regex.replace(@re, s, "-") end).()
      |> path_end_fixed()
    end
  end

  defp path_end_fixed(path) do
    if String.ends_with?(path, "-") do
      fix_one = String.slice(path, 0..(String.length(path) - 2))
      fix_one |> path_end_fixed()
    else
      path
    end
  end
end
