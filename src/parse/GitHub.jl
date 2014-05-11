#jewel module Markdown

function fenced_code(stream::IO, block::Block, config::Config)
  skip_whitespace(stream)
  startswith(stream, "```") || return false
  readline(stream)
  buffer = IOBuffer()
  while !eof(stream)
    startswith(stream, "```") && break
    write(buffer, read(stream, Char))
  end
  push!(block, Code(takebuf_string(buffer) |> chomp))
  return true
end

function github_paragraph(stream::IO, block::Block, config::Config)
  buffer = IOBuffer()
  md = Paragraph()
  push!(block, md)
  skip_whitespace(stream)
  while !eof(stream)
    char = read(stream, Char)
    if char == '\n'
      eof(stream) && break
      next = peek(stream)
      if next == '\n' || stop(stream, config.triggers)
        break
      else
        write(buffer, '\n')
      end
    else
      if char in config.inner.triggers &&
          (inner = parse_inner(stream, config, offset = -1)) != nothing
        push!(md, Plain(takebuf_string(buffer)))
        buffer = IOBuffer()
        push!(md, inner)
      else
        write(buffer, char)
      end
    end
  end
  push!(md.content, Plain(takebuf_string(buffer)))
  return true
end

github = Config(
  # Block elements
  ["```", '#', underline_header_trigger],
  [list, indented_code, fenced_code, underline_header, hash_header, github_paragraph],
  # Inline elements
  "-`*!", [en_dash, inline_code, asterisk_bold, asterisk_italic, image])

flavours[:github] = github
