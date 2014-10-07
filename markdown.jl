#!/usr/local/bin/julia
using Markdown

input = readall(STDIN)

cd(dirname(@__FILE__)) do
  open("log.txt", "w") do io
    println(io, input)
    println(io, "----")
  end
end

if input in ("\n", "")
  println("no input")
  exit(0)
end

try
  output = stringmime("text/html", Markdown.parse(input, flavor = :standard))

  println(output)

  cd(dirname(@__FILE__)) do
    open("log.txt", "a") do io
      println(io, output)
    end
  end

catch e
  open("log.txt", "a") do io
    showerror(io, e, catch_backtrace())
    println(io)
  end
#   rethrow()
end
