defmodule TradingPlatform do
  require Logger

  @moduledoc """
  TradingPlatformDemo is a demo if a trading platforms event loop.
  This is just to have fun with elixir, dont use this in production.
  """
  @type message ::
          {:buy, String.t(), integer()}
          | {:sell, String.t(), integer()}
          | {:close, String.t(), integer()}
          | :stop

  @spec start() :: no_return()
  def start() do
    Logger.info("started trading platform")
    init_portfolio = Portfolio.new(50_000.0)
    event_loop(init_portfolio)
  end

  @spec event_loop(Portfolio.t()) :: no_return()
  def event_loop(portfolio) do
    price = Enum.random(8..12)

    receive do
      # Receive a buy event
      {:buy, symbol, qty} ->
        Logger.info("BUY #{symbol} #{qty} @ $#{price}")
        position = Position.new_position(symbol, price, qty, Position.Side.Long)
        updated_portfolio = Portfolio.add_position(portfolio, position)
        event_loop(updated_portfolio)

      # Receive a sell event
      {:sell, symbol, qty} ->
        Logger.info("SELL #{symbol} #{qty} @ $#{price}")
        position = Position.new_position(symbol, price, qty, Position.Side.Short)
        updated_portfolio = Portfolio.add_position(portfolio, position)
        event_loop(updated_portfolio)

      # Receive a close event
      {:close, symbol, qty} ->
        Logger.info("Received CLOSE order #{symbol} #{qty}")

        case Map.fetch(portfolio[:positions], symbol) do
          # For now, we just pop. will implement full portfolio balancing.
          {:ok, position} ->
            {_, new_positions} = Map.pop(portfolio[:positions], position)
            new_portfolio = Map.replace(portfolio, :positions, new_positions)
            event_loop(new_portfolio)

          :error ->
            Logger.error("NO position found to close for #{symbol}")
        end

        event_loop(portfolio)

      # Stop and exit
      :stop ->
        Logger.warning("Stopping event loop")
        :ok
    end
  end
end

# Testing stuff.
pid = spawn(TradingPlatform, :start, [])
send(pid, {:buy, "PTON", 100})
Process.sleep(500)
send(pid, {:buy, "SG", 230})
Process.sleep(500)
send(pid, {:buy, "CHWY", 56})
Process.sleep(500)
send(pid, {:sell, "PTON", 100})
Process.sleep(500)
send(pid, {:close, "PTON", 100})
Process.sleep(500)
send(pid, {:buy, "NVDA", 150})
send(pid, {:close, "SG", 230})
