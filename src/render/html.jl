# Utils

function withtag(f, io, tag)
  print(io, "<$tag>")
  f()
  print(io, "</$tag>")
end

# Block elements

function html(io::IO, block::MD)
  for md in block.content
    html(io::IO, md)
    println(io)
  end
end

function html{l}(io::IO, header::Header{l})
  withtag(io, "h$l") do
    print(io, header.text)
  end
end

function html(io::IO, code::Code)
  withtag(io, "pre") do
    withtag(io, "code") do
      print(io, code.code)
    end
  end
end

function html(io::IO, md::Paragraph)
  withtag(io, "p") do
    for md in md.content
      htmlinline(io, md)
    end
  end
end

function html(io::IO, md::BlockQuote)
  withtag(io, "blockquote") do
    for md in block.content
      html(io::IO, md)
      println(io)
    end
  end
end

function html(io::IO, md::List)
  withtag(io, "ul") do
    for item in md.content
      withtag(io, "li") do
        htmlinline(io, item)
      end
    end
  end
end

# Inline elements

function htmlinline(io::IO, code::InlineCode)
  withtag(io, "code") do
    print(io, code.code)
  end
end

function htmlinline(io::IO, md::Plain)
  print(io, md.text)
end

function htmlinline(io::IO, md::Bold)
  withtag(io, "strong") do
    print(io, md.text)
  end
end

function htmlinline(io::IO, md::Italic)
  withtag(io, "em") do
    print(io, md.text)
  end
end

function htmlinline(io::IO, md::Image)
  print(io, """<img src="$(md.url)" alt="$(md.alt)"></img>""")
end

function htmlinline(io::IO, md::Link)
  print(io, """<a href="$(md.url)">$(md.text)</a>""")
end

# API

export html

html(md) = sprint(html, md)

Base.writemime(io::IO, ::MIME"text/html", md::MD) = html(io, md)
