defmodule ThreeD do
  def threeD_topology(num) do
    # given edge build a cube with that many layers which has n*n nodes
    edge = Kernel.trunc(Float.ceil(:math.pow(num, 1 / 3)))

    cube = ThreeD.buildCube(num)
    # IO.inspect(cube,label: "Cube ")

    # assign each node its neighbors
    # neighbor list = front, back, right, left, top, and bottom
    # neighborList = ThreeD.makeNeighbors(cube,edge)
  end

  def roundUp(numActors) do
    if(Integer.mod(numActors, 8) != 0) do
      numActors = numActors + 1
      roundUp(numActors)
    else
      numActors
    end
  end

  def threeDtop(index, cube) do
    # have to already have all the neighbors mapped to each other
    # this should just go to index and return value
    num_nodeInt = String.to_integer(Atom.to_string(index))
    num_node = num_nodeInt - 1
    node = Enum.at(cube, num_node)
    {index, node, neighbors} = node
    neighbors = convertNeighbors(neighbors, cube)
  end

  def convertNeighbors(neighbors, cube) do
    # for all the neighbors in the list
    # take their coordinate
    # find their id
    neighbors =
      Enum.map(neighbors, fn node ->
        {id, coor, neighborsList} =
          Enum.find(cube, fn x ->
            {index, coor, nl} = x
            coor == node
          end)

        id
      end)

    neighbors
  end

  def buildCube(numNodes) do
    # given edge build a cube with that many layers which has n*n nodes
    edge = Kernel.trunc(Float.ceil(:math.pow(numNodes, 1 / 3)))

    # IO.inspect(edge, label: "edge")
    layers = 0
    x = 0
    y = 0
    lastNode = edge - 1
    rng = Range.new(0, lastNode)

    # xyzList = []
    xyzList =
      for(layers <- rng) do
        for(x <- rng) do
          for(y <- rng) do
            node = {layers, x, y}
            neighbors = makeNeighbors(node, lastNode)
            {node, neighbors}
          end
        end
      end

    xyzList = List.flatten(xyzList)

    xyzList =
      Enum.map(xyzList, fn info ->
        index = Enum.find_index(xyzList, fn x -> x == info end)
        index = index + 1
        Tuple.insert_at(info, 0, :"#{index}")
      end)
  end

  def makeNeighbors(node, edge) do
    # neighbor list = front, back, right, left, top, and bottom
    # {layers, x, y}
    # x plane = right, left
    # y plane = front, back
    # z/layer plane = top, bottom

    # neighbor list = front, back, right, left, top, and bottom
    {layers, x, y} = node

    # check if on bottom layer
    bottom =
      if layers == 0 do
        bottom = {edge, x, y}
      else
        bottom = {layers - 1, x, y}
      end

    # check if on top layer
    top =
      if layers == edge do
        top = {0, x, y}
      else
        top = {layers + 1, x, y}
      end

    # check if all the way right
    right =
      if x == edge do
        right = {layers, 0, y}
      else
        right = {layers, x + 1, y}
      end

    # check if all the way left
    left =
      if x == 0 do
        left = {layers, edge, y}
      else
        left = {layers, x - 1, y}
      end

    # check if all the way front
    front =
      if y == 0 do
        front = {layers, x, edge}
      else
        front = {layers, x, y - 1}
      end

    # check if all the way back
    back =
      if y == edge do
        back = {layers, x, 0}
      else
        back = {layers, x, y + 1}
      end

    nl = [front, back, right, left, top, bottom]
    nl = Enum.uniq(nl)
  end
end
