
# distributed algorithms, n.dulay, 4 jan 24
# simple client-server, v1

defmodule ClientServer do

def start do
  this = Helper.node_init()
  start(this, this.start_function)
end # start

defp start(_this, :cluster_wait) do
  :skip
end # start :cluster_wait

defp start(this, :single_start) do
  IO.puts "-> ClientServer at #{Helper.node_string()}"
  server = Node.spawn(:'clientserver_#{this.node_suffix}', Server, :start, [])
  Process.sleep(100)
  client1 = Node.spawn(:'clientserver_#{this.node_suffix}', Client, :start, [])
  client2 = Node.spawn(:'clientserver_#{this.node_suffix}', Client, :start, [])
  send server, { :bind }
  send client1, { :bind, server }
  send client2, { :bind, server }
end # start :single_start

defp start(this, :cluster_start) do
  IO.puts "-> ClientServer at #{Helper.node_string()}"
  server = Node.spawn(:'server_#{this.node_suffix}', Server, :start, [])
  Process.sleep(100)
  send server, { :bind }

  IO.puts "this.client is #{this.clients}"

  for suffix <- 1..this.clients do
    client = Node.spawn(:'client#{suffix}_#{this.node_suffix}', Client, :start, [])
    send client, { :bind, server }
  end

end # start :cluster_start

end # ClientServer
