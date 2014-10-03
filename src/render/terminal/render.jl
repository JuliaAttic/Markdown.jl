include("formatting.jl")

# Render Content to Terminal

# Need separate print and print_inline
# Block should handle padding, not individual elements

const margin = 2

function term(io::IO, content::Vector; columns = nothing)
  for md in content
    term(io, md, columns = columns)
    println(io)
  end
end

term(io::IO, md::MD; columns = nothing) = term(io, md.content, columns = columns)

function term(io::IO, md::Paragraph; columns = nothing)
  if columns == nothing
    terminline(io, md.content)
  else
    print(io, " "^margin)
    print_wrapped(io, width = columns-2margin, pre = " "^margin) do io
      terminline(io, md.content)
    end
  end
end

function term(io::IO, md::BlockQuote; columns = nothing)
  s = sprint(io->term(io, Block(md.content); columns = columns - 10))
  for line in split(rstrip(s), "\n")
    println(io, " "^margin, "|", line)
  end
  println(io)
end

function term(io::IO, md::List; columns = 80) # TODO: handle no column number
  for point in md.items
    print(io, " "^2margin, "• ")
    print_wrapped(io, width = columns-(4margin+2), pre = " "^(2margin+2), i = 2margin+2) do io
      terminline(io, point)
    end
  end
  println(io)
end

function term(io::IO, md::Header{1}; columns = nothing)
  if columns == nothing
    println(io, 2margin, md.text)
    println(io, 2margin,"–"^min(length(md.text), 30))
    println(io)
  else
    with_output_format(:bold, io) do io
      print_centred(io, sprint(terminline, md.text), width = columns - 4margin, columns = columns)
    end
    print_centred(io, "-"*"–"^min(length(md.text), div(columns, 2))*"-", columns = columns)
    println(io)
  end
end

function term{l}(io::IO, md::Header{l}; columns = nothing)
  print(io, "#"^l, " ")
  terminline(io, md.text)
end

function term(io::IO, md::Code; columns = nothing)
  if columns == nothing
    print_with_format(:cyan, io, md.code)
  else
    with_output_format(:cyan, io) do io
      for line in lines(md.code)
        print(io, " "^margin)
        println(io, line)
      end
    end
    println(io)
  end
end

# Inline Content

function terminline(io::IO, content::Vector)
  for md in content
    terminline(io, md)
  end
end

function terminline(io::IO, md::String)
  print_with_format(:normal, io, md)
end

function terminline(io::IO, md::Bold)
  print_with_format(:bold, io, md.text)
end

function terminline(io::IO, md::Italic)
  print_with_format(:underline, io, md.text)
end

function terminline(io::IO, md::Image)
  print(io, "(Image: $(md.alt))")
end

function terminline(io::IO, md::Link)
  print(io, md.text)
end

function terminline(io::IO, code::Code)
  print_with_format(:cyan, io, code.code)
end

# # Show in terminal

# import Base.show, Base.Terminals.TextTerminal

# function show(term::TextTerminal, md::Content)
#   global tty = term
#   println(term)
#   terminal_print(term, md, columns = size(term)[2])
# end
