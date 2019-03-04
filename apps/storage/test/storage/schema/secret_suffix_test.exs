defmodule Storage.Schema.SecretSuffixTest do
  use ExUnit.Case, async: false

  alias Storage.Repo
  alias Storage.Schema.{SecretSuffix}

  import Storage.Schema.SecretSuffix

  setup do
    on_exit(fn ->
      Repo.delete_all(SecretSuffix)
    end)
  end

  test "generate and get last secret_suffix" do
    {status, instered} = generate()
    assert status == :ok

    last = last_one()
    assert last != nil
    assert instered.val == last.val
  end
end
