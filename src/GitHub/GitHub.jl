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

function github_paragraph(stream::IO, block::MD, config::Config)
  skipwhitespace(stream)
  buffer = IOBuffer()
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
      write(buffer, char)
    end
  end
  push!(block, Paragraph(parseinline(seek(buffer, 0), config)))
  return true
end

# TODO: tables

github = config(list, indented_code, blockquote, fenced_code, hashheader, github_paragraph,
                en_dash, inline_code, asterisk_bold, asterisk_italic, image, link)

flavours[:github] = github
