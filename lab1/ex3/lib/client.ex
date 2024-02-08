
# distributed algorithms, n.dulay, 4 jan 24
# simple client-server, v1

defmodule Client do

def start do
  IO.puts "-> Client at #{Helper.node_string()}"
  receive do
    { :bind, server } -> %{server: server} |> next()
  end # receive
end # start

defp next(this) do
  value = Helper.random(3)
  cond do
    value == 1 ->
      send this.server, { :trsqrt, self(), 10.0 }
    value == 2 ->
      send this.server, { :square, self(), 1.0 }
    true ->
      send this.server, { :circle, self(), 1.0 }
  end


  receive do { :result, area } -> IO.puts "Area is #{area}, pid: #{inspect(self())}" end
  Process.sleep(1000)
  this |> next()
end # next

end # Client
