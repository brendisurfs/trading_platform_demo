defmodule Position do
  @moduledoc """
  defines a position within our portfolio.
  """
  @type t :: %Position{symbol: String.t(), price: float(), qty: integer()}

  defstruct [:symbol, :price, :qty]
end

defmodule Portfolio do
  @moduledoc """
  Portfolio holds the positions of the platform.
  """
  @type t :: %Position{}

  @spec add_position(Portfolio.t(), String.t(), Position.t()) :: Portfolio.t()
  def add_position(state, symbol, position) do
    Map.put(state, symbol, position)
  end
end

defmodule TradingPlatform do
  require Logger

  @moduledoc """
  TradingPlatformDemo is a demo if a trading platforms event loop.
  This is just to have fun with elixir, dont use this in production.
  """
  def start() do
    Logger.info("started trading platform")
    init_state = %{}
    event_loop(init_state)
  end

  @spec event_loop(Portfolio.t()) :: term()
  def event_loop(state) do
    receive do
      # Receive a buy event
      {:buy, symbol, qty, reply_to} ->
        price = Enum.random(8..12)
        Logger.info("Received BUY order #{symbol} #{qty} for $#{price}")

        pos = %Position{symbol: symbol, price: price, qty: qty}
        new_state = Portfolio.add_position(state, symbol, pos)
        IO.inspect(new_state)

        send(reply_to, {:ok, "succesful order"})
        event_loop(new_state)

      # Receive a sell event
      {:sell, symbol, qty, reply_to} ->
        Logger.info("Received SELL order #{symbol} #{qty}")
        send(reply_to, {:ok, "succesful order"})
        event_loop(state)

      :stop ->
        IO.puts("Stopping event loop")
        # Stop and exit
        :ok
    end
  end
end
