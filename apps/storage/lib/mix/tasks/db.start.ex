defmodule Mix.Tasks.Db.Start do
  @moduledoc false
  defmacro eprint(msg) do
    quote do
      IO.puts(:stderr, "#{IO.ANSI.red()}#{IO.ANSI.bright()}#{unquote(msg)}")
    end
  end

  @files [
    "dev.docker-compose.yml",
    "dev.docker-compose.yaml"
  ]

  def run(_args) do
    exists_r = @files |> Enum.filter(&File.exists?(&1))

    case exists_r do
      [head_f | _] ->
        System.cmd("docker-compose", ["-f", head_f, "up", "-d"])

      [] ->
        eprint("** (DB.START) The dev.docker-compose.y(a)ml file could not be found.")
    end
  end
end
