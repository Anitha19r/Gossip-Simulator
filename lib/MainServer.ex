defmodule MainServer do
  use GenServer

  ## Client API

  @doc """
  Starts the registry.
  """
  #Anitha only this is used for now
  def start_link(nodes,topology , algorithm) do
    IO.puts("Main process pid is #{inspect self()}")
    IO.puts("-------------------------------------")
    GenServer.start_link(__MODULE__, {nodes,topology , algorithm},name: {:global, :MainServer})
  end

  
  #Anitha only this is used for now
  def startGossip(num_nodes,topology, algorithm) do
    message = "She is the best"
    n=num_nodes
    num_nodes=if topology == "2D" or topology == "imp2D" do
      round(:math.pow(:math.ceil(:math.sqrt(num_nodes)),2))
    else 
      n
    end
    start_node=:rand.uniform(num_nodes)-1
    list_of_nodes=[]
    list_of_nodes=startprocesses(num_nodes,list_of_nodes,algorithm)
    GenServer.cast(self(), {:maintain_state_list, list_of_nodes})
    #IO.inspect(list_of_nodes)
    called_pid=Enum.at(list_of_nodes,start_node)
    #IO.inspect(called_pid)
    case topology do
        "full"->
            generateFullTopology(num_nodes,called_pid,list_of_nodes)
        "2D" -> 
            generate2DTopology(num_nodes,called_pid,list_of_nodes)
        "line" ->  
            generateLineTopology(num_nodes,called_pid,list_of_nodes)
        "imp2D" -> 
            generateImp2DTopology(num_nodes,called_pid,list_of_nodes)
    end
    GenServer.cast(called_pid, {:recieve_gossip, message,0,0})
  end
  #Anitha only this is used for now
  def startprocesses(num_nodes,list,algorithm)  do
      if num_nodes > 0 do
        {:ok, pid}=GenServer.start_link(Workers,algorithm)
        list =[pid |list]
        startprocesses(num_nodes-1,list,algorithm)
      else
        list_of_nodes=list
      end
  end

  def generateFullTopology(num_nodes,called_pid,list_of_nodes) do
      n=length(list_of_nodes)-1 
      for x <- 0..n do
        GenServer.cast(Enum.at(list_of_nodes,x), {:save_neighbors, List.delete(list_of_nodes,self()),x+1,1})
      end 
  end
  def generateLineTopology(num_nodes,called_pid,list_of_nodes) do
      n=length(list_of_nodes)-1    
      for x <- 0..n do
        neighbors=[]
        if x ==0 do
          neighbors = [Enum.at(list_of_nodes,x+1)]
        else 
          if x ==n do
            neighbors = [Enum.at(list_of_nodes,x-1)]
          else
              neighbors = [Enum.at(list_of_nodes,(x-1)) | neighbors] 
              neighbors = [Enum.at(list_of_nodes,(x+1)) | neighbors] 
          end
        end
        GenServer.cast(Enum.at(list_of_nodes,x), {:save_neighbors, neighbors,x+1,1})
      end 
  end
  def generate2DTopology(num_nodes,called_pid,list_of_nodes) do
      n=num_nodes-1  
      size=num_nodes
      w=:math.sqrt(num_nodes) |> round
      for i <- 0..n do
        neighbors=[]
        if i - w >= 0 do
	        neighbors=[Enum.at(list_of_nodes,(i - w)) | neighbors]# north
        end
	      if rem(i, w) != 0 do
	    	  neighbors=[Enum.at(list_of_nodes,(i - 1)) | neighbors]#west
        end
	      if rem((i + 1),w) != 0 do 
	    	  neighbors=[Enum.at(list_of_nodes,(i + 1)) | neighbors] #east
        end
	      if (i + w) < size do
	    	  neighbors=[Enum.at(list_of_nodes,(i + w)) | neighbors] #south
        end
        GenServer.cast(Enum.at(list_of_nodes,i), {:save_neighbors, neighbors,i+1,1})
      end
  end
  def generateImp2DTopology(num_nodes,called_pid,list_of_nodes) do
      n=num_nodes-1  
      size=num_nodes
      w=:math.sqrt(num_nodes) |> round
      for i <- 0..n do
        neighbors=[]
        if (i - w) >= 0 do
	        neighbors=[Enum.at(list_of_nodes,(i - w)) | neighbors]# north
        end
	      if rem(i, w) != 0 do
	    	  neighbors=[Enum.at(list_of_nodes,(i - 1)) | neighbors]#west
        end
	      if rem((i + 1),w) != 0 do 
	    	  neighbors=[Enum.at(list_of_nodes,(i + 1)) | neighbors] #east
        end
	      if (i + w) < size do
	    	  neighbors=[Enum.at(list_of_nodes,(i + w)) | neighbors] #south
        end
        list_nodes_wo_self = Enum.reduce([self()|neighbors], list_of_nodes,
                              fn (x,del) -> List.delete(del,x) end)
        start_node=:rand.uniform(length(list_nodes_wo_self))-1                     
        neighbors=[Enum.at(list_nodes_wo_self,start_node)|neighbors]
        GenServer.cast(Enum.at(list_of_nodes,i), {:save_neighbors, neighbors,i+1,1})
      end
  end
  def handle_cast({:handle_covergence,remove_pid,start_time,algorithm,ratio}, {count,node_list}) do
      IO.puts("(()))***Inside handle convergence ***(())) #{count} ") 
      if length(node_list) <= 2 or algorithm== "push-sum" do
         IO.puts("(()))***Reached convergence ***(()))")
        #  if algorithm == "push-sum" do
        #    IO.puts("Ratio for convergence is #{ratio}")
        #  end
         IO.puts("**************************************************************TOTAL TIME IN SECONDS IS : #{System.system_time(:second)-start_time} **************************************************************")
         Process.exit(self(), :kill)
      end 
      {:noreply,{count+1,List.delete(node_list,remove_pid)}}
  end 
  
  def handle_cast({:maintain_state_list,list}, {count,node_list}) do
      {:noreply,{0,list}}
  end 

  ## Server Callbacks
  #Anitha only this is used for now
  def init({nodes,topology , algorithm}) do
    IO.puts("inside init #{inspect self()}")
    startGossip(nodes,topology , algorithm)
    {:ok,{0,[]}}
  end
 
end