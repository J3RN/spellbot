defmodule Spellbot.MessageHandler do
  @moduledoc """
  This module is responsible for responding to all user messages.
  """

  def start_link(client, word_list) do
    GenServer.start_link(__MODULE__, [client, word_list])
  end

  def init([client, word_list]) do
    ExIrc.Client.add_handler client, self
    {:ok, [client, word_list]}
  end

  def handle_info({:received, msg, nick, channel}, [client, word_list]) do
    IO.puts "#{nick} #{channel}: #{msg}"

    if Regex.match?(~r/spell: .*/, msg) do
      trimmed = Regex.replace(~r/spell: /, msg, "")
      words = List.flatten(Regex.scan(~r/[\w']+/, trimmed))

      bad = Enum.filter(words, fn(word) ->
        ! Spellbot.WordList.spelled_good?(word_list, word)
      end)

      if Enum.any? bad do
        ExIrc.Client.msg(client, :privmsg, channel, "#{Enum.join(bad, ", ")} is spelled wrong")
      else
        ExIrc.Client.msg(client, :privmsg, channel, "Looks good to me!")
      end
    end


    {:noreply, [client, word_list]}
  end

  def handle_info({:received, msg, nick}, state) do
    IO.puts "#{nick}: #{msg}"

    {:noreply, state}
  end

  # Catch-all
  def handle_info(_, state) do
    {:noreply, state}
  end
end
