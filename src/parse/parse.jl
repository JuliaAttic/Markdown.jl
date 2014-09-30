include("util.jl")

# Config description and utils

export Config

type InnerConfig
  triggers::UTF8String
  parsers::Vector{Function}
end

type Config
  triggers::Vector
  parsers::Vector{Function}
  inner::InnerConfig
end

Config(triggers, parsers, inner_triggers, inner_parsers) =
  Config(triggers, parsers, InnerConfig(inner_triggers, inner_parsers))

function stop(stream::IO, trigger::Char)
  !eof(stream) && peek(stream) == trigger
end

function stop(stream::IO, trigger::String)
  startswith(stream, trigger, eat = false)
end

function stop(stream::IO, trigger::Function)
  trigger(stream)
end

function stop(stream::IO, triggers::Vector)
  any(t -> stop(stream, t), triggers)
end

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
    if char in config.inner.triggers &&
        (inner = innerparse(stream, config)) != nothing
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

# Block parsing

function parse(stream::IO, block::MD, config::Config)
  eof(stream) && return false
  for parser in config.parsers
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
