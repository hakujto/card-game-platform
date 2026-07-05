defmodule CardsProject.Marketplace.Events.OrderEvents do

  defmodule OrderPaid do
    @type t_order_id :: integer()
    @type t_player_id :: integer()
    @type t_total :: Decimal.t()
    @type t_payment_method :: String.t()
    @type t_paid_at :: NaiveDateTime.t()

    defstruct [:order_id, :player_id, :total, :payment_method, :paid_at]
  end

  defmodule OrderShipped do
    @type t_order_id :: integer()
    @type t_tracking_number :: String.t()
    @type t_shipped_at :: NaiveDateTime.t()

    defstruct [:order_id, :tracking_number, :shipped_at]
  end

  defmodule OrderRefunded do
    @type t_order_id :: integer()
    @type t_refunded_at :: NaiveDateTime.t()

    defstruct [:order_id, :refunded_at]
  end

end
