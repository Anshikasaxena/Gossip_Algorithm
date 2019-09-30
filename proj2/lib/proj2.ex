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
    topology = "Full"
    # Algorithm
    algo = "Gossip"

    # Starting the dynamic Server
    {:ok, _pid} = DySupervisor.start_link(1)
    IO.puts("Supervisor started")

    xyList = TwoDGridTopology.makeXYList(rng)
    IO.inspect(xyList, label: "xyList")

    newList = TwoDGridTopology.twoD_topology(xyList, rng)
    IO.inspect(newList, label: "newList")

    # Calling each child with its state variables
    for x <- rng do
      nl = []
      index = x - 1
      # first..last = rng
      # Use String.to_atom to store neighbors
      # nl = Full_topology.full_topology(x, rng)
      nl = TwoDGridTopology.twoDtop(index, rng, newList)
      IO.puts("Got nl")
      DySupervisor.start_child(nl, algo, x)
      IO.puts("Child started #{x}")
    end

    children = DynamicSupervisor.which_children(DySupervisor)
    IO.inspect(children)
    # Enum.each(children,fn x-> GenServer.cast(x,{:get_neig,})

    # Start the first message
    # A check if names have been assigned correctly
    :ok = GenServer.call(:"1", {:rumor})

    # Start the Rounds
    Start_Rounds.start_rounds(children)
  end
end
