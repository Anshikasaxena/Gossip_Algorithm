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
      for x <- rng do
        nl = []
        index = x - 1

        # get neighbor list depending on topology
        case topology do
          "Line" ->
            nl = Line_topology.line_topology(x, rng)
            IO.inspect(nl, label: "Line NeighborsList is")
            DySupervisor.start_child(nl, algo, x)
            IO.puts("Child started #{x}")

          "Full" ->
            nl = Full_topology.full_topology(x, rng)
            IO.inspect(nl, label: "Full Neighbor List")
            DySupervisor.start_child(nl, algo, x)
            IO.puts("Child started #{x}")

          "twoD" ->
            nl = TwoDGridTopology.twoDtop(index, neighborsLists2)
            IO.inspect(nl, label: "2D NeighborsList is")
            DySupervisor.start_child(nl, algo, x)
            IO.puts("Child started #{x}")

          _ ->
            IO.puts("Incorrect topology type")
            # TO DO: Program should stop here...
        end
      end
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
    Start_Rounds.start_rounds(children, algo)
  end
end
