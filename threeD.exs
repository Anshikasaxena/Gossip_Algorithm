defmodule ThreeD do
  def makeXYZList(num) do
    numActors = roundUp(num)

    # create number of "fully connected cubes (8 actors in these)"
    # fully connected cubes = divide total num by 8
    numCubes = Kernel.trunc(numActors / 8)
    IO.puts("Num cubes: #{numCubes}")

    cubeRange = Range.new(0, numCubes - 1)
    rng = Range.new(1, numActors)
    actorRange = Range.new(1, 8)

    xyzList = []
    # for each cube
    actor0 = {0, 0, 0}
    actor1 = {0, 0, 1}
    actor2 = {0, 1, 0}
    actor3 = {0, 1, 1}
    actor4 = {1, 0, 0}
    actor5 = {1, 0, 1}
    actor6 = {1, 1, 0}
    actor7 = {1, 1, 1}

    xyzList =
      for cube <- cubeRange do
        for index <- actorRange do
          # assign coordinates
          i = index - 1
          nl = []

          case index do
            1 ->
              cord = {0, 0, 0, cube, i, nl}
              _xyzList = List.insert_at(xyzList, i, cord)

            2 ->
              cord = {0, 0, 1, cube, i, nl}
              _xyzList = List.insert_at(xyzList, i, cord)

            3 ->
              cord = {0, 1, 0, cube, i, nl}
              _xyzList = List.insert_at(xyzList, i, cord)

            4 ->
              cord = {0, 1, 1, cube, i, nl}
              _xyzList = List.insert_at(xyzList, i, cord)

            5 ->
              cord = {1, 0, 0, cube, i, nl}
              _xyzList = List.insert_at(xyzList, i, cord)

            6 ->
              cord = {1, 0, 1, cube, i, nl}
              _xyzList = List.insert_at(xyzList, i, cord)

            7 ->
              cord = {1, 1, 0, cube, i, nl}
              _xyzList = List.insert_at(xyzList, i, cord)

            8 ->
              cord = {1, 1, 1, cube, i, nl}
              _xyzList = List.insert_at(xyzList, i, cord)
          end
        end
      end

    newList = ThreeD.threeD_topology(xyzList, cubeRange)
  end

  def roundUp(numActors) do
    if(Integer.mod(numActors, 8) != 0) do
      numActors = numActors + 1
      roundUp(numActors)
    else
      numActors
    end
  end

  def twoDtop(node_num, rng, neighbor_map) do
    # have to already have all the neighbors mapped to each other
    # this should just go to index and return value
    node = Enum.at(neighbor_map, node_num)
    [{x, y, z, i, nl}] = node
    nl
  end

  def threeD_topology(xyzList, cubeRange) do
    # actor neighbor list = front, back, right, left, top, and bottom
    actor0nl = [1, 1, 4, 4, 2, 2]
    actor1nl = [0, 0, 5, 5, 3, 3]
    actor2nl = [3, 3, 6, 6, 0, 0]
    actor3nl = [2, 2, 7, 7, 1, 1]
    actor4nl = [5, 5, 0, 0, 6, 6]
    actor5nl = [4, 4, 1, 1, 7, 7]
    actor6nl = [7, 7, 2, 2, 4, 4]

    # IO.inspect(actor0nl)
    # IO.inspect(actor1nl)
    # IO.inspect(actor2nl)
    # IO.inspect(actor3nl)
    # IO.inspect(actor4nl)
    # IO.inspect(actor5nl)
    # IO.inspect(actor6nl)

    # for each number of cubes
    for cube <- cubeRange do
      actor0nl = Enum.map(actor0nl, fn x -> x + cube * 8 end)
      IO.inspect(actor0nl)
      actor1nl = Enum.map(actor1nl, fn x -> x + cube * 8 end)
      IO.inspect(actor1nl)
      actor2nl = Enum.map(actor2nl, fn x -> x + cube * 8 end)
      IO.inspect(actor2nl)
      actor3nl = Enum.map(actor3nl, fn x -> x + cube * 8 end)
      IO.inspect(actor3nl)
      actor4nl = Enum.map(actor4nl, fn x -> x + cube * 8 end)
      IO.inspect(actor4nl)
      actor5nl = Enum.map(actor5nl, fn x -> x + cube * 8 end)
      IO.inspect(actor5nl)
      actor6nl = Enum.map(actor6nl, fn x -> x + cube * 8 end)
      IO.inspect(actor6nl)
    end

    # newList =
    #   Enum.map(xyzList, fn value ->
    #     [{x, y, z, i, nl}] = value
    #     # front = you + 1
    #     # back = you + 2
    #     # right = you + 3
    #     # left = you + 4
    #     # top = you + 5
    #     # bottom = you + 6
    #
    #     # # check every other value if our differences are < 1
    #     new_neighbors = 0
    #
    #     new_neighbors =
    #       for num <- rng do
    #         index = num - 1
    #         node = Enum.at(xyList, index)
    #         [{x2, y2, i2, nl2}] = node
    #
    #         if(i1 != i2) do
    #           new_neighbors = 1
    #           difference = difference(x1, y1, x2, y2)
    #           # IO.inspect(difference, label: "difference is")
    #           if(difference <= 1) do
    #             IO.inspect(i2, label: "#{i1} has as a new neighbor")
    #             new_neighbors = nl1 ++ [i2]
    #           else
    #             new_neighbors = "dumb"
    #           end
    #         else
    #           new_neighbors = "dumb"
    #         end
    #       end
    #
    #     new_neighbors = Enum.reject(new_neighbors, fn x -> x == "dumb" end)
    #     new_neighbors = List.flatten(new_neighbors)
    #     # end)
    #
    #     # return value1
    #     newvalue = [{x1, y1, i1, new_neighbors}]
    #     newvalue
    #     # end
    #   end)
    #
    # newList
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

xyzList = ThreeD.makeXYZList(num)
