#jewel module Markdown

import Base: peek

const whitespace = " \t"

"""
Skip any leading whitespace. Returns io.
"""
function skip_whitespace(io::IO; newlines = true)
  while !eof(io) && (peek(io) in whitespace || (newlines && peek(io) == '\n'))
    read(io, Char)
  end
  return io
end

"""
Skip any leading blank lines. Returns the number skipped.
"""
function skip_blank_lines(io::IO)
  start = position(io)
  i = 0
  while !eof(io)
    c = read(io, Char)
    c == '\n' && (start = position(io); i+=1; continue)
    c in whitespace || break
  end
  seek(io, start)
  return i
end

"""
Returns true if the line contains only (and
at least one of) the characters given.
"""
function next_line_contains_only(io::IO, chars::String; allow_whitespace = true,
                                                        eat = false)
  start = position(io)
  l = readline(io) |> chomp
  result = false
  for c in l
    c in whitespace && (allow_whitespace ? continue : (result = false; break))
    c in chars && (result = true; continue)
    result = false; break
  end
  !(result && eat) && seek(io, start)
  return result
end

"""
Test if the stream starts with the given string.
`eat` specifies whether to advance on success (true by default).
`padding` specifies whether leading whitespace should be ignored.
"""
function starts_with(stream::IO, s::String; eat = true, padding = false)
  start = position(stream)
  padding && skip_whitespace(stream)
  result = true
  for char in s
    !eof(stream) && read(stream, Char) == char ||
      (result = false; break)
  end
  !(result && eat) && seek(stream, start)
  return result
end

function starts_with{T<:String}(stream::IO, ss::Vector{T})
  any(s->starts_with(stream, s), ss)
end

"""
Read the stream until the delimiter is met.
The delimiter is consumed but not included.
"""
function read_until(stream::IO, delimiter::String, newlines = false)
  start = position(stream)
  buffer = IOBuffer()
  while !eof(stream)
    starts_with(stream, delimiter) && return takebuf_string(buffer)
    char = read(stream, Char)
    !newlines && char == '\n' && break
    write(buffer, char)
  end
  seek(stream, start)
  return nothing
end

"""
Parse a symmetrical delimiter which wraps words.
i.e. `*word word*` but not `*word * word`
"""
function parse_inline_wrapper(stream::IO, delimiter::String, no_newlines = true)
  start = position(stream)
  starts_with(stream, delimiter) || return nothing

  buffer = IOBuffer()
  while !eof(stream)
    char = read(stream, Char)
    no_newlines && char == '\n' && break
    if !(char in whitespace) && starts_with(stream, delimiter)
      write(buffer, char)
      return takebuf_string(buffer)
    end
    write(buffer, char)
  end

  seek(stream, start)
  return nothing
end

function show_rest(io::IO)
  start = position(io)
  show(readall(io))
  seek(io, start)
end
