defmodule MainServer do
  use GenServer

  ## Client API

  @doc """
  Starts the registry.
  """
  #Anitha only this is used for now
  def start_link(nodes,topology , algorithm) do
    IO.puts("MAin process pid is #{inspect self()}")
    IO.puts("-------------------------------------")
    GenServer.start_link(__MODULE__, {nodes,topology , algorithm},name: {:global, :MainServer})
  end

  
  #Anitha only this is used for now
  def startGossip(num_nodes,topology, algorithm) do
    message = "She is the best"
    if topology == "2D" or topology == "imp2D" do
      num_nodes=round(:math.pow(:math.ceil(:math.sqrt(num_nodes)),2))
    end
    start_node=:rand.uniform(num_nodes)-1
    list_of_nodes=[]
    list_of_nodes=startprocesses(num_nodes,list_of_nodes)
    GenServer.cast(self(), {:maintain_state_list, list_of_nodes})
    IO.inspect(list_of_nodes)
    called_pid=Enum.at(list_of_nodes,start_node)
    IO.inspect(called_pid)
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
    GenServer.cast(called_pid, {:recieve_gossip, message})
  end
  #Anitha only this is used for now
  def startprocesses(num_nodes,list)  do
      if num_nodes > 0 do
        {:ok, pid}=GenServer.start_link(Workers,0)
        list =[pid |list]
        startprocesses(num_nodes-1,list)
      else
        list_of_nodes=list
      end
  end

  def generateFullTopology(num_nodes,called_pid,list_of_nodes) do
      for x <- list_of_nodes do
        IO.puts("inside for")
        GenServer.cast(x, {:save_neighbors, List.delete(list_of_nodes,self())})
      end 
  end
  def generateLineTopology(num_nodes,called_pid,list_of_nodes) do
      n=length(list_of_nodes)-1    
      for x <- 0..n do
        neighbors=[]
        case x do
         0 ->
          neighbors = [Enum.at(list_of_nodes,x+1)]
         n -> 
          neighbors = [Enum.at(list_of_nodes,x-1)]
         _ -> 
          neighbors = [Enum.at(list_of_nodes,x+1)|Enum.at(list_of_nodes,x-1)]
        end
        GenServer.cast(Enum.at(list_of_nodes,x), {:save_neighbors, neighbors})
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
        GenServer.cast(Enum.at(list_of_nodes,i), {:save_neighbors, neighbors})
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
        start_node=:rand.uniform(num_nodes)-1
        neighbors=[Enum.at(list_of_nodes,start_node)|neighbors]
        GenServer.cast(Enum.at(list_of_nodes,i), {:save_neighbors, neighbors})
      end
  end
  
  def handle_cast({:handle_covergence,remove_pid}, {count,node_list}) do
      IO.puts("(()))***Inside handle convergence ***(())) #{count} ")
       
      if length(node_list) <= 2 do
         IO.puts("(()))***Reached convergence ***(()))")
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


-------------------------------------------------------


defmodule Workers do
  use GenServer

  ## Client API

  @doc """
  Starts the registry.
  """
  #Anitha only this is used for now
  
  def create(server, name) do
    GenServer.cast(server, {:create, name})
  end

  ## Server Callbacks
  #Anitha only this is used for now
  def init(state) do 
    {:ok, {state,[]}}
  end

  def handle_cast({:save_neighbors, input_neigbors}, {state, neighbors}) do
      IO.puts("saving neighbors")
      {:noreply,{0,input_neigbors}}
  end 
 
 #Anitha only this is used for now
  def handle_cast({:recieve_gossip, msg}, {state, neighbors}) do
    if state == 10 do
       IO.puts("******-------------Rumour limit reached for node #{inspect self()}-------------******")
       #remove_pid =self()
       :global.sync()
       pid=:global.whereis_name(:MainServer)
       IO.inspect " *************************************************** PID #{inspect pid}"
       GenServer.cast(pid,{:handle_covergence,self()})
       {:noreply, {state,neighbors }}
       #Process.exit(self(), :normal)
       #{:noreply, {state,List.delete(list,remove_pid) }}
    else
       IO.puts("Rumour recieved by #{inspect self()}-----------#{msg} #{state}")
       #neighbors=List.delete(list,self()) #so that the gossip is not sent to self
       GenServer.cast(self(), {:transmit_gossip, msg})
       {:noreply,{state+1,neighbors}}
    end
  end

  def handle_cast({:transmit_gossip,msg},{state, neighbors}) do
    random_len=length(neighbors) 
    #random_len=random_len-1 
    #IO.inspect(random_len)
    start_node=:rand.uniform(random_len)-1
    called_pid=Enum.at(neighbors,start_node)
    IO.puts("Sending rumour from #{inspect self()}  to #{inspect called_pid} ")
    GenServer.cast(called_pid, {:recieve_gossip, msg})
    :timer.sleep(1000)
    GenServer.cast(self(), {:transmit_gossip, msg})
    {:noreply, {state, neighbors}}
  end
end