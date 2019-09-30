defmodule TwoDGridTopology do
  def makeTwoDTopology(rng) do
    xyList = TwoDGridTopology.makeXYList(rng)
    newNeighborList = TwoDGridTopology.twoD_topology(xyList, rng)
    IO.inspect(newNeighborList, label: "newNeighborList")
  end

  def makeXYList(rng) do
    xyList = []

    xyList =
      for index <- rng do
        x = Enum.random(0..10)
        y = Enum.random(0..10)
        i = index
        nl = []
        cord = {x, y, i, nl}
        xyList = List.insert_at(xyList, i, cord)
      end
  end

  def twoDtop(node_num, neighbor_map) do
    # have to already have all the neighbors mapped to each other
    # this should just go to index and return value
    node = Enum.at(neighbor_map, node_num)
    [{x, y, i, nl}] = node
    nl
  end

  def twoD_topology(xyList, rng) do
    # for every value in xyList
    newList =
      Enum.map(xyList, fn value1 ->
        [{x1, y1, i1, nl1}] = value1

        # # check every other value if our differences are < 1
        new_neighbors =
          for num <- rng do
            index = num - 1
            node = Enum.at(xyList, index)
            [{x2, y2, i2, nl2}] = node

            if(i1 != i2) do
              difference = difference(x1, y1, x2, y2)
              # IO.inspect(difference, label: "difference is")
              if(difference <= 1) do
                IO.inspect(i2, label: "#{i1} has as a new neighbor")
                new_neighbors = nl1 ++ [:"#{i2}"]
              else
                new_neighbors = "dumb"
              end
            else
              new_neighbors = "dumb"
            end
          end

        new_neighbors = Enum.reject(new_neighbors, fn x -> x == "dumb" end)
        new_neighbors = List.flatten(new_neighbors)
        # end)

        # return value1
        newvalue = [{x1, y1, i1, new_neighbors}]
        newvalue
        # end
      end)

    newList
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
