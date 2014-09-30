type Config
  interrupting::Vector{Function}
  regular::Vector{Function}
  inner::Dict{Char, Vector{Function}}
end

const META = Dict{Function, Dict{Symbol, Any}}()

meta(f) = META[f] = get(META, f, Dict{Symbol, Any}())

interrupting!(f) = meta(f)[:interrupting] = true
interrupting(f) = get(meta(f), :interrupting, false)

triggers!(f, ts) = meta(f)[:triggers] = Set{Char}(ts)
triggers(f) = meta(f)[:triggers]

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

macro triggers (ex)
  isexpr(ex, :->) || error("invalid @triggers form, use ->")
  ts, def = ex.args
  quote
    f = $(esc(def))
    triggers!(f, $ts)
    f
  end
end
