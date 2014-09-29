import Base.writemime

export html

function withtag(f, io, tag)
  print(io, "<$tag>")
  f()
  print(io, "</$tag>")
end

writemime(io::IO, ::MIME"text/html", md::Content) =
  writemime(io, "text/plain", md)

function writemime(io::IO, mime::MIME"text/html", block::MD)
  for md in block.content[1:end-1]
    writemime(io::IO, mime, md)
    println(io)
  end
  writemime(io::IO, mime, block.content[end])
end

function writemime{l}(io::IO, mime::MIME"text/html", header::Header{l})
  withtag(io, "h$l") do
    print(io, header.text)
  end
end

function writemime(io::IO, ::MIME"text/html", code::Code)
  withtag(io, "pre") do
    withtag(io, "code") do
      print(io, code.code)
    end
  end
end

function writemime(io::IO, ::MIME"text/html", code::InlineCode)
  withtag(io, "code") do
    print(io, code.code)
  end
end

function writemime(io::IO, ::MIME"text/html", md::Paragraph)
  withtag(io, "p") do
    for md in md.content
      html_inline(io, md)
    end
  end
end

function writemime(io::IO, ::MIME"text/html", md::BlockQuote)
  withtag(io, "blockquote") do
    writemime(io, "text/html", MD(md.content))
  end
end

function writemime(io::IO, ::MIME"text/html", md::List)
  withtag(io, "ul") do
    for item in md.content
      withtag(io, "li") do
        html_inline(io, item)
      end
    end
  end
end

# Inline elements

function writemime(io::IO, ::MIME"text/html", md::Plain)
  print(io, md.text)
end

function writemime(io::IO, ::MIME"text/html", md::Bold)
  withtag(io, "strong") do
    print(io, md.text)
  end
end

function writemime(io::IO, ::MIME"text/html", md::Italic)
  withtag(io, "em") do
    print(io, md.text)
  end
end

function writemime(io::IO, ::MIME"text/html", md::Image)
  print(io, """<img src="$(md.url)" alt="$(md.alt)"></img>""")
end

function writemime(io::IO, ::MIME"text/html", md::Link)
  print(io, """<a href="$(md.url)">$(md.text)</a>""")
end

html_inline(io::IO, el::Content) = writemime(io, "text/html", el)

html(md::Content) = stringmime("text/html", md)
