defmodule Line_topology do
  def line_topology(myIndex, rng) do
    first_elm = Enum.min(rng)
    last_elm = Enum.max(rng)
    # if i'm not the first element
    if(myIndex > 1) do
      if(myIndex == last_elm) do
        # I'm the last element I only have a left neighbor
        leftElmIndex = myIndex - 1
        myneighbors = [:"#{leftElmIndex}"]
      else
        # I'm a middle element I have a left & a right neighbor
        leftElmIndex = myIndex - 1
        rightElmIndex = myIndex + 1
        myneighbors = [:"#{leftElmIndex}", :"#{rightElmIndex}"]
      end
    else
      # I'm the first element I only have a right neighbor
      rightElmIndex = myIndex + 1
      myneighbors = [:"#{rightElmIndex}"]
    end
  end
end
