defmodule WebServer.Router do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  get "/" do
    send_resp(conn, 200, "Hello world!")
  end

  # forward "/articles", to: ArticleRouter

  match _ do
    send_resp(conn, 404, "Not Found")
  end
end
