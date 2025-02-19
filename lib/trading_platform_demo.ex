defmodule TradingPlatform do
  @moduledoc """
  TradingPlatformDemo is a demo if a trading platforms event loop.
  This is just to have fun with elixir, dont use this in production.
  """

  require Logger
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

        portfolio
        |> Portfolio.place_buy_order(symbol, price, qty)
        |> event_loop()

      # Receive a sell event
      {:sell, symbol, qty} ->
        Logger.info("SELL #{symbol} #{qty} @ $#{price}")

        portfolio
        |> Portfolio.place_sell_order(symbol, price, qty)
        |> event_loop()

      # Receive a close event
      {:close, symbol, qty} ->
        Logger.info("Received CLOSE order #{symbol} #{qty}")

        case Map.fetch(portfolio[:positions], symbol) do
          {:ok, _} ->
            portfolio |> Portfolio.close_position(symbol) |> event_loop()

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
Process.sleep(1000)
send(pid, :stop)
Process.sleep(1000)
