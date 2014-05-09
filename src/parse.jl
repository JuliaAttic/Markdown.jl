#jewel module Markdown

export Config

type InnerConfig
  triggers::UTF8String
  parsers::Vector{Function}
end

type Config
  triggers::UTF8String
  parsers::Vector{Function}
  inner::InnerConfig
end

Config(triggers, parsers, inner_triggers, inner_parsers) =
  Config(triggers, parsers, InnerConfig(inner_triggers, inner_parsers))

md = """
# Title 1
This is **some text** which
spans *multiple* lines.

# Title 2
$lorem

And now for `some code`
it be
"""

import Base: peek

"""
Parser functions:
  stream – guaranteed not to have trailing whitespace or EOF
  md – should be modified appropriately
return – basically, true if parse was successful
    false uses the next parser in the queue, true
    goes back to the beginning
"""

const whitespace = " \t"

function parse_inner(stream::IO, parsers::Vector{Function}; offset = 0)
  skip(stream, offset)
  for parser in parsers
    inner = parser(stream)
    inner == nothing || return inner
  end
  skip(stream, -offset)
  return nothing
end

parse_inner(stream::IO, config::Config; offset = 0) =
  parse_inner(stream, config.inner.parsers; offset=offset)

function paragraph(stream::IO, block::Block, config::Config)
  buffer = IOBuffer()
  md = Paragraph()
  push!(block, md)
  while !eof(stream)
    char = read(stream, Char)
    if char == '\n'
      eof(stream) && break
      next = peek(stream)
      if next == '\n' || next in config.triggers
        break
      else
        write(buffer, ' ')
      end
    else
      if char in config.inner.triggers &&
          (inner = parse_inner(stream, config, offset = -1)) != nothing
        push!(md, Plain(takebuf_string(buffer)))
        buffer = IOBuffer()
        push!(md, inner)
      else
        write(buffer, char)
      end
    end
  end
  push!(md.content, Plain(takebuf_string(buffer)))
  return true
end

# Currently only supports level = 1
function hash_header(stream::IO, md::Block, config::Config)
  peek(stream) == '#' || return false
  level = 0
  while peek(stream) == '#'
    level += 1
    read(stream, Char)
  end
  discard_whitespace(stream, newlines = false)
  h = readline(stream) |> chomp
  if !isempty(h)
    push!(md.content, Header(h))
    return true
  else
    return false
  end
end

function parse_inline_wrapper(stream::IO, delimiter::String, no_newlines = true)
  startswith(stream, delimiter) || return nothing
  skip(stream, length(delimiter))

  start = position(stream)
  buffer = IOBuffer()
  while !eof(stream)
    char = read(stream, Char)
    no_newlines && char == '\n' && break
    if !(char in whitespace) && startswith(stream, delimiter)
      skip(stream, length(delimiter))
      write(buffer, char)
      return takebuf_string(buffer)
    end
    write(buffer, char)
  end

  seek(stream, start)
  return nothing
end

function asterisk_italic(stream::IO)
  result = parse_inline_wrapper(stream, "*")
  return result == nothing ? nothing : Italic(result)
end

function asterisk_bold(stream::IO)
  result = parse_inline_wrapper(stream, "**")
  return result == nothing ? nothing : Bold(result)
end

function inline_code(stream::IO)
  result = parse_inline_wrapper(stream, "`")
  return result == nothing ? nothing : Code(result)
end

function discard_whitespace(io::IO; newlines = true)
  while !eof(io) && (peek(io) in whitespace || (newlines && peek(io) == '\n'))
    read(io, Char)
  end
end

function startswith(stream::IO, s::String)
  start = position(stream)
  result = true
  for char in s
    !eof(stream) && read(stream, Char) == char ||
      (result = false; break)
  end
  seek(stream, start)
  return result
end

standard = Config(
  "#`=-", [hash_header, paragraph],
  "*_[`", [inline_code, asterisk_bold, asterisk_italic])

# The interface needs to change – modify tree directly and return true/false

function parse(stream::IO, config::Config = standard)
  markdown = Block()
  discard_whitespace(stream)
  while !eof(stream)
    for parser in config.parsers
      parser(stream, markdown, config) && break
    end
    discard_whitespace(stream)
  end
  return markdown
end

parse(markdown::String) = parse(IOBuffer(markdown))
