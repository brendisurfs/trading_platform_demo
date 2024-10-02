defmodule Portfolio do
  @moduledoc """
  Portfolio holds the positions of the platform.
  """
  require Logger
  @behaviour Access
  @type t :: %Portfolio{capital: float(), equity: float(), positions: Map}
  defstruct [:capital, :equity, :positions]

  @spec new(float()) :: %__MODULE__{
          capital: float(),
          equity: float(),
          positions: Map
        }
  def new(capital) do
    %__MODULE__{capital: capital, equity: 0.0, positions: %{}}
  end

  @spec add_position(Portfolio.t(), Position.t()) :: Portfolio.t()
  def add_position(portfolio, position) do
    case Map.fetch(position, :symbol) do
      {:ok, symbol} ->
        Logger.debug("Found #{symbol}")
        new_positions = Map.put(portfolio[:positions], symbol, position)

        %__MODULE__{
          equity: portfolio[:equity],
          capital: portfolio[:capital],
          positions: new_positions
        }

      :error ->
        Logger.error("No symbol found")
        portfolio
    end
  end

  def fetch(term, key), do: Map.fetch(term, key)
  def pop(data, key), do: Map.get(data, key)
  def get_and_update(data, key, function), do: Map.get_and_update(data, key, function)
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
          order_id: UUID,
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
