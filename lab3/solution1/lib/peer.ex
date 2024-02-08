
# distributed algorithms, n.dulay, 4 jan 24
# lab2 -- flooding

defmodule Peer do

# **** ADD YOUR CODE HERE ****
def start do
  IO.puts "-> Client at #{Helper.node_string()}"
  receive do
    { :bind, myself, neighbors, send_list, recv_list } ->
      %{myself: myself, neighbors: neighbors, send_list: send_list, recv_list: recv_list, remain_broadcasts: 0} |> next()
  end # receive
end # start


# callback function for :tick
def handle_info(:tick, this) do
  IO.puts "???"
  IO.write("peer#{this.myself}:   ")
  for i <- 0..(Kernel.map_size(this.neighbors) - 1) do
    IO.write("{#{this.send_list[i]}, #{this.recv_list[i]}}  ")
  end
  IO.puts ""
  {:noreply, this}
end

defp next(this) do
  receive do
    {:broadcast, max_broadcasts, timeout} ->
      Process.send_after(self(), :tick, timeout)
      send self(), {:send_msg}
      this1 = %{this | remain_broadcasts: max_broadcasts}
      this1 |> next()

    {:tick} ->
      IO.write("peer#{this.myself}:   ")
      for i <- 0..(Kernel.map_size(this.neighbors) - 1) do
        IO.write("{#{this.send_list[i]}, #{this.recv_list[i]}}  ")
      end
      IO.puts ""

    {:send_msg} ->
      #IO.puts "test#{this.remain_broadcasts }"
      if this.remain_broadcasts != 0 do
        for i <- 0..(Kernel.map_size(this.neighbors) - 1) do
          send this.neighbors[i], {:receive_msg, this.myself}
        end

        new_send = Enum.reduce(0..(Kernel.map_size(this.neighbors) - 1), this.send_list, fn i, acc ->
          Map.put(acc, i, acc[i]+1)
        end)

        send self(), {:send_msg}
        this1 = %{this | remain_broadcasts: this.remain_broadcasts - 1, send_list: new_send }
        this1 |> next()
      else
        this |> next()
      end

    {:receive_msg, sender} ->
      new_recv = Map.put(this.recv_list, sender, this.recv_list[sender] + 1)
      this1 = %{this | recv_list: new_recv}
      this1 |> next()

    after
      1000*(this.myself+1) -> # Timeout of 0 means no waiting
        IO.write("peer#{this.myself}:   ")
        for i <- 0..(Kernel.map_size(this.neighbors) - 1) do
          IO.write("{#{this.send_list[i]}, #{this.recv_list[i]}}  ")
        end
        IO.puts ""
        #this |> next()

  end # receive
end # next


end # Peer
