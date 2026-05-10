defmodule CardsProject.Endpoint do
  use Phoenix.Endpoint, otp_app: :cards_project

  plug CORSPlug, origin: ["*"]

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head

  plug CardsProjectWeb.Router
end
