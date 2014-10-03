type Paragraph
  content

  Paragraph(x) = new(x)
end

Paragraph() = Paragraph({})
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
  text
end

Header(s, level::Int) = Header{level}(s)
Header(s) = Header(s, 1)

type Code
  language::UTF8String
  code::UTF8String
end

Code(code) = Code("", code)

type Bold
  text
end

type Italic
  text
end

type Link
  text
  url::UTF8String
end

type Image
  url::UTF8String
  alt::UTF8String
end
