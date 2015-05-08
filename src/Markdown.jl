# This file is a part of Julia. License is MIT: http://julialang.org/license

module Markdown

using Compat

## Backport `Pair`. ##

immutable Pair{A,B}
    first::A
    second::B
end

Base.start(p::Pair) = 1
Base.done(p::Pair, i) = i>2
Base.next(p::Pair, i) = (getfield(p,i), i+1)

Base.indexed_next(p::Pair, i::Int, state) = (getfield(p,i), i+1)

Base.hash(p::Pair, h::UInt) = hash(p.second, hash(p.first, h))

==(p::Pair, q::Pair) = (p.first==q.first) & (p.second==q.second)
Base.isequal(p::Pair, q::Pair) = isequal(p.first,q.first) & isequal(p.second,q.second)

Base.isless(p::Pair, q::Pair) = ifelse(!isequal(p.first,q.first), isless(p.first,q.first),
                                                             isless(p.second,q.second))
Base.getindex(p::Pair,i::Int) = getfield(p,i)
Base.getindex(p::Pair,i::Real) = getfield(p, convert(Int, i))
Base.reverse(p::Pair) = Pair(p.second, p.first)

## End backport. ##

import Base: writemime

typealias String AbstractString

include("parse/config.jl")
include("parse/util.jl")
include("parse/parse.jl")

include("Common/Common.jl")
include("GitHub/GitHub.jl")
include("IPython/IPython.jl")
include("Julia/Julia.jl")

include("render/plain.jl")
include("render/html.jl")
include("render/latex.jl")

include("render/terminal/render.jl")

export readme, license, @md_str, @doc_str, @md_mstr, @doc_mstr

parse(markdown::String; flavor = julia) = parse(IOBuffer(markdown), flavor = flavor)
parse_file(file::String; flavor = julia) = parse(readall(file), flavor = flavor)

readme(pkg::String; flavor = github) = parse_file(Pkg.dir(pkg, "README.md"), flavor = flavor)
readme(pkg::Module; flavor = github) = readme(string(pkg), flavor = flavor)

license(pkg::String; flavor = github) = parse_file(Pkg.dir(pkg, "LICENSE.md"), flavor = flavor)
license(pkg::Module; flavor = github) = license(string(pkg), flavor = flavor)

function mdexpr(s, flavor = :julia)
    md = parse(s, flavor = symbol(flavor))
    esc(toexpr(md))
end

function docexpr(s, flavor = :julia)
    quote
        let md = $(mdexpr(s, flavor))
            md.meta[:path] = @__FILE__
            md.meta[:module] = current_module()
            md
        end
    end
end

macro md_str(s, t...)
    mdexpr(s, t...)
end

macro doc_str(s, t...)
    docexpr(s, t...)
end

macro md_mstr(s, t...)
    mdexpr(Base.triplequoted(s), t...)
end

macro doc_mstr(s, t...)
    docexpr(Base.triplequoted(s), t...)
end

function Base.display(d::Base.REPL.REPLDisplay, md::Vector{MD})
    for md in md
        display(d, md)
    end
end

end
