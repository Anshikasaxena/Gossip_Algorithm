defmodule DySupervisor do
  use DynamicSupervisor

  def start_link(init_arg) do
    # IO.puts("Its here in DynamicSupervisor")
    {:ok, _pid} = DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def start_child(nl, algo, x) do
    if algo == "Gossip" do
      child_spec = Supervisor.child_spec({Gossip, [x, nl]}, id: x, restart: :temporary)
    end

    child_spec = Supervisor.child_spec({Gossip, [x, nl]}, id: x, restart: :temporary)
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

  def handle_call({:update_nl, x}, _from, {init_arg, nl}) do
    new_nl = nl ++ [x]
    IO.puts("updating ..")
    IO.inspect(new_nl)
    {:reply, :ok, {init_arg, new_nl}}
  end

  def handle_info(:timeout, _) do
    # Logger.info("shutting down")
    System.stop(0)
    {:stop, :normal, []}
  end
end

defmodule Start_Rounds do
  def start_rounds(children, percent_nodes) do
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
          {init_arg, nl} = :sys.get_state(pidx)

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

      kill_em(percent_nodes)
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

  def kill_em(percent_nodes) do
    children = DynamicSupervisor.which_children(DySupervisor)

    for x <- children do
      {_, pidx, _, _} = x
      {init_arg, nl} = :sys.get_state(pidx)

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

    # Another terminating condition
    children = DynamicSupervisor.which_children(DySupervisor)
    IO.inspect(children)
    children_alive = length(children)

    if children_alive <= percent_nodes do
      IO.puts("Stopping the Supervisor cause most are dead")
      :ok = DynamicSupervisor.stop(DySupervisor)
    else
      start_rounds(children, percent_nodes)
    end
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

