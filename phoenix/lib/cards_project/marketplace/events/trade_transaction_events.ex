defmodule CardsProject.Marketplace.Events.TradeTransactionEvents do

  defmodule TransactionCompleted do
    @type t_transaction_id :: integer()
    @type t_buyer_id :: integer()
    @type t_seller_id :: integer()
    @type t_final_price :: Decimal.t()
    @type t_completed_at :: NaiveDateTime.t()

    defstruct [:transaction_id, :buyer_id, :seller_id, :final_price, :completed_at]
  end

end
