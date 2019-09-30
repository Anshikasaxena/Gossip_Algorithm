defmodule Full_topology do
  def full_topology(node_num, rng) do
    # Produce a list of neighbors for the given specific node
    main_node = node_num
    nebhrs = Enum.filter(rng, fn x -> x != main_node end)
    nl = Enum.map(nebhrs, fn x -> :"#{x}" end)
  end
end
