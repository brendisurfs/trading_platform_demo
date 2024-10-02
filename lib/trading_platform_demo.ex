defmodule TradingPlatform do
  @moduledoc """
  TradingPlatformDemo is a demo if a trading platforms event loop.
  This is just to have fun with elixir, dont use this in production.
  """

  require Logger
  require Position
  require Portfolio

  @type message ::
          {:buy, String.t(), integer()}
          | {:sell, String.t(), integer()}
          | {:close, String.t(), integer()}
          | :stop

  @doc """
  starts the main event loop
  """
  def start() do
    Logger.info("started trading platform")
    Portfolio.new(50_000.0) |> event_loop()
  end

  @doc """
  handles the main event loop of receiving/closing orders
  """
  @spec event_loop(Portfolio.t()) :: :ok
  def event_loop(portfolio) do
    price = Enum.random(8..12)

    receive do
      # Receive a buy event
      {:buy, symbol, qty} ->
        Logger.info("BUY #{symbol} #{qty} @ $#{price}")
        new_position = Position.new(symbol, price, qty, :long)

        portfolio
        |> Portfolio.add_position(new_position)
        |> event_loop()

      # Receive a sell event
      {:sell, symbol, qty} ->
        Logger.info("SELL #{symbol} #{qty} @ $#{price}")

        new_position = Position.new(symbol, price, qty, :short)

        portfolio
        |> Portfolio.add_position(new_position)
        |> event_loop()

      # Receive a close event
      {:close, symbol, qty} ->
        Logger.info("Received CLOSE order #{symbol} #{qty}")

        case Map.fetch(portfolio[:positions], symbol) do
          # For now, we just pop. will implement full portfolio balancing.
          {:ok, position} ->
            {_, new_positions} = Map.pop(portfolio[:positions], position)
            Map.replace(portfolio, :positions, new_positions) |> event_loop()

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
send(pid, {:buy, "SG", 230})
send(pid, {:buy, "CHWY", 56})
send(pid, {:sell, "PTON", 100})
send(pid, {:close, "PTON", 100})
send(pid, {:buy, "NVDA", 150})
send(pid, {:close, "SG", 230})
