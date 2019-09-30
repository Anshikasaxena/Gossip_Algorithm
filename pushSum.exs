defmodule DySupervisor do
  use DynamicSupervisor

  def start_link(init_arg) do
    # IO.puts("Its here in DynamicSupervisor")
    {:ok, _pid} = DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def start_child(nl, algo, x) do
    # node has s, w, oldRatios, done, neighbors, as it's state
    child_spec = Supervisor.child_spec({PushSum, [x, nl]}, id: x, restart: :temporary)

    {:ok, child} = DynamicSupervisor.start_child(__MODULE__, child_spec)
  end

  def init(init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end

defmodule Full_topology do
  def full_topology(node_num, rng) do
    # Produce a list of neighbors for the given specific node
    main_node = node_num
    nebhrs = Enum.filter(rng, fn x -> x != main_node end)
    nl = Enum.map(nebhrs, fn x -> :"#{x}" end)
  end
end

defmodule PushSum do
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

  def handle_call({:rumor, message}, _from, {init_arg, nl, s, w, ratio, oldRatio}) do
    IO.puts(" I heard rumor")
    new_state = init_arg + 1
    new_nl = nl
    oldRatio = ratio
    # Upon receive, an actor should add received pair to its own corresponding values.
    {neighborS, neighborW} = message
    news = (s + neighborS) / 2
    neww = (w + neighborW) / 2
    newRatio = news / neww

    if new_state > 3 do
      current = self()
      # If an actor did not change more than 10^10 in 3 consecutive rounds the actor terminates
      difference = Float.round(newRatio - ratio, 11)

      if(abs(difference) < :math.pow(10, -10)) do
        Start_Rounds.remove_me(current, new_nl)
      else
        new_state = 1
      end
    end

    {:reply, :ok, {new_state, new_nl, news, neww, newRatio, oldRatio}}
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

defmodule Start_Rounds do
  def start_rounds(children) do
    if children == [] do
      # terminate
      # Check - might give error for few arguments
      IO.puts("Stopping the Supervisor")
      :ok = DynamicSupervisor.stop(DySupervisor)
      IO.puts("Uh oh ")
    else
      for x <- children do
        {_, pidx, _, _} = x

        if Process.alive?(pidx) do
          {init_arg, nl, s, w, ratio, oldRatio} = :sys.get_state(pidx)

          # IO.inspect(init_arg)

          values = Process.info(pidx)
          name = Enum.at(values, 0, nil)
          sender = elem(name, 1)
          # IO.inspect(sender)

          cond do
            nl == [] ->
              # Remove the process from the list of children
              IO.puts("Your neigbors are dead and so are you")
              children = List.delete(children, x)
              # Send a normal exit command
              # Check - Possible error
              IO.puts("My neighbors are dead , here i die ")
              :ok = DynamicSupervisor.terminate_child(DySupervisor, pidx)
              IO.inspect(children)
              childkilled = DynamicSupervisor.which_children(DySupervisor)
              IO.inspect(childkilled)

            init_arg > 3 ->
              # Remove the process from the list of children
              ## do here in start rounds
              # remove_me(pidx,nl)
              difference = Float.round(ratio - oldRatio, 11)

              if(abs(difference) < :math.pow(10, -10)) do
                children = List.delete(children, x)
              else
                # not sure what would go here
              end

            init_arg > 0 ->
              # pick a random neighbor and start sending message
              sendto = Enum.take_random(nl, 1)
              sendto = Enum.at(sendto, 0)
              message = {s, w}
              IO.puts("I #{sender} am sending a message to #{sendto}")
              # Check - Possible error
              :ok = GenServer.call(sendto, {:rumor, message})

            init_arg == 0 ->
              IO.puts("Nothing here")
          end
        else
          children = List.delete(children, x)
        end
      end

      kill_em()
      # start_rounds(children)
    end
  end

  def remove_me(pidx, nl) do
    values = Process.info(pidx)
    name = Enum.at(values, 0, nil)
    sender = elem(name, 1)

    IO.puts("Remove me #{sender} from your list")
    Enum.each(nl, fn x -> GenServer.call(x, {:RemoveMe, sender}) end)
    # Send a normal exit command
  end

  def kill_em do
    children = DynamicSupervisor.which_children(DySupervisor)

    for x <- children do
      {_, pidx, _, _} = x
      {init_arg, nl, s, w, ratio, oldRatio} = :sys.get_state(pidx)

      if init_arg > 3 do
        difference = Float.round(ratio - oldRatio, 11)

        if(abs(difference) < :math.pow(10, -10)) do
          IO.puts("Here i die ")
          IO.inspect(pidx)
          current = self()
          IO.puts("Its me cleaning up ")
          IO.inspect(current)
          # Check - Possible error
          # Dig in - Control not going ba
          :ok = DynamicSupervisor.terminate_child(DySupervisor, pidx)
          IO.puts("Its me cleaning up ")
        else
          # do nothing?
        end
      end
    end

    children = DynamicSupervisor.which_children(DySupervisor)
    IO.inspect(children)
    start_rounds(children)
  end
end

# Main Application
num = 12
rng = Range.new(1, num)
# the topology of the network
_topology = "Full"
# Algorithm
algo = "Gossip"

# Starting the dynamic Server
{:ok, _pid} = DySupervisor.start_link(1)
IO.puts("Supervisor started")

# xyList = TwoDGridTopology.makeXYList(rng)
# IO.inspect(xyList, label: "xyList")
#
# newList = TwoDGridTopology.twoD_topology(xyList, rng)
# IO.inspect(newList, label: "newList")

# Calling each child with its state variables
for x <- rng do
  _nl = []
  # first..last = rng
  # Use String.to_atom to store neighbors
  # nl = TwoDGridTopology.twoDtop(index, rng, newList)
  nl = Full_topology.full_topology(x, rng)
  IO.puts("Got nl")
  DySupervisor.start_child(nl, algo, x)
  IO.puts("Child started #{x}")
end

children = DynamicSupervisor.which_children(DySupervisor)
IO.inspect(children)
# Enum.each(children,fn x-> GenServer.cast(x,{:get_neig,})

# Start the first message
# A check if names have been assigned correctly
# first message
message = {1, 1}
:ok = GenServer.call(:"1", {:rumor, message})

# Start the Rounds
Start_Rounds.start_rounds(children)
