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
    rng = Range.new(1, num)
    # the topology of the network
    topology = Enum.at(argv, 1)
    # Algorithm
    algo = Enum.at(argv, 2)

    # Starting the dynamic Server
    {:ok, _pid} = DySupervisor.start_link(1)
    IO.puts("Supervisor started")

    # create xyList before anything even starts if needed
    neighborsLists = TwoDGridTopology.makeTwoDTopology(rng)

    # Calling each child with its state variables
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
          IO.inspect(nl, label: "Got nl")
          DySupervisor.start_child(nl, algo, x)
          IO.puts("Child started #{x}")

        "twoD" ->
          nl = TwoDGridTopology.twoDtop(index, neighborsLists)
          IO.inspect(nl, label: "NeighborsList is")
          DySupervisor.start_child(nl, algo, x)
          IO.puts("Child started #{x}")

        "threeD" ->
          nl = ThreeD.threeD_topology(num)
          IO.inspect(nl, label: "Got nl")
          DySupervisor.start_child(nl, algo, x)
          IO.puts("Child started #{x}")

        _ ->
          IO.puts("Incorrect topology type")
          # TO DO: Program should stop here...
      end
    end

    children = DynamicSupervisor.which_children(DySupervisor)
    IO.inspect(children)

    # Start the first message
    :ok = GenServer.call(:"1", {:rumor})

    # Start the Rounds
    Start_Rounds.start_rounds(children)
  end
end
