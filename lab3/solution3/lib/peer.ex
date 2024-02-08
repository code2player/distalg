
# distributed algorithms, n.dulay, 4 jan 24
# lab2 -- flooding

# 基本思路：PL发送实际通信，client用来计数

defmodule Perfect_p2p_links do
  def start do
    IO.puts "-> PL at #{Helper.node_string()}"
    receive do
      { :bind, process_id, neighbors, remain_broadcasts, client } ->
        %{process_id: process_id, neighbors: neighbors, remain_broadcasts: remain_broadcasts, client: client} |> next()
    end # receive
  end # start

  defp next(this) do
    receive do
      {:pl_send} ->
        if this.remain_broadcasts != 0 do
          for i <- 0..(Kernel.map_size(this.neighbors) - 1) do
            send this.neighbors[i], {:pl_deliver, this.process_id}
          end
          send self(), {:pl_send}
          this1 = %{this | remain_broadcasts: this.remain_broadcasts - 1}
          this1 |> next()
        else
          this |> next()
        end

      {:pl_deliver, sender} ->
        send this.client, {:client_recv, sender}
        this |> next()

    end # receive
  end # next
end



defmodule Client do
  def start do
    IO.puts "-> Client at #{Helper.node_string()}"
    receive do
      { :bind, process_id, neighbors, recv_list, pl } ->
        %{process_id: process_id, neighbors: neighbors, recv_list: recv_list, pl: pl} |> next()
    end # receive
  end # start

  defp next(this) do
    receive do
      {:client_recv, sender} ->
        #IO.write("peer#{this.process_id}:   ")
        new_recv = Map.put(this.recv_list, sender, this.recv_list[sender] + 1)
        this1 = %{this | recv_list: new_recv}
        this1 |> next()

      after
        3000 + 50*(this.process_id+1) -> # Timeout of 0 means no waiting
          IO.write("peer#{this.process_id}:   ")
          for i <- 0..(Kernel.map_size(this.neighbors) - 1) do
            IO.write("{#{this.recv_list[i]}}  ")
          end
          IO.puts ""

    end # receive
  end # next
end

defmodule Peer do

# **** ADD YOUR CODE HERE ****
  def start do
    IO.puts "-> Peer at #{Helper.node_string()}"
    receive do
      { :bind, process_id, neighbors, recv_list, remain_broadcasts } ->
        %{process_id: process_id, neighbors: neighbors, recv_list: recv_list, remain_broadcasts: remain_broadcasts, pl_list: %{}, pl: 0, client: 0} |> next()
    end # receive
  end # start

  defp next(this) do
    receive do
      {:init} ->
        pl = spawn(Perfect_p2p_links, :start, [])
        client1 = spawn(Client, :start, [])
        for i <- 0..(Kernel.map_size(this.neighbors) - 1) do
          send this.neighbors[i], {:broadcast_recv, this.process_id, pl}
        end
        this1 = %{this | pl: pl, client: client1}
        this1 |> next()

      {:broadcast_recv, sender, pl} ->
        new_pl_list = Map.put(this.pl_list, sender, pl)
        this1 = %{this | pl_list: new_pl_list}
        this1 |> next()

      {:gogo} ->
        send this.pl, { :bind, this.process_id, this.pl_list, this.remain_broadcasts - this.process_id, this.client }
        send this.client, { :bind, this.process_id, this.pl_list, this.recv_list, this.pl }
        Process.sleep(100)
        send this.pl, { :pl_send }
        this |> next()

    end # receive
  end # next
end # Peer
