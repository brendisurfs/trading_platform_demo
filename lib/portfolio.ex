defmodule Portfolio do
  @moduledoc """
  Portfolio holds the positions of the platform.
  """

  require Logger

  @behaviour Access
  defstruct [:capital, :equity, :positions]

  @type t :: %__MODULE__{capital: float(), equity: float(), positions: %{}}

  @doc """
  creates a new Portfolio
  """
  @spec new(capital :: float()) :: t()
  def new(capital) do
    %__MODULE__{capital: capital, equity: 0.0, positions: %{}}
  end

  @doc """
    adds a position to the Portfolio
  """
  @spec add_position(portfolio :: t(), position :: Position.t()) :: t()
  def add_position(portfolio, position) do
    symbol = position[:symbol]
    Logger.debug("#{symbol} order_id: #{position[:order_id]}")
    new_positions = Map.put(portfolio[:positions], symbol, position)
    %{portfolio | positions: new_positions}
  end

  # TODO: Remove Position 
  @spec remove_position(portfolio :: t(), symbol :: String.t()) :: term()
  def remove_position(portfolio, symbol) do
    IO.puts("Todo: remove position")
  end

  def fetch(term, key), do: Map.fetch(term, key)
  def pop(data, key), do: Map.get(data, key)
  def get_and_update(data, key, function), do: Map.get_and_update(data, key, function)
end

defmodule Position do
  @moduledoc """
  defines a position within our portfolio.
  """

  require Logger

  @behaviour Access
  defstruct [:order_id, :symbol, :price, :qty, :side]

  @type t :: %__MODULE__{
          order_id: UUID,
          symbol: String.t(),
          price: float(),
          qty: integer(),
          side: Side
        }

  @type position_side :: :long | :short
  @doc """
  new makes a new order, adding an order_id (UUID) to it.
  """
  @spec new(String.t(), float(), integer(), position_side()) :: t()
  def new(symbol, price, qty, side) do
    %__MODULE__{order_id: UUID.uuid4(), symbol: symbol, qty: qty, price: price, side: side}
  end

  def pop(data, key), do: Map.pop(data, key)
  def fetch(term, key), do: Map.fetch(term, key)
  def get_and_update(data, key, function), do: Map.get_and_update(data, key, function)
end
