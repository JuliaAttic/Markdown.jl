typealias InnerConfig Dict{Char, Vector{Function}}

type Config
  interrupting::Vector{Function}
  regular::Vector{Function}
  inner::InnerConfig
end

Config() = Config(Function[], Function[], InnerConfig())

const META = Dict{Function, Dict{Symbol, Any}}()

getset(coll, key, default) = coll[key] = get(coll, key, default)

meta(f) = getset(META, f, Dict{Symbol, Any}())

interrupting!(f) = meta(f)[:interrupting] = true
interrupting(f) = get(meta(f), :interrupting, false)

triggers!(f, ts) = meta(f)[:triggers] = Set{Char}(ts)
triggers(f) = get(meta(f), :triggers, Set{Char}())

# Macros

isexpr(x::Expr, ts...) = x.head in ts
isexpr{T}(x::T, ts...) = T in ts

macro interrupt (def)
  quote
    f = $(esc(def))
    interrupting!(f)
    f
  end
end

macro trigger (ex)
  isexpr(ex, :->) || error("invalid @triggers form, use ->")
  ts, def = ex.args
  quote
    f = $(esc(def))
    triggers!(f, $ts)
    f
  end
end

function config(parsers::Function...)
  c = Config()
  for parser in parsers
    ts = triggers(parser)
    if interrupting(parser)
      push!(c.interrupting, parser)
    elseif !isempty(ts)
      for t in ts
        push!(getset(c.inner, t, Function[]), parser)
      end
    else
      push!(c.regular, parser)
    end
  end
  return c
end
