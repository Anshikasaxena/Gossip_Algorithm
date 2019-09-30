defmodule Gossip do
  use GenServer

  def start_link([init_arg, nl]) do
    id = init_arg
    new_arg = 0
    # Check - if this works
    {:ok, _pid} = GenServer.start_link(__MODULE__, {new_arg, nl, init_arg}, name: :"#{id}")
  end

  def init({init_arg, nl, x}) do
    # node has s, w, oldRatios, done, neighbors, as it's state
    s = x
    w = 1
    ratio = s / w
    oldRatio = ratio

    {:ok, {init_arg, nl, s, w, ratio, oldRatio}}
  end

  def handle_call({:rumor}, _from, {init_arg, nl, s, w, ratio, oldRatio}) do
    IO.puts(" I heard rumor")
    new_state = init_arg + 1
    new_nl = nl

    if new_state > 3 do
      current = self()
      Start_Rounds.remove_me(current, new_nl)
    end

    {:reply, :ok, {new_state, new_nl, s, w, ratio, oldRatio}}
  end

  def handle_call({:RemoveMe, sender}, _from, {init_arg, nl, s, w, ratio, oldRatio}) do
    new_nl = List.delete(nl, sender)
    IO.puts("See i removed ya ")
    IO.inspect(new_nl)
    {:reply, :ok, {init_arg, new_nl, s, w, ratio, oldRatio}}
  end

  def handle_info(:timeout, _) do
    # Logger.info("shutting down")
    System.stop(0)
    {:stop, :normal, []}
  end
end
