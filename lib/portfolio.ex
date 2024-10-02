defmodule Portfolio do
  @moduledoc """
  Portfolio holds the positions of the platform.
  """
  @enforce_keys [:positions]
  defstruct [:positions]

  @type t :: %__MODULE__{
          positions: Map
        }

  @spec new() :: Portfolio.t()
  def new do
    %{}
  end

  @spec add_position(Portfolio.t(), String.t(), Position.t()) :: Portfolio.t()
  def add_position(state, symbol, position) do
    Map.put(state, symbol, position)
  end
end

defmodule Position do
  @moduledoc """
  defines a position within our portfolio.
  """
  @type t :: %Position{symbol: String.t(), price: float(), qty: integer()}
  defstruct [:symbol, :price, :qty]
end
