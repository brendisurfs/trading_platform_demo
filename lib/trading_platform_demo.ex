defmodule TradingPlatform do
  require Logger

  @moduledoc """
  TradingPlatformDemo is a demo if a trading platforms event loop.
  This is just to have fun with elixir, dont use this in production.
  """

  def start() do
    Logger.info("started trading platform")
    init_state = Portfolio.new()
    event_loop(init_state)
  end

  @spec event_loop(Portfolio.t()) :: nil
  def event_loop(positions) do
    receive do
      # Receive a buy event
      {:buy, symbol, qty} ->
        # random num generator for faking price while we build.
        price = Enum.random(8..12)
        Logger.info("Received BUY order #{symbol} #{qty} for $#{price}")

        position = Position.new_position(symbol, price, qty, Position.Side.Long)
        new_positions = Portfolio.add_position(positions, position)
        event_loop(new_positions)

      # Receive a sell event
      {:sell, symbol, qty} ->
        Logger.info("Received SELL order #{symbol} #{qty}")

        price = Enum.random(8..12)
        position = Position.new_position(symbol, price, qty, Position.Side.Short)
        new_positions = Portfolio.add_position(positions, position)
        event_loop(new_positions)

      # Receive a close event
      {:close, symbol, qty} ->
        Logger.info("Received CLOSE order #{symbol} #{qty}")

        case Map.fetch(positions, symbol) do
          # For now, we just pop. will implement full portfolio balancing.
          {:ok, position} ->
            {_, new_positions} = Map.pop(positions, position)
            event_loop(new_positions)

          :error ->
            Logger.error("NO position found to close for #{symbol}")
        end

        event_loop(positions)

      # Stop and exit
      :stop ->
        IO.puts("Stopping event loop")
        :ok
    end
  end
end

pid = spawn(TradingPlatform, :start, [])
Process.sleep(1000)
send(pid, {:buy, "PTON", 100})
send(pid, {:buy, "SG", 230})
send(pid, {:buy, "CHWY", 56})
send(pid, {:sell, "PTON", 100})
send(pid, {:close, "PTON", 100})
Process.sleep(1000)
send(pid, {:buy, "NVDA", 150})
send(pid, {:close, "SG", 230})
Process.sleep(1000)
