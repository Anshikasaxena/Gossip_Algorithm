defmodule Start_Rounds do
  def start_rounds(children, algo) do
    if children == [] do
      # terminate
      # Check - might give error for few arguments
      IO.puts("Stopping the Supervisor")
      :ok = DynamicSupervisor.stop(DySupervisor)
      IO.puts("Uh oh ")
    else
      for x <- children do
        {_, pidx, _, _} = x

        if Process.alive?(pidx) do
          # {init_arg, nl} = :sys.get_state(pidx)
          state = :sys.get_state(pidx)
          init_arg = elem(state, 0)
          nl = elem(state, 1)
          s = elem(state, 2)
          w = elem(state, 3)
          # IO.inspect(init_arg)

          values = Process.info(pidx)
          name = Enum.at(values, 0, nil)
          sender = elem(name, 1)
          # IO.inspect(sender)

          cond do
            nl == [] ->
              # Remove the process from the list of children
              IO.puts("Your neigbors are dead and so are you")
              children = List.delete(children, x)
              # Send a normal exit command
              # Check - Possible error
              stringPid = Kernel.inspect(pidx)
              IO.puts("My neighbors are dead , here i #{sender} die ")
              :ok = DynamicSupervisor.terminate_child(DySupervisor, pidx)
              IO.inspect(children)
              childkilled = DynamicSupervisor.which_children(DySupervisor)
              IO.inspect(childkilled)

            init_arg > 3 ->
              # Remove the process from the list of children
              ## do here in start rounds
              children = List.delete(children, x)

            # remove_me(pidx,nl)

            init_arg >= 0 ->
              # pick a random neighbor and start sending message
              sendto = Enum.take_random(nl, 1)
              sendto = Enum.at(sendto, 0)
              IO.puts("I #{sender} am sending a message to #{sendto}")
              # Check - Possible error
              # :ok = GenServer.call(sendto, {:rumor})
              # Start the first message
              if algo == "Gossip" do
                :ok = GenServer.call(sendto, {:rumor})
              else
                # send your s and w
                message = {s, w}
                :ok = GenServer.call(sendto, {:rumor, message})
              end

              # QUESTION: why was this written like this? 
              # init_arg == 0 ->
              #   IO.puts("Nothing here")
          end
        else
          children = List.delete(children, x)
        end
      end

      kill_em(algo)
      # start_rounds(children)
    end
  end

  def remove_me(pidx, nl) do
    values = Process.info(pidx)
    name = Enum.at(values, 0, nil)
    sender = elem(name, 1)

    IO.puts("Remove me #{sender} from your list")
    Enum.each(nl, fn x -> GenServer.call(x, {:RemoveMe, sender}) end)
    # Send a normal exit command
  end

  def kill_em(algo) do
    children = DynamicSupervisor.which_children(DySupervisor)

    for x <- children do
      {_, pidx, _, _} = x
      # {init_arg, nl} = :sys.get_state(pidx)
      state = :sys.get_state(pidx)
      init_arg = elem(state, 0)
      nl = elem(state, 1)

      if init_arg > 3 do
        IO.puts("Here i die ")
        IO.inspect(pidx)
        current = self()
        IO.puts("Its me cleaning up ")
        IO.inspect(current)
        # Check - Possible error
        # Dig in - Control not going ba
        :ok = DynamicSupervisor.terminate_child(DySupervisor, pidx)
        IO.puts("Its me cleaning up ")
      end
    end

    children = DynamicSupervisor.which_children(DySupervisor)
    IO.inspect(children)
    start_rounds(children, algo)
  end
end
