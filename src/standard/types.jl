abstract Content

# Forward some array methods

Base.push!(md::Content, x) = push!(md.content, x)
Base.getindex(md::Content, args...) = md.content[args...]
Base.setindex!(md::Content, args...) = setindex!(md.content, args...)
Base.endof(md::Content) = endof(md.content)
Base.length(md::Content) = length(md.content)
Base.isempty(md::Content) = isempty(md.content)

typealias Cell Vector{Any}

type MD <: Content
  content::Cell

  MD(x::AbstractVector) = new(x)
end

MD(xs...) = MD([xs...])

type Paragraph <: Content
  content::Cell

  Paragraph(x::AbstractVector) = new(x)
end

Paragraph(xs...) = Paragraph([xs...])

type BlockQuote <: Content
  content::Cell

  BlockQuote(x::AbstractVector) = new(x)
end

BlockQuote(xs...) = BlockQuote([xs...])

type List <: Content
  content::Cell
  ordered::Bool

  List(x::AbstractVector) = new(x)
end

List(xs...) = List([xs...])

type Header{level} <: Content
  text::UTF8String
end

Header(s::String, level::Int) = Header{level}(s)
Header(s::String) = Header(s, 1)

type InlineCode <: Content
  code::UTF8String
end

type Code <: Content
  language::UTF8String
  code::UTF8String
end

BlockCode(code) = BlockCode("", code)

type Plain <: Content
  text::UTF8String
end

type Bold <: Content
  text::UTF8String
end

type Italic <: Content
  text::UTF8String
end

type Link <: Content
  text::UTF8String
  url::UTF8String
end

type Image <: Content
  url::UTF8String
  alt::UTF8String
end
