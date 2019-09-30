defmodule TwoDGridTopology do
  def makeXYList(rng) do
    xyList = []

    xyList =
      for index <- rng do
        x = Enum.random(0..10)
        y = Enum.random(0..10)
        i = index - 1
        nl = []
        cord = {x, y, i, nl}
        xyList = List.insert_at(xyList, i, cord)
      end
  end

  def twoD_topology(xyList, rng) do
    # for every value in xyList
    newList =
      Enum.map(xyList, fn value1 ->
        [{x1, y1, i1, nl1}] = value1

        # # check every other value if our differences are < 1
        new_neighbors = 0

        new_neighbors =
          for num <- rng do
            index = num - 1
            node = Enum.at(xyList, index)
            [{x2, y2, i2, nl2}] = node

            if(i1 != i2) do
              new_neighbors = 1
              difference = difference(x1, y1, x2, y2)
              # IO.inspect(difference, label: "difference is")
              if(difference <= 1) do
                IO.inspect(i2, label: "#{i1} has as a new neighbor")
                new_neighbors = nl1 ++ [i2]
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

  def twoDtop(node_num, neighbor_map) do
    # have to already have all the neighbors mapped to each other
    # this should just go to index and return value
    node = Enum.at(neighbor_map, node_num)
    [{x, y, i, nl}] = node
    nl
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

# Main Application
num = 12
rng = Range.new(1, num)

xyList = TwoDGridTopology.makeXYList(rng)
IO.inspect(xyList, label: "xyList")

newList = TwoDGridTopology.twoD_topology(xyList, rng)
IO.inspect(newList, label: "newList")

neighborsList = TwoDGridTopology.twoDtop(2, rng, newList)
IO.inspect(neighborsList, label: "2 neighborsList")

neighborsList = TwoDGridTopology.twoDtop(3, rng, newList)
IO.inspect(neighborsList, label: "3 neighborsList")

neighborsList = TwoDGridTopology.twoDtop(4, rng, newList)
IO.inspect(neighborsList, label: "4 neighborsList")

neighborsList = TwoDGridTopology.twoDtop(5, rng, newList)
IO.inspect(neighborsList, label: "5 neighborsList")

neighborsList = TwoDGridTopology.twoDtop(6, rng, newList)
IO.inspect(neighborsList, label: "6 neighborsList")
