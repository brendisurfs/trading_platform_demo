defmodule Portfolio do
  @moduledoc """
  Portfolio holds the positions of the platform.
  """
  @type t :: Map

  @spec new() :: Portfolio.t()
  def new do
    %{}
  end

  @spec add_position(Portfolio.t(), Position.t()) :: Portfolio.t()
  def add_position(state, position) do
    symbol = Map.get(position, :symbol)
    Map.put(state, symbol, position)
  end
end

defmodule Position do
  @moduledoc """
  defines a position within our portfolio.
  """
  defmodule Side do
    defmodule Long do
      defstruct [:long]
    end

    defmodule Short do
      defstruct [:short]
    end
  end

  @type t :: %Position{
          order_id: UUID.uuid4(),
          symbol: String.t(),
          price: float(),
          qty: integer(),
          side: Side
        }
  defstruct [:order_id, :symbol, :price, :qty, :side]

  def new_position(symbol, price, qty, side) do
    %__MODULE__{order_id: UUID.uuid4(), symbol: symbol, qty: qty, price: price, side: side}
  end
end
