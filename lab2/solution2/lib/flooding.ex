# distributed algorithms, n.dulay, 4 jan 24
# lab2 -- flooding, v1

# flood message through 1-hop (fully connected) network

defmodule Flooding do

def start do
  this = Helper.node_init()
  start(this, this.start_function)
end # start

defp start(_this, :cluster_wait) do
  :skip
end # start :cluster_wait

defp start(this, :cluster_start) do
  IO.puts "-> Flooding at #{Helper.node_string()}"

  # **** ADD YOUR CODE HERE ****

  # create 10 peer processes its own node
  process_num = this.n_peers

  # 需要这么写，否则每一次循环创建新的map，不会更新外部，借助递归形式获取。
  addrmap = Enum.reduce(0..(process_num-1), %{}, fn suffix, acc ->
    peerx = Node.spawn(:'peer#{suffix}_#{this.node_suffix}', Peer, :start, [])
    #IO.puts "id #{Helper.pid_string(peerx)}"
    Process.sleep(10)
    Map.put(acc, suffix, peerx)
  end)


  #IO.puts "suffix #{1} -> pid #{Helper.pid_string(addrmap[1])}"
  #IO.puts "suffix #{1} -> pid #{Helper.pid_string(addrmap[6])}"

  send addrmap[0], { :bind, 0, [addrmap[1], addrmap[6]] }
  send addrmap[1], { :bind, 1, [addrmap[0], addrmap[2], addrmap[3]] }
  send addrmap[2], { :bind, 2, [addrmap[1], addrmap[3], addrmap[4]] }
  send addrmap[3], { :bind, 3, [addrmap[1], addrmap[2], addrmap[5]] }
  send addrmap[4], { :bind, 4, [addrmap[2]] }
  send addrmap[5], { :bind, 5, [addrmap[3]] }
  send addrmap[6], { :bind, 6, [addrmap[0], addrmap[7]] }
  send addrmap[7], { :bind, 7, [addrmap[6], addrmap[8], addrmap[9]] }
  send addrmap[8], { :bind, 8, [addrmap[7], addrmap[9]] }
  send addrmap[9], { :bind, 9, [addrmap[7], addrmap[8]] }
  Process.sleep(10)
  send addrmap[0], { :hello, -1 }

end # start :cluster_start

end # Flooding
