typealias Strings{T<:String} AbstractVector{T}

function pager(io::TextTerminal, s::Strings)
  for i = 1:max(length(s) - size(io).height + 2, 1)
    print_page(io, s, i)
    sleep(1)
    clear_screen(io)
  end
end

pager(io::TextTerminal, s::String, args...) =
  pager(lines(s), args...)

function print_page(io::TextTerminal, s::Strings, line)
  columns = size(io).width
  rows = size(io).height
  for i = line:line+rows-2
    i <= length(s) ?
      println(io, s[i]) :
      println(io, " "^columns)
  end
  s = "... please wait ..."
  pad = " "^div(columns - length(s), 2)
  print_with_format(:negative, io, pad*s*pad)
end

cursor_to_corner(term) = print(term, "\e[H")

function clear_screen(term)
  cursor_to_corner(term)
  for i = 1:size(term).height
    print(term, " "^size(term).width)
    i < size(term).height && println(term)
  end
  cursor_to_corner(term)
end
