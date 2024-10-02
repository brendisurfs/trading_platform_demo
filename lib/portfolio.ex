defmodule Portfolio do
  @moduledoc """
  Portfolio holds the positions of the platform.
  """

  require Logger

  @behaviour Access
  defstruct [:capital, :equity, :positions]
  @type t :: %__MODULE__{capital: float(), equity: float(), positions: %{}}

  @doc """
  creates a new Portfolio.

  ## Parameters

  `capital`: the starting capital allocated for this Portfolio (float).

  ## Returns
  A new Portfolio struct.
  """
  @spec new(capital :: float()) :: t()

  def new(capital) do
    %__MODULE__{capital: capital, equity: 0.0, positions: %{}}
  end

  def place_buy_order(portfolio, symbol, price, qty) do
    position = Position.new(symbol, price, qty, :long)
    new_positions = Map.put(portfolio[:positions], symbol, position)
    %{portfolio | positions: new_positions}
  end

  def place_sell_order(portfolio, symbol, price, qty) do
    position = Position.new(symbol, price, qty, :short)
    new_positions = Map.put(portfolio[:positions], symbol, position)
    %{portfolio | positions: new_positions}
  end

  @doc """
    adds a position to the Portfolio

  ## Arguments 
  `portfolio`: the Portfolio where the positions are held (Portfolio).
  `position`: The new position we want to add to the Portfolio (Position).

  ## Returns 
  A new Portfolio struct with updated_positions.
  """
  @spec add_position(portfolio :: t(), position :: Position.t()) :: t()

  def add_position(portfolio, position) do
    symbol = position[:symbol]
    Logger.debug("#{symbol} order_id: #{position[:order_id]}")
    new_positions = Map.put(portfolio[:positions], symbol, position)
    %{portfolio | positions: new_positions}
  end

  @doc """
  "Closes" a position in Portfolio.

  ## Parameters:

  `portfolio`: the Portfolio where the positions are held (Portfolio).
  `symbol`: the ticker symbol belonging to the position we want to remove (String or atom).
  """
  @spec close_position(portfolio :: t(), symbol :: String.t()) :: term()

  # TODO: Remove Position 
  def close_position(portfolio, symbol) do
    {_, new_positions} = Map.pop(portfolio[:positions], symbol)
    Map.replace(portfolio, :positions, new_positions)
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

  @typedoc """
  defines the side our position is on.
  """
  @type side :: :long | :short

  @spec new(symbol :: String.t(), price :: float(), qty :: integer(), side :: side()) :: t()
  @doc """
  Creates a new position.

  ## Parameters:

  * `symbol`: The stock symbol (atom or string).
  * `price`: The price per share (float).
  * `qty`: The quantity of shares (integer).
  * `side`: The side of the trade, either :long or :short (atom).

  ## Returns:
  A new Position struct.
  """
  def new(symbol, price, qty, side) do
    %__MODULE__{order_id: UUID.uuid4(), symbol: symbol, qty: qty, price: price, side: side}
  end

  def pop(data, key), do: Map.pop(data, key)
  def fetch(term, key), do: Map.fetch(term, key)
  def get_and_update(data, key, function), do: Map.get_and_update(data, key, function)
end
