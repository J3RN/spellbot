defmodule Spellbot.WordList do
  use GenServer
  import Exredis

  ## Client API

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def spelled_good?(server, word) do
    GenServer.call(server, {:member, word})
  end

  def get_count(server, word) do
    GenServer.call(server, {:lookup, word})
  end

  def set_word(server, word, value) do
    GenServer.call(server, {:update, word, value})
  end

  ## Server callbacks

  def init(:ok) do
    words_and_nums = start |> query ["HGETALL", "words"]
    loose_map = words_and_nums |> Enum.chunk(2) |> Enum.map(fn(x) ->
      {Enum.at(x, 0), String.to_integer(Enum.at(x, 1))}
    end)
    words = loose_map |> Enum.into(HashDict.new)

    {:ok, words}
  end

  def handle_call({:member, word}, _from, words) do
    {:reply, Enum.member?(HashDict.keys(words), word), words}
  end

  def handle_call({:lookup, word}, _from, words) do
    {:reply, HashDict.get(words, word), words}
  end

  def handle_call({:update, word, value}, _from, words) do
    {:reply, true, HashDict.put(words, word, value)}
  end
end
