#jewel module Markdown

abstract Content

Base.push!(md::Content, x) = push!(md.content, x)

type Block <: Content
  content::Vector{Content}

  Block(x::AbstractVector) = new(x)
end

Block(xs...) = Block([xs...])

type Paragraph <: Content
  content::Vector{Content}

  Paragraph(x::AbstractVector) = new(x)
end

Paragraph(xs...) = Paragraph([xs...])

type List <: Content
  content::Vector{Content}
  ordered::Bool

  List(x::AbstractVector) = new(x)
end

List(xs...) = List([xs...])

type Header{T<:String, level} <: Content
  text::T
end

Header(s::String, level::Int) = Header{typeof(s), level}(s)
Header(s::String) = Header(s, 1)

typealias Header1{T} Header{T, 1}

type Code{T<:String} <: Content
  code::T
end

type Plain{T<:String} <: Content
  text::T
end

type Bold{T<:String} <: Content
  text::T
end

type Italic{T<:String} <: Content
  text::T
end
