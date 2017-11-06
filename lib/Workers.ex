defmodule Workers do
  use GenServer

  ## Client API

  @doc """
  Starts the registry.
  """
  #Anitha only this is used for now
  

  ## Server Callbacks
  #Anitha only this is used for now
  def init(algorithm) do 
    {:ok, {0,[],0,0,algorithm,0}}
  end

  def handle_cast({:save_neighbors, input_neigbors,input_s,input_w}, {state, neighbors,s,w,algorithm,start_time}) do
      start_time = System.system_time(:second)
      {:noreply,{0,input_neigbors,input_s,input_w,algorithm,start_time}}
  end 
 
 #Anitha only this is used for now
  def handle_cast({:recieve_gossip, msg,input_s,input_w}, {state, neighbors,s,w,algorithm,start_time}) do
    :global.sync()
    pid=:global.whereis_name(:MainServer)
    #IO.puts("#{inspect neighbors}")
    if state >= 10 and algorithm != "push-sum" do
       IO.puts("******-------------Rumour limit reached for node #{inspect self()}-------------******")
       GenServer.cast(pid,{:handle_covergence,self(),start_time,algorithm,0})
       {:noreply, {state,neighbors ,s,w,algorithm,start_time}}
    else
       IO.puts("Rumour recieved by #{inspect self()}-----------#{msg} #{state}")
       if algorithm =="push-sum" do
          if state >= 3 do
              IO.puts("(()))***Reached convergence ***(()))")
              GenServer.cast(pid,{:handle_covergence,self(),start_time,algorithm,s/w})
              {:noreply,{3,neighbors,input_s,input_w,algorithm,start_time}}
          else 
              
              old_s=s
              old_w=w
              new_s1= (s+input_s)
              new_w1= (w+input_w)
              new_s=(s+input_s)/2
              new_w=(w+input_w)/2
              #IO.puts(new_s1/new_w1)
              ratio = (s/w) - (new_s1/new_w1)
              GenServer.cast(self(), {:transmit_gossip, msg,new_s,new_w})
              if ratio <= abs(:math.pow(10,-10)) do
                {:noreply,{state+1,neighbors,new_s,new_w,algorithm,start_time}}
              else
                {:noreply,{0,neighbors,new_s,new_w,algorithm,start_time}}
              end
          end
       else 
          GenServer.cast(self(), {:transmit_gossip, msg,s,w})
          {:noreply,{state+1,neighbors,input_s,input_w,algorithm,start_time}}
       end
    end
  end

  def handle_cast({:transmit_gossip,msg,input_s,input_w},{state, neighbors,s,w,algorithm,start_time}) do
    random_len=length(neighbors) 
    start_node=:rand.uniform(random_len)-1
    called_pid=Enum.at(neighbors,start_node)
    IO.puts("Sending rumour from #{inspect self()}  to #{inspect called_pid}")
    GenServer.cast(called_pid, {:recieve_gossip, msg,input_s,input_w})
    
    if algorithm != "push-sum" do
      :timer.sleep(3000)
      GenServer.cast(self(), {:transmit_gossip, msg,input_s,input_w})
    end
    {:noreply, {state, neighbors,input_s,input_w,algorithm,start_time}}
  end
end