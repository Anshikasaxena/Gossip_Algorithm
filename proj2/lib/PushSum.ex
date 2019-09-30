defmodule PushSum do
  use GenServer

  def start_link([init_arg, nl]) do
    id = init_arg
    new_arg = 0
    # Check - if this works
    {:ok, _pid} = GenServer.start_link(__MODULE__, {new_arg, nl, init_arg}, name: :"#{id}")
  end

  def init({num_heard, nl, x}) do
    # node has s, w, oldRatios, done, neighbors, as it's state
    s = x
    w = 1
    ratio = s / w
    oldRatio = ratio

    {:ok, {num_heard, nl, s, w, ratio, oldRatio}}
  end

  def handle_call({:rumor, message}, _from, {num_heard, nl, s, w, ratio, oldRatio}) do
    IO.puts("In PushSum I heard the rumor")
    new_state = num_heard + 1
    new_nl = nl
    oldRatio = ratio

    # Upon receive, an actor should add received pair to its own corresponding values.
    {neighborS, neighborW} = message
    news = (s + neighborS) / 2
    neww = (w + neighborW) / 2
    newRatio = news / neww

    if new_state > 3 do
      # If an actor did not change more than 10^10 in 3 consecutive rounds the actor terminates
      difference = Float.round(newRatio - oldRatio, 11)

      if(abs(difference) < :math.pow(10, -10)) do
        current = self()
        Start_Rounds.remove_me(current, new_nl)
        {:reply, :ok, {new_state, new_nl, news, neww, newRatio, oldRatio}}
      else
        new_state = 0
        IO.inspect(self(), label: "I'm resetting state because my difference was #{difference}")
        {:reply, :ok, {new_state, new_nl, news, neww, newRatio, oldRatio}}
      end
    else
      {:reply, :ok, {new_state, new_nl, news, neww, newRatio, oldRatio}}
    end
  end

  def handle_call({:RemoveMe, sender}, _from, {num_heard, nl, s, w, ratio, oldRatio}) do
    new_nl = List.delete(nl, sender)
    IO.puts("See i removed ya ")
    IO.inspect(new_nl)
    {:reply, :ok, {num_heard, new_nl, s, w, ratio, oldRatio}}
  end

  def handle_info(:timeout, _) do
    # Logger.info("shutting down")
    System.stop(0)
    {:stop, :normal, []}
  end
end
