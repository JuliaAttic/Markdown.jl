include("util.jl")
include("config.jl")

# Parser functions:
#   md – should be modified appropriately
#   return – basically, true if parse was successful
#     false uses the next parser in the queue, true
#     goes back to the beginning
# 
# Inner parsers:
#   return – element to use or nothing

# Inner parsing

function innerparse(stream::IO, parsers::Vector{Function})
  for parser in parsers
    inner = parser(stream)
    inner ≡ nothing || return inner
  end
end

innerparse(stream::IO, config::Config) =
  innerparse(stream, config.inner.parsers)

function parseinline(stream::IO, config::Config)
  content = {}
  buffer = IOBuffer()
  while !eof(stream)
    char = peek(stream)
    if haskey(config.inner, char) &&
        (inner = innerparse(stream, config.inner[char])) != nothing
      c = takebuf_string(buffer)
      !isempty(c) && push!(content, c)
      buffer = IOBuffer()
      push!(content, inner)
    else
      write(buffer, read(stream, Char))
    end
  end
  c = takebuf_string(buffer)
  !isempty(c) && push!(content, c)
  return content
end

parseinline(s::String, c::Config) =
  parseinline(IOBuffer(s), c)

# Block parsing

function parse(stream::IO, block::MD, config::Config; interrupting = false)
  eof(stream) && return false
  for parser in (interrupting ? config.interrupting : [config.interrupting, config.regular])
    parser(stream, block, config) && return true
  end
  return false
end

const flavours = Dict{Symbol, Config}()

function parse(stream::IO; flavour = julia)
  isa(flavour, Symbol) && (flavour = flavours[flavour])
  markdown = MD()
  while parse(stream, markdown, flavour) end
  return markdown
end
