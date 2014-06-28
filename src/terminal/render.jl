include("formatting.jl")

# Render Content to Terminal

# Need separate print and print_inline
# Block should handle padding, not individual elements

const margin = 2

function terminal_print(io::IO, md::Block; columns = nothing)
  for content in md.content
    terminal_print(io, content, columns = columns)
  end
end

function terminal_print(io::IO, md::Paragraph; columns = nothing)
  if columns == nothing
    for content in md.content
      terminal_print(io, content)
    end
  else
    print(io, " "^margin)
    print_wrapped(io, width = columns-2margin, pre = " "^margin) do io
      for content in md.content
        terminal_print(io, content)
      end
    end
  end
  println(io)
end

function terminal_print(io::IO, md::List; columns = 80) # TODO: handle no column number
  for point in md.content
    print(io, " "^2margin, "• ")
    print_wrapped(io, width = columns-(4margin+2), pre = " "^(2margin+2), i = 2margin+2) do io
      terminal_print(io, point)
    end
  end
  println(io)
end

function terminal_print(io::IO, md::Header{1}; columns = nothing)
  if columns == nothing
    println(io, 2margin, md.text)
    println(io, 2margin,"–"^min(length(md.text), 30))
    println(io)
  else
    with_output_format(:bold, io) do io
      print_centred(io, md.text, width = columns - 4margin, columns = columns)
    end
    print_centred(io, "-"*"–"^min(length(md.text), div(columns, 2))*"-", columns = columns)
    println(io)
  end
end

function terminal_print{l}(io::IO, md::Header{l}; columns = nothing)
  println(io, "#"^l, " ", md.text, "\n")
end

function terminal_print(io::IO, md::Code; columns = nothing)
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

function terminal_print(io::IO, md::Plain)
  print_with_format(:normal, io, md.text)
end

function terminal_print(io::IO, md::Bold)
  print_with_format(:bold, io, md.text)
end

function terminal_print(io::IO, md::Italic)
  print_with_format(:underline, io, md.text)
end

function terminal_print(io::IO, md::Image)
  print(io, "(Image: $(md.alt))")
end

# Allows display of Plain, Bold etc. but causes infinite loops
terminal_print(io::IO, md::Content; columns = nothing) =
  terminal_print(io, md)

terminal_print(md::Content; columns = nothing) =
  terminal_print(STDOUT, md, columns = columns)

terminal_str(md::Content; columns = nothing) =
  sprint(io -> terminal_print(io, md, columns = columns))

# Show in terminal

import Base.show, Base.Terminals.TextTerminal

function show(term::TextTerminal, md::Content)
  global tty = term
  println(term)
  terminal_print(term, md, columns = size(term).width)
end
