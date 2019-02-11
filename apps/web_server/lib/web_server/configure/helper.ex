defmodule WebServer.Configure.Helper do
  @moduledoc false
  @prefix "ANYEX_SERVER_"
  @config_items [
    {:web_server, :port},
    {:web_server, :username},
    {:web_server, :password},
    {:web_server, :secret},
    {:web_server, :article_markdown_support},
    {:web_server, :tweet_markdown_support},
    {:web_server, :default_limit}
  ]

  def init do
    @config_items
    |> Enum.reduce(Map.new(), fn {app, item}, acc ->
      Map.put(acc, gen_key(app, item), get_config!(app, item))
    end)
  end

  def get_config!(app, item) do
    name = item |> Atom.to_string() |> String.upcase()
    env_var = "#{@prefix}#{name}"

    val =
      System.get_env(env_var) ||
        Application.get_env(app, item)

    if val !== nil, do: val, else: raise("please give me a #{item} parameter!")
  end

  def gen_key(app, item) do
    "#{app}_#{item}"
  end
end
