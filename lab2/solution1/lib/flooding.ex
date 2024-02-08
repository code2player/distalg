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
  process_num = 10

  # 需要这么写，否则每一次循环创建新的map，不会更新外部，借助递归形式获取。
  addrmap = Enum.reduce(1..process_num, %{}, fn suffix, acc ->
    peerx = Node.spawn(:'peer#{suffix}_#{this.node_suffix}', Peer, :start, [])
    Process.sleep(10)
    Map.put(acc, suffix, peerx)
  end)


  IO.puts "suffix #{1} -> pid #{Helper.pid_string(addrmap[1])}"

  for suffix <- 1..process_num do
    peerx = addrmap[suffix]

    peer1 = addrmap[rem(suffix+1, process_num)+1]
    peer2 = addrmap[rem(suffix+4, process_num)+1]
    peer3 = addrmap[rem(suffix+7, process_num)+1]

    send peerx, { :bind, suffix, [peer1, peer2, peer3] }
  end

  send addrmap[1], { :hello, 1 }


end # start :cluster_start

end # Flooding
