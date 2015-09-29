defmodule Spellbot.ConnectionHandler do
  @moduledoc """
  This module is responsible for setting up the connection
  """

  defmodule State do
    defstruct host: "chat.freenode.net",
              port: 6667,
              pass: "",
              nick: "spelltest",
              user: "spelltest",
              name: "Jonathan Arnett",
              client: nil
  end

  def start_link(client, state \\ %State{}) do
    GenServer.start_link(__MODULE__, [%{state | client: client}])
  end

  def init([state]) do
    ExIrc.Client.add_handler state.client, self
    ExIrc.Client.connect! state.client, state.host, state.port
    {:ok, state}
  end

  def handle_info({:connected, server, port}, state) do
    debug "Connected to #{server}:#{port}"
    ExIrc.Client.logon state.client, state.pass, state.nick, state.user, state.name
    {:noreply, state}
  end

  def handle_info({:unrecognized, code, msg}, state) do
    args = Map.get(Map.from_struct(msg), :args)
    IO.puts Enum.at(args, 1)

    {:noreply, state}
  end

  # Catch-all for messages you don't care about
  def handle_info(msg, state) do
    {:noreply, state}
  end

  defp debug(msg) do
    IO.puts IO.ANSI.yellow() <> msg <> IO.ANSI.reset()
  end
end
