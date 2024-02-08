
# distributed algorithms, n.dulay, 4 jan 24
# lab2 -- flooding

defmodule Peer do

# **** ADD YOUR CODE HERE ****
def start do
  IO.puts "-> Client at #{Helper.node_string()}"
  receive do
    { :bind, myself, neighbors } -> %{myself: myself, neighbors: neighbors, hellonum: 0, return_num: 0, return_sum: 0, parent: myself} |> next()
  end # receive
end # start



defp next(this) do
  #this1 = %{myself: this.myself, neighbors: this.neighbors}
  receive do
    { :hello, clientnum, sender } ->

      if this.hellonum == 0 do
        IO.puts "node: #{this.myself} -> receive :#{clientnum}, num: #{this.hellonum + 1}"
        for elem <- this.neighbors do
          send elem, { :hello, this.myself, self() }
          #IO.puts "send to #{Helper.pid_string(elem)}"
        end
        this1 = %{this | hellonum: this.hellonum + 1, parent: sender}
        Process.sleep(10)
        this1 |> next()
      else
        send sender, { :return, 0 }

        this1 = %{this | hellonum: this.hellonum + 1}
        Process.sleep(10)
        this1 |> next()
      end

    { :return, clientsum } ->
      childsum = this.return_sum + clientsum
      if this.return_num + 1 == length(this.neighbors) do
        IO.puts "node: #{this.myself}, childsum :#{childsum + 1}"
        if this.myself != 0 do
          send this.parent, { :return, childsum + 1 }# +1 is self
        end
      else
        this1 = %{this | return_num: this.return_num + 1, return_sum: childsum }
        this1 |> next()
      end

  end # receive
end # next




end # Peer
