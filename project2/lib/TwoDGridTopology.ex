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
        _xyList = List.insert_at(xyList, i, cord)
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

    # check to make sure first node has a neighbor if not recurse on myself
    [{x2, y2, i2, nl2}] = List.first(newList)

    if(nl2 == []) do
      IO.inspect("i have no friends")
      newxyList = []

      newxyList =
        for index <- rng do
          x = Enum.random(0..10)
          y = Enum.random(0..10)
          i = index
          nl = []
          cord = {x, y, i, nl}
          newxyList = List.insert_at(newxyList, i, cord)
        end

      twoD_topology(newxyList, rng)
    else
      newList
    end
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

  def makePercentage(neighborList, numNodes) do
    # get node 1 --> get all nodes directly or indirectly

    onesNeighbor = getOnesNeighbors(neighborList)
    onesNeighborList = Enum.uniq(onesNeighbor)
    # [{x1, y1, i1, nl1}] = onesNeighbor
    IO.inspect(onesNeighborList, label: "onesNeighborList")
    allPositives = Enum.count(onesNeighborList)

    zeroNeighbors = getZeroNeighbors(neighborList)
    # add all numbers that are
    allZeros = Enum.count(zeroNeighbors)
    IO.inspect(allZeros, label: "Make Zero Neighbor List")

    # recurse down my neighborList
    # num1Neighbors = getOneConnected(nl1, 0, 0, neighborList)
    # IO.inspect(num1Neighbors, label: "Make Percentage New Neighbor List")
    #
    # # add all numbers that are
    #
    #
    limit = allPositives + allZeros
    # give as new percentage
    percentage = numNodes - limit
    # IO.inspect(percentage, label: "percent_nodes from twoD")
  end

  def getZeroNeighbors(neighborList) do
    Enum.filter(neighborList, fn x ->
      [{x, y, i, nl}] = x
      nl == []
    end)
  end

  def getOneConnected(node1Neighbors, node_location, increment, neighborList) do
    IO.inspect(node1Neighbors, label: "node1Neighbors")
    nodeIndex = Enum.at(node1Neighbors, increment)
    IO.inspect(nodeIndex, label: "nodeIndex")
    # get nodeIndex's neighbors
    index = String.to_integer(Atom.to_string(nodeIndex))
    IO.inspect(index, label: "index")
    ind = index - 1
    node2 = Enum.at(neighborList, ind)
    IO.inspect(node2, label: "node2")
    [{x2, y2, i2, nl2}] = node2

    newNeighbors =
      for node3Index <- nl2 do
        index2 = String.to_integer(Atom.to_string(node3Index)) - 1
        IO.inspect(index2, label: "index2")
        node3 = Enum.at(neighborList, index2)
        IO.inspect(node3, label: "node3")
        [{x3, y3, i3, nl3}] = node3

        if(:"#{i3}" not in node1Neighbors) do
          node1Neighbors = node1Neighbors ++ [:"#{i3}"]
        end
      end

    maxNodes = Enum.count(newNeighbors)
    IO.inspect(maxNodes, label: "count")
    maxNum = maxNodes - 1
    IO.inspect(maxNum, label: "count2 ")

    if(increment < maxNum) do
      increment = increment + 1
      IO.inspect(newNeighbors, label: "node1Neighbors")
      getOneConnected(newNeighbors, node_location, increment, neighborList)
    else
      newNeighbors
    end
  end

  def getOnesNeighbors(neighborList) do
    onesNeighbor = Enum.at(neighborList, 0)
    [{x1, y1, i1, nl1}] = onesNeighbor
    nl1
    elem = 0
    onesNeighborList = getEveryoneInOnesNeighbors(nl1, neighborList, elem)
    IO.inspect(onesNeighborList, label: "onesNeighborList")
    # onesNeighborList = List.flatten(onesNeighborList)
  end

  def getEveryoneInOnesNeighbors(nl, neighborList, elem) do
    count = Enum.count(nl) - 1
    IO.inspect(count, label: "count")

    if(elem <= count) do
      firstNeighbor = Enum.at(nl, elem)
      IO.inspect(firstNeighbor, label: "firstNeighbor")
      index = String.to_integer(Atom.to_string(firstNeighbor))
      # IO.inspect(index, label: "firstNeighbor index")
      ind = index - 1
      node = Enum.at(neighborList, ind)
      [{x2, y2, i2, nl2}] = node
      IO.inspect(nl2, label: "#{i2}'s neighborList:'")
      thirdLevel(nl2, nl, neighborList, elem)
    else
      IO.puts("In base case")
      nl
    end
  end

  def thirdLevel(nl2, nl, neighborList, elem) do
    IO.puts("In third level")
    IO.inspect(nl, label: "nl")
    IO.inspect(nl2, label: "nl2")

    nlToFlat =
      for neighbor <- nl2 do
        IO.inspect(neighbor, label: "neighbor")
        # check if I'm not in one's List
        nl =
          if neighbor not in nl do
            IO.puts("I'm getting picked")
            # add myself to nl
            nl = nl ++ [neighbor]
          else
            IO.puts("Not picked")
            nl
          end
      end

    nlToUniq = List.flatten(nlToFlat)
    nl = Enum.uniq(nlToUniq)

    IO.inspect(nl, label: "new nl")
    elem = elem + 1
    getEveryoneInOnesNeighbors(nl, neighborList, elem)
  end

  # IO.inspect(secondLevel, label: "secondLevel")
end
