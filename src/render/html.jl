#jewel module Markdown

import Base.writemime

function with_tag(f, io, tag)
  print(io, "<$tag>")
  f()
  print(io, "</$tag>")
end

writemime(io::IO, ::MIME"text/html", md::Content) =
  writemime(io, "text/plain", md)

function writemime(io::IO, mime::MIME"text/html", block::Block)
  for md in block.content[1:end-1]
    writemime(io::IO, mime, md)
    println(io)
  end
  writemime(io::IO, mime, block.content[end])
end

function writemime{l}(io::IO, mime::MIME"text/html", header::Header{l})
  with_tag(io, "h$l") do
    print(io, header.text)
  end
end

function writemime(io::IO, ::MIME"text/html", code::Code)
  with_tag(io, "code") do
    println(io)
    for line in split(code.code, "\n")
      println(io, line)
    end
  end
end

function writemime(io::IO, ::MIME"text/html", md::Paragraph)
  with_tag(io, "p") do
    for md in md.content
      html_inline(io, md)
    end
  end
end

function writemime(io::IO, ::MIME"text/html", md::List)
  with_tag(io, "ul") do
    for item in md.content
      with_tag(io, "li") do
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
  with_tag(io, "bold") do
    print(io, md.text)
  end
end

function writemime(io::IO, ::MIME"text/html", md::Italic)
  with_tag(io, "italic") do
    print(io, md.text)
  end
end

function writemime(io::IO, ::MIME"text/html", md::Image)
  print(io, """<img src="$(md.url)" alt="$(md.alt)"></img>""")
end

html_inline(io::IO, el::Content) = writemime(io, "text/html", el)

