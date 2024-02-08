
# distributed algorithms, n.dulay, 4 jan 24
# lab3 - broadcast algorithms

defmodule Broadcast do

def start do
  this = Helper.node_init()
  start(this, this.start_function)
end # start

defp start(_this, :cluster_wait) do :skip end

defp start(this, :cluster_start) do
  IO.puts "-> Broadcast at #{Helper.node_string()}"

  # **** ADD YOUR CODE HERE ****
  process_num = this.n_peers
  addr = Enum.reduce(0..(process_num-1), %{seen: %{}, list: %{}, acc: []}, fn suffix, acc ->
    peerx = Node.spawn(:'peer#{suffix}_#{this.node_suffix}', Peer, :start, [])
    Process.sleep(10)
    new_seen = Map.put(acc.seen, suffix, peerx)
    new_list = Map.put(acc.list, suffix, 0)
    %{seen: new_seen, list: new_list, acc: [peerx | acc.acc]}
  end)

  # fully-connection
  for i <- 0..(process_num-1) do
    send addr.seen[i], { :bind, i, addr.seen, addr.list, addr.list }
  end

  for i <- 0..(process_num-1) do
    send addr.seen[i], {:broadcast, 1000, 3000}
  end

end # start :cluster_start

end # Broadcast