defmodule Honeycomb do
  def honeycomb_topo(node_num, poc, mode) do
    node_name = :"#{node_num}"

    values =
      cond do
        node_num <= 6 ->
          poc =
            cond do
              # First node 
              poc == {} ->
                IO.puts("Here")
                poc = Tuple.append(poc, node_name)

              node_num == 6 ->
                nl1 = elem(poc, 0)
                nl2 = elem(poc, 4)
                IO.puts("Me #{node_name}")
                :ok = GenServer.call(node_name, {:update_nl, nl1})
                :ok = GenServer.call(node_name, {:update_nl, nl2})
                IO.puts("Me #{nl1}")
                :ok = GenServer.call(nl1, {:update_nl, node_name})
                IO.puts("Me #{nl2}")
                :ok = GenServer.call(nl2, {:update_nl, node_name})
                poc = Tuple.append(poc, node_name)

              # Every other node 
              true ->
                nebhr = node_num - 1
                nl = :"#{nebhr}"
                IO.puts("Me #{node_name}")
                :ok = GenServer.call(node_name, {:update_nl, nl})
                IO.puts("Me #{nl}")
                :ok = GenServer.call(nl, {:update_nl, node_name})
                poc = Tuple.append(poc, node_name)
            end

          IO.puts("Values at the end of n<6")
          values = {poc = poc, mode = mode}
          IO.inspect(values)

        node_num > 6 ->
          # Main players 
          values =
            cond do
              mode == 0 ->
                IO.puts("In greater than 7")
                # IO.inspect(poc)
                attach_node = elem(poc, 0)
                # IO.inspect(attach_node)
                # IO.puts("HONEY")
                {init_arg, attach_node_nl} = :sys.get_state(attach_node)
                IO.puts("UHOH")
                nn1 = String.to_integer(Atom.to_string(Enum.at(attach_node_nl, 0)))
                nn2 = String.to_integer(Atom.to_string(Enum.at(attach_node_nl, 1)))
                IO.puts("HI")

                value =
                  cond do
                    nn1 <= nn2 ->
                      attach_node_nn1 = Enum.at(attach_node_nl, 0)
                      attach_node_nn2 = Enum.at(attach_node_nl, 1)
                      value = {attach_node_nn1, attach_node_nn2}

                    nn1 > nn2 ->
                      attach_node_nn1 = Enum.at(attach_node_nl, 1)
                      attach_node_nn2 = Enum.at(attach_node_nl, 0)
                      value = {attach_node_nn1, attach_node_nn2}
                  end

                {attach_node_nn1, attach_node_nn2} = value
                IO.puts("ALL WELL ")

                mode =
                  cond do
                    attach_node_nn1 in Tuple.to_list(poc) ->
                      mode = 3

                    attach_node_nn2 in Tuple.to_list(poc) ->
                      mode = 2

                    true ->
                      mode = 1
                  end

                # IO.puts("My first call")
                :ok = GenServer.call(node_name, {:update_nl, attach_node})
                # IO.puts("My second call")
                :ok = GenServer.call(attach_node, {:update_nl, node_name})
                IO.puts("Done")
                {init_arg, attach_node_nl} = :sys.get_state(attach_node)
                # g = length(attach_node_nl)
                # IO.inspect(g)

                poc =
                  if length(attach_node_nl) >= 3 do
                    # check if it needs to be stored 
                    poc = Tuple.delete_at(poc, 0)
                  else
                    poc = poc
                  end

                poc = Tuple.append(poc, node_name)
                values = {poc = poc, mode = mode}

              # LOOP OVER 
              mode == 1 ->
                mode = 0
                attach_node_1 = elem(poc, 0)
                # Get the last element 
                attach_node_2 = elem(poc, tuple_size(poc) - 1)
                {_, attach_node_nl} = :sys.get_state(attach_node_1)
                :ok = GenServer.call(node_name, {:update_nl, attach_node_1})
                :ok = GenServer.call(attach_node_1, {:update_nl, node_name})
                :ok = GenServer.call(node_name, {:update_nl, attach_node_2})
                :ok = GenServer.call(attach_node_2, {:update_nl, node_name})
                {init_arg, attach_node_nl} = :sys.get_state(attach_node_1)

                poc =
                  if length(attach_node_nl) >= 3 do
                    poc = put_elem(poc, 0, node_name)
                  else
                    poc = poc
                  end

                values = {poc = poc, mode = mode}

              true ->
                mode = mode - 1
                attach_node = elem(poc, tuple_size(poc) - 1)
                :ok = GenServer.call(node_name, {:update_nl, attach_node})
                :ok = GenServer.call(attach_node, {:update_nl, node_name})
                poc = Tuple.append(poc, node_name)
                values = {poc = poc, mode = mode}
            end

          values = values
      end

    IO.puts("values at the end ")
    IO.inspect(values)
    values = values
  end

  def get_nl(rng, poc, mode, new_x, last, algo) when last == new_x do
    nl = []
    x = new_x
    DySupervisor.start_child(nl, algo, x)
    IO.puts("Child started #{x}")
    IO.inspect(poc)
    IO.inspect(mode)
    values = Honeycomb.honeycomb_topo(x, poc, mode)
    # IO.inspect(poc)
  end

  def get_nl(rng, poc, mode, new_x, last, algo) do
    # Everybody starts with empty nl
    first..last = rng
    x = first
    new_x = x + 1
    nl = []
    # IO.inspect(poc)
    # start the child with empty nl 
    DySupervisor.start_child(nl, algo, x)
    IO.puts("Child started #{x}")
    IO.inspect(poc)
    IO.inspect(mode)
    values = Honeycomb.honeycomb_topo(x, poc, mode)
    {poc, mode} = values
    rng = Range.new(new_x, last)

    get_nl(rng, poc, mode, new_x, last, algo)
  end
end

# Main Application  
num = 1200
percent_nodes = num - round(0.90 * num)
rng = Range.new(1, num)
# the topology of the network 
topology = "Honeycomb"
# Algorithm 
algo = "Gossip"

# Starting the dynamic Server
{:ok, pid} = DySupervisor.start_link(1)
IO.puts("Supervisor started")

# Calling each child with its state variables
if topology == "Full" do
  for x <- rng do
    nl = []
    # first..last = rng
    # Use String.to_atom to store neighbors
    nl = Full_topology.full_topology(x, rng)
    IO.puts("Got nl")
    DySupervisor.start_child(nl, algo, x)
    IO.puts("Child started #{x}")
  end
end

if topology == "Honeycomb" do
  poc = {}
  mode = 0
  first..last = rng
  new_x = 0
  Honeycomb.get_nl(rng, poc, mode, new_x, last, algo)
end

children = DynamicSupervisor.which_children(DySupervisor)
IO.inspect(children)
# Enum.each(children,fn x-> GenServer.cast(x,{:get_neig,})

# Start the first message 
# A check if names have been assigned correctly 
:ok = GenServer.call(:"1", {:rumor})

# Start the Rounds 
Start_Rounds.start_rounds(children, percent_nodes)
