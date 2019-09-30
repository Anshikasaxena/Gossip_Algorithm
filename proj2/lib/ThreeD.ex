defmodule ThreeD do
  def threeD_topology(num) do
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

    # actor neighbor list = front, back, right, left, top, and bottom
    actor0nl = [1, 1, 4, 4, 2, 2]
    actor1nl = [0, 0, 5, 5, 3, 3]
    actor2nl = [3, 3, 6, 6, 0, 0]
    actor3nl = [2, 2, 7, 7, 1, 1]
    actor4nl = [5, 5, 0, 0, 6, 6]
    actor5nl = [4, 4, 1, 1, 7, 7]
    actor6nl = [7, 7, 2, 2, 4, 4]
    actor7nl = [6, 6, 3, 3, 5, 5]

    xyzList =
      for cube <- cubeRange do
        for index <- actorRange do
          # assign coordinates
          i = index - 1

          case index do
            1 ->
              actor0nl = Enum.map(actor0nl, fn x -> x + cube * 8 end)
              actor0nl = Enum.map(actor0nl, fn x -> :"#{x}" end)
              cord = {0, 0, 0, cube, i, actor0nl}
              _xyzList = List.insert_at(xyzList, i, cord)

            2 ->
              actor1nl = Enum.map(actor1nl, fn x -> x + cube * 8 end)
              actor1nl = Enum.map(actor1nl, fn x -> :"#{x}" end)
              cord = {0, 0, 1, cube, i, actor1nl}
              _xyzList = List.insert_at(xyzList, i, cord)

            3 ->
              actor2nl = Enum.map(actor2nl, fn x -> x + cube * 8 end)
              actor2nl = Enum.map(actor2nl, fn x -> :"#{x}" end)
              cord = {0, 1, 0, cube, i, actor2nl}
              _xyzList = List.insert_at(xyzList, i, cord)

            4 ->
              actor3nl = Enum.map(actor3nl, fn x -> x + cube * 8 end)
              actor3nl = Enum.map(actor3nl, fn x -> :"#{x}" end)
              cord = {0, 1, 1, cube, i, actor3nl}
              _xyzList = List.insert_at(xyzList, i, cord)

            5 ->
              actor4nl = Enum.map(actor4nl, fn x -> x + cube * 8 end)
              actor4nl = Enum.map(actor4nl, fn x -> :"#{x}" end)
              cord = {1, 0, 0, cube, i, actor4nl}
              _xyzList = List.insert_at(xyzList, i, cord)

            6 ->
              actor5nl = Enum.map(actor5nl, fn x -> x + cube * 8 end)
              actor5nl = Enum.map(actor5nl, fn x -> :"#{x}" end)
              cord = {1, 0, 1, cube, i, actor5nl}
              _xyzList = List.insert_at(xyzList, i, cord)

            7 ->
              actor6nl = Enum.map(actor6nl, fn x -> x + cube * 8 end)
              actor6nl = Enum.map(actor6nl, fn x -> :"#{x}" end)
              cord = {1, 1, 0, cube, i, actor6nl}
              _xyzList = List.insert_at(xyzList, i, cord)

            8 ->
              actor7nl = Enum.map(actor7nl, fn x -> x + cube * 8 end)
              actor7nl = Enum.map(actor7nl, fn x -> :"#{x}" end)
              cord = {1, 1, 1, cube, i, actor7nl}
              _xyzList = List.insert_at(xyzList, i, cord)
          end
        end
      end

    xyzList = List.flatten(xyzList)
  end

  def roundUp(numActors) do
    if(Integer.mod(numActors, 8) != 0) do
      numActors = numActors + 1
      roundUp(numActors)
    else
      numActors
    end
  end

  def threeDtop(node_num, neighbor_map) do
    # have to already have all the neighbors mapped to each other
    # this should just go to index and return value
    node = Enum.at(neighbor_map, node_num)
    {x, y, z, cube, i, nl} = node
    nl
  end

  def cube(xyzList, cubeRange) do
    # actor neighbor list = front, back, right, left, top, and bottom
    actor0nl = [1, 1, 4, 4, 2, 2]
    actor1nl = [0, 0, 5, 5, 3, 3]
    actor2nl = [3, 3, 6, 6, 0, 0]
    actor3nl = [2, 2, 7, 7, 1, 1]
    actor4nl = [5, 5, 0, 0, 6, 6]
    actor5nl = [4, 4, 1, 1, 7, 7]
    actor6nl = [7, 7, 2, 2, 4, 4]

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
  end
end
