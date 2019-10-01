defmodule Proj2 do
  @moduledoc """
  Documentation for Proj2.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Proj2.hello()
      :world

  """
  def hello do
    :world
  end

  def main(argv) do
    # Main Application
    # Enum.at(argv, 0) is numNodes
    # Enum.at(argv, 1) is topology
    # Enum.at(argv, 2) is algorithm

    num = String.to_integer(Enum.at(argv, 0))
    # Topology of the network
    topology = Enum.at(argv, 1)

    # Algorithm
    algo = Enum.at(argv, 2)

    # Range of GenServers
    rng = Range.new(1, num)

    # Starting the dynamic Server
    {:ok, _pid} = DySupervisor.start_link(1)
    IO.puts("Supervisor started")

    # create neighborLists before anything even starts if needed
    neighborsLists2 = TwoDGridTopology.makeTwoDTopology(rng)
    neighborsLists3 = ThreeD.threeD_topology(num)

    # Calling each child with its state variables
    # rng has to round if Top is 3D
    if topology != "threeD" do
      # for x <- rng do
      #   nl = []
      #   index = x - 1

      # get neighbor list depending on topology
      case topology do
        #   "Line" ->
        #     nl = Line_topology.line_topology(x, rng)
        #     IO.inspect(nl, label: "Line NeighborsList is")
        #     DySupervisor.start_child(nl, algo, x)
        #     IO.puts("Child started #{x}")
        #
        #   "Full" ->
        #     nl = Full_topology.full_topology(x, rng)
        #     IO.inspect(nl, label: "Full Neighbor List")
        #     DySupervisor.start_child(nl, algo, x)
        #     IO.puts("Child started #{x}")
        #
        #   "twoD" ->
        #     nl = TwoDGridTopology.twoDtop(index, neighborsLists2)
        #     IO.inspect(nl, label: "2D NeighborsList is")
        #     DySupervisor.start_child(nl, algo, x)
        #     IO.puts("Child started #{x}")

        "Honeycomb" ->
          poc = {}
          mode = 0
          first..last = rng
          new_x = 0
          Honeycomb.get_nl(rng, poc, mode, new_x, last, algo)

        _ ->
          IO.puts("Incorrect topology type")
          # TO DO: Program should stop here...
      end

      # end
    else
      newRangeNum = ThreeD.roundUp(num)
      # Range of GenServers
      rng = Range.new(1, newRangeNum)

      for x <- rng do
        nl = []
        index = x - 1
        nl = ThreeD.threeDtop(index, neighborsLists3)
        IO.inspect(nl, label: "3D NeighborsList is")
        DySupervisor.start_child(nl, algo, x)
        IO.puts("Child started #{x}")
      end
    end

    children = DynamicSupervisor.which_children(DySupervisor)
    IO.inspect(children)

    # Start the first message
    if algo == "Gossip" do
      :ok = GenServer.call(:"1", {:rumor})
    else
      message = {1, 1}
      :ok = GenServer.call(:"1", {:rumor, message})
    end

    # Start the Rounds
    percent_nodes = num - round(0.90 * num)
    Start_Rounds.start_rounds(children, algo, percent_nodes)
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
                # {init_arg, attach_node_nl} = :sys.get_state(attach_node)
                state = :sys.get_state(attach_node)
                IO.inspect(state)
                init_arg = elem(state, 0)
                attach_node_nl = elem(state, 1)
                # s = elem(state, 2)
                # w = elem(state, 3)
                # newRatio = elem(state, 4)
                # oldRatio = elem(state, 5)

                IO.puts("UHOH")
                IO.inspect(attach_node_nl, label: "Attach node nl")
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
                # {init_arg, attach_node_nl} = :sys.get_state(attach_node)
                state = :sys.get_state(attach_node)
                init_arg = elem(state, 0)
                nl = elem(state, 1)
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
                # {_, attach_node_nl} = :sys.get_state(attach_node_1)
                state = :sys.get_state(attach_node_1)
                init_arg = elem(state, 0)
                attach_node_nl = elem(state, 1)

                :ok = GenServer.call(node_name, {:update_nl, attach_node_1})
                :ok = GenServer.call(attach_node_1, {:update_nl, node_name})
                :ok = GenServer.call(node_name, {:update_nl, attach_node_2})
                :ok = GenServer.call(attach_node_2, {:update_nl, node_name})
                # {init_arg, attach_node_nl} = :sys.get_state(attach_node_1)
                state = :sys.get_state(attach_node_1)
                init_arg = elem(state, 0)
                attach_node_nl = elem(state, 1)

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
