type MD
  content::Vector{Any}

  MD(x::AbstractVector) = new(x)
end

MD(xs...) = MD([xs...])

# Forward some array methods

Base.push!(md::MD, x) = push!(md.content, x)
Base.getindex(md::MD, args...) = md.content[args...]
Base.setindex!(md::MD, args...) = setindex!(md.content, args...)
Base.endof(md::MD) = endof(md.content)
Base.length(md::MD) = length(md.content)
Base.isempty(md::MD) = isempty(md.content)

type Paragraph
  content

  Paragraph(x) = new(x)
end

Paragraph(xs...) = Paragraph([xs...])

type BlockQuote
  content

  BlockQuote(x) = new(x)
end

BlockQuote(xs...) = BlockQuote([xs...])

type List
  items::Vector{Any}
  ordered::Bool

  List(x::AbstractVector) = new(x)
end

List(xs...) = List([xs...])

type Header{level}
  content
end

Header(s, level::Int) = Header{level}(s)
Header(s) = Header(s, 1)

type Code
  language::UTF8String
  code::UTF8String
end

Code(code) = Code("", code)

type Bold
  text::UTF8String
end

type Italic
  text::UTF8String
end

type Link
  content
  url::UTF8String
end

type Image
  url::UTF8String
  alt::UTF8String
end
