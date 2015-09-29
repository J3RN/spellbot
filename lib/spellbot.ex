defmodule Spellbot do
  use Application

  def start(_type, _args) do
    Spellbot.Supervisor.start_link
  end
end

defmodule Spellbot.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    {:ok, client} = ExIrc.start_client!
    {:ok, word_list} = Spellbot.WordList.start_link

    children = [
      worker(Spellbot.ConnectionHandler, [client]),
      worker(Spellbot.LoginHandler, [client, ["#bottest"]]),
      worker(Spellbot.MessageHandler, [client, word_list]),
      worker(Spellbot.WordList, []),
    ]

    opts = [strategy: :one_for_one, name: Spellbot.Supervisor]
    supervise(children, opts)
  end
end

