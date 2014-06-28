abstract Content

# Forward some array methods

Base.push!(md::Content, x) = push!(md.content, x)
Base.getindex(md::Content, args...) = md.content[args...]
Base.setindex!(md::Content, args...) = setindex!(md.content, args...)
Base.endof(md::Content) = endof(md.content)
Base.length(md::Content) = length(md.content)
Base.isempty(md::Content) = isempty(md.content)

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

type Header{level} <: Content
  text::UTF8String
end

Header(s::String, level::Int) = Header{level}(s)
Header(s::String) = Header(s, 1)

type Code <: Content
  language::UTF8String
  code::UTF8String
  line::Int
end

Code(code) = Code("", code, 0)

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
