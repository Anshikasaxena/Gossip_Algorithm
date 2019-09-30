defmodule Gossip do
  use GenServer

  def start_link([init_arg, nl]) do
    id = init_arg
    new_arg = 0
    # Check - if this works
    {:ok, _pid} = GenServer.start_link(__MODULE__, {new_arg, nl}, name: :"#{id}")
  end

  def init({init_arg, nl}) do
    {:ok, {init_arg, nl}}
  end

  def handle_call({:rumor}, _from, {init_arg, nl}) do
    IO.puts(" I heard rumor")
    new_state = init_arg + 1
    new_nl = nl

    if new_state > 3 do
      current = self()
      Start_Rounds.remove_me(current, new_nl)
    end

    {:reply, :ok, {new_state, new_nl}}
  end

  def handle_call({:RemoveMe, sender}, _from, {init_arg, nl}) do
    new_nl = List.delete(nl, sender)
    IO.puts("See i removed ya ")
    IO.inspect(new_nl)
    {:reply, :ok, {init_arg, new_nl}}
  end

  def handle_info(:timeout, _) do
    # Logger.info("shutting down")
    System.stop(0)
    {:stop, :normal, []}
  end
end
