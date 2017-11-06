defmodule Project2 do
  @moduledoc """
  Documentation for Project2.
  """

   def main(argv) do

    IO.inspect(argv)
    [nodes, topology , algorithm] = argv
    # if (algorithm != "push-sum") and (algorithm != "gossip") do
    #   IO.puts("Invalid algorithm #{algorithm} --> Please use either 'push-sum' or 'gossip'")
    # else 
    #   if (topology != "2D" and topology!= "imp2D" and topology != "line" and topology !="full") do
    #     IO.puts("Invalid topology #{topology} --> Please use either '2D' or 'imp2D' or 'line' or 'full'")
    #   else
        GenServer.start_link(MainServer,{String.to_integer(nodes),topology , algorithm},name: {:global, :MainServer})
        receive do
      #   end
      # end
    end
  end

end
