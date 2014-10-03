@breaking true ->
function fenced_code(stream::IO, block::MD, config::Config)
  startswith(stream, "```", padding = true) || return false
  readline(stream)
  buffer = IOBuffer()
  while !eof(stream)
    startswith(stream, "```") && break
    write(buffer, read(stream, Char))
  end
  push!(block, Code(takebuf_string(buffer) |> chomp))
  return true
end

function github_paragraph(stream::IO, md::MD, config::Config)
  skipblank(stream) > 0 && return true
  skipwhitespace(stream)
  buffer = IOBuffer()
  p = Paragraph()
  push!(md, p)
  while !eof(stream)
    char = read(stream, Char)
    if char == '\n'
      eof(stream) && break
      if startswith(stream, ["\n", "\r"], padding = true, newlines = false) ||
          parse(stream, md, config, breaking = true)
        break
      else
        write(buffer, '\n')
      end
    else
      write(buffer, char)
    end
  end
  p.content = parseinline(seek(buffer, 0), config)
  return true
end

# TODO: tables

@flavour github [list, indented_code, blockquote, fenced_code, hashheader, github_paragraph,
                 en_dash, inline_code, asterisk_bold, asterisk_italic, image, link]
