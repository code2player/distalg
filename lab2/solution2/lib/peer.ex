
# distributed algorithms, n.dulay, 4 jan 24
# lab2 -- flooding

defmodule Peer do

# **** ADD YOUR CODE HERE ****
def start do
  IO.puts "-> Client at #{Helper.node_string()}"
  receive do
    { :bind, myself, neighbors } -> %{myself: myself, neighbors: neighbors, hellonum: 0} |> next()
  end # receive
end # start



defp next(this) do
  #this1 = %{myself: this.myself, neighbors: this.neighbors}
  receive do
    { :hello, clientnum } ->

      if this.hellonum == 0 do
        IO.puts "node: #{this.myself} -> receive :#{clientnum}, num: #{this.hellonum + 1}"
        for elem <- this.neighbors do
          send elem, { :hello, this.myself }
          #IO.puts "send to #{Helper.pid_string(elem)}"
        end
      end

      #this.hellonum = this.hellonum + 1

      #Map.put(this1, :hellonum, this.hellonum + 1)

  end # receive
  this1 = %{this | hellonum: this.hellonum + 1}
  Process.sleep(10)
  this1 |> next()
end # next




end # Peer
