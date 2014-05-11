#jewel module Markdown

import Base.writemime

# writemime seems to take priority over show?

# function writemime(io::IO, mime::MIME"text/plain", block::Block)
#   for md in block.content[1:end-1]
#     writemime(io::IO, mime, md)
#     println(io)
#   end
#   writemime(io::IO, mime, block.content[end])
# end

# function writemime{l}(io::IO, mime::MIME"text/plain", header::Header{l})
#   print(io, "#"^l*" ")
#   println(io, header.text)
# end

# function writemime(io::IO, ::MIME"text/plain", code::Code)
#   for line in split(code.code, "\n")
#     println(io, line)
#   end
# end

# function writemime(io::IO, ::MIME"text/plain", md::Paragraph)
#   for md in md.content
#     print_inline(io, md)
#   end
#   println(io)
# end

# function writemime(io::IO, ::MIME"text/plain", md::List)
#   for item in md.content
#     print(io, "  * ")
#     print_inline(io, item)
#     println(io)
#   end
# end

# Inline elements

print_inline(io::IO, el::Content) = writemime(io, "text/plain", el)

print_inline(io::IO, md::Image) = print(io, "![$(md.alt)](md.url)")

print_inline(io::IO, md::Plain) = print(io, md.text)

print_inline(io::IO, md::Bold) = print(io, "**", md.text, "**")

print_inline(io::IO, md::Italic) = print(io, "*", md.text, "*")

print_inline(io::IO, md::Code) = print(io, "`", md.code, "`")


