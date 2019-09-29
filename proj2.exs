defmodule DySupervisor do
  use DynamicSupervisor

  def start_link(init_arg) do
    # IO.puts("Its here in DynamicSupervisor")
    {:ok, _pid} = DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def start_child(nl, algo, x, y, child) do
    if algo == "Gossip" do
      child_spec =
        Supervisor.child_spec({Gossip, [child, nl, x, y]}, id: child, restart: :temporary)
    end

    child_spec =
      Supervisor.child_spec({Gossip, [child, nl, x, y]}, id: child, restart: :temporary)

    # if algo == "Push-Sum" do
    # children = Supervisor.child_spec({Push - Sum, [x, 1, nl]}, id: x, restart: :temporary)
    # end

    {:ok, child} = DynamicSupervisor.start_child(__MODULE__, child_spec)
  end

  def init(init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end

defmodule Gossip do
  use GenServer

  def start_link([init_arg, nl, x, y]) do
    id = init_arg
    new_arg = 0
    # Check - if this works
    {:ok, _pid} = GenServer.start_link(__MODULE__, {new_arg, nl, x, y}, name: :"#{id}")
  end

  def init({init_arg, nl, x, y}) do
    {:ok, {init_arg, nl, x, y}}
  end

  def handle_call({:rumor}, _from, {init_arg, nl, x, y}) do
    IO.puts(" I heard rumor")
    new_state = init_arg + 1
    new_nl = nl

    if new_state > 3 do
      current = self()
      Start_Rounds.remove_me(current, new_nl)
    end

    {:reply, :ok, {new_state, new_nl, x, y}}
  end

  def handle_call({:RemoveMe, sender}, _from, {init_arg, nl, x, y}) do
    new_nl = List.delete(nl, sender)
    IO.puts("See i removed ya ")
    IO.inspect(new_nl)
    {:reply, :ok, {init_arg, new_nl, x, y}}
  end

  def handle_call({:addNeighbors, new_neighbors}, _from, {init_arg, nl, x, y}) do
    IO.inspect(new_neighbors, label: "New neighbor list")
    {:reply, :ok, {init_arg, new_neighbors, x, y}}
  end

  def handle_info(:timeout, _) do
    # Logger.info("shutting down")
    System.stop(0)
    {:stop, :normal, []}
  end

  def addNeighbors(server, new_neighbors) do
    GenServer.call(server, {:addNeighbors, new_neighbors})
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
          {init_arg, nl, x, y} = :sys.get_state(pidx)

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
              children = List.delete(children, x)

            # remove_me(pidx,nl)

            init_arg > 0 ->
              # pick a random neighbor and start sending message
              sendto = Enum.take_random(nl, 1)
              sendto = Enum.at(sendto, 0)
              IO.puts("I #{sender} am sending a message to #{sendto}")
              # Check - Possible error
              :ok = GenServer.call(sendto, {:rumor})

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
      {init_arg, nl, x, y} = :sys.get_state(pidx)

      if init_arg > 3 do
        IO.puts("Here i die ")
        IO.inspect(pidx)
        current = self()
        IO.puts("Its me cleaning up ")
        IO.inspect(current)
        # Check - Possible error
        # Dig in - Control not going ba
        :ok = DynamicSupervisor.terminate_child(DySupervisor, pidx)
        IO.puts("Its me cleaning up ")
      end
    end

    children = DynamicSupervisor.which_children(DySupervisor)
    IO.inspect(children)
    start_rounds(children)
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

defmodule TwoDGridTopology do
  def twoD_topology(child1_pid, sup_pid) do
    children = DynamicSupervisor.which_children(DySupervisor)

    {init_arg, nl, x1, y1} = :sys.get_state(child1_pid, :infinity)
    # IO.inspect(state)

    Enum.each(children, fn
      child2 ->
        {_a, child2_pid, _b, _c} = child2

        if(child1_pid != child2_pid) do
          {init_arg2, nl2, x2, y2} = :sys.get_state(child2_pid, :infinity)
          # IO.inspect(state2)
          # add neighbor if difference is < 1

          difference = difference(x1, y1, x2, y2)

          IO.inspect(difference, label: "difference is")

          if(difference <= 1) do
            values = Process.info(child2_pid)
            name = Enum.at(values, 0, nil)
            child_name = elem(name, 1)

            myneighbors = [child_name | nl]
            IO.inspect(myneighbors, label: "my new neighbor is:")
            # replace neighbors for twoD grid topology
            Gossip.addNeighbors(child1_pid, myneighbors)
          end
        end
    end)
  end

  def difference(x1, y1, x2, y2) do
    # d = sqrt((x2-x1)^2 + (y2-y1)^2)
    xDifference = x2 - x1
    xDifferenceSquared = :math.pow(xDifference, 2)
    yDifference = y2 - y1
    yDifferenceSquared = :math.pow(yDifference, 2)
    sum = xDifferenceSquared + yDifferenceSquared
    _d = :math.sqrt(sum)
  end
end

defmodule Honeycomb do
  def honeycomb_topo(node_num, rng) do
  end
end

# Main Application
num = 12
rng = Range.new(1, num)
# the topology of the network
topology = "Two"
# Algorithm
algo = "Gossip"

# Starting the dynamic Server
{:ok, pid} = DySupervisor.start_link(1)
IO.puts("Supervisor started")

# Calling each child with its state variables
for child <- rng do
  nl = []
  # first..last = rng
  # Use String.to_atom to store neighbors
  # nl = Full_topology.full_topology(x, rng)
  # IO.puts("Got nl")
  x = Enum.random(0..10)
  y = Enum.random(0..10)
  DySupervisor.start_child(nl, algo, x, y, child)

  IO.puts("Child started #{child}")
end

children = DynamicSupervisor.which_children(DySupervisor)
IO.inspect(children)

Enum.each(children, fn child ->
  {_, child_pid, _, _} = child
  nl = TwoDGridTopology.twoD_topology(child_pid, pid)
end)

children = DynamicSupervisor.which_children(DySupervisor)
IO.inspect(children)
# Enum.each(children,fn x-> GenServer.cast(x,{:get_neig,})

# Start the first message
# A check if names have been assigned correctly
:ok = GenServer.call(:"1", {:rumor})

# Start the Rounds
Start_Rounds.start_rounds(children)
