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
