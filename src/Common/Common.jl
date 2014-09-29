# Block elements
# ––––––––––––––

function paragraph(stream::IO, block::MD, config::Config)
  skipblank(stream) > 0 && return true
  buffer = IOBuffer()
  md = Paragraph()
  push!(block, md)
  skipwhitespace(stream)
  while !eof(stream)
    char = read(stream, Char)
    if char == '\n' || char == '\r'
#       char == '\n' && startswith(stream, "\r")
      if startswith(stream, ["\n", "\r"], padding = true, newlines = false) || stop(stream, config.triggers)
        break
      else
        write(buffer, ' ')
      end
    else
      if char in config.inner.triggers &&
          (inner = parseinline(stream, config, offset = -1)) != nothing
        push!(md.content, takebuf_string(buffer))
        buffer = IOBuffer()
        push!(md.content, inner)
      else
        write(buffer, char)
      end
    end
  end
  push!(md.content, takebuf_string(buffer))
  return true
end

# Currently only supports level = 1
function hash_header(stream::IO, md::MD, config::Config)
  startswith(stream, "#") || return false
  level = 1
  while startswith(stream, "#")
    level += 1
  end
  h = readline(stream) |> chomp
  h = match(r"\s*(.*)(?<![#\s])", h).captures[1]
  if !isempty(h)
    push!(md.content, Header(h, level))
    return true
  else
    return false
  end
end

function has_plain_last(md::MD)
  return !isempty(md) && isa(md[end], Paragraph) &&
    !isempty(md[end].content) && isa(md[end].content[1], String)
end

function underline_header(stream::IO, md::MD, config::Config)
  if has_plain_last(md) && next_line_contains_only(stream, whitespace*"=", eat = true)
    md[end] = Header(md[end][1].text)
    return true
  else
    return false
  end
end

underline_header_trigger(stream::IO) = next_line_contains_only(stream, "=")

function indented_code(stream::IO, block::MD, config::Config)
  start = position(stream)
  skipblank(stream)
  buffer = IOBuffer()
  while startswith(stream, "    ") || startswith(stream, "\t")
    write(buffer, readline(stream))
  end
  code = takebuf_string(buffer)
  !isempty(code) && (push!(block, BlockCode(chomp(code))); return true)
  seek(stream, start)
  return false
end

function blockquote(stream::IO, block::MD, config::Config)
  start = position(stream)
  skipblank(stream)
  buffer = IOBuffer()
  @label loop
  while startswith(stream, "> ") || startswith(stream, ">")
    write(buffer, readline(stream))
  end
  blankline(stream) && @goto loop
  md = takebuf_string(buffer)
  if !isempty(md)
    push!(block, BlockQuote(parse(md).content))
    return true
  else
    seek(stream, start)
    return false
  end
end

# Todo: ordered lists, inline formatting
function list(stream::IO, block::MD, config::Config)
  start = position(stream)
  skipwhitespace(stream)
  startswith(stream, ["* ", "• "]) || (seek(stream, start); return false)
  the_list = List()
  buffer = IOBuffer()
  fresh_line = false
  while !eof(stream)
    if fresh_line
      skipwhitespace(stream)
      if startswith(stream, ["* ", "• "])
        push!(the_list.items, takebuf_string(buffer))
        buffer = IOBuffer()
      else
        write(buffer, ' ')
      end
      fresh_line = false
    else
      c = read(stream, Char)
      if c == '\n'
        eof(stream) && break
        next = peek(stream)
        if next == '\n' || stop(stream, config.triggers)
          break
        else
          fresh_line = true
        end
      else
        write(buffer, c)
      end
    end
  end
  push!(the_list.items, takebuf_string(buffer))
  push!(block, the_list)
  return true
end

# Inline elements
# –––––––––––––––

function asterisk_italic(stream::IO)
  result = parse_inline_wrapper(stream, "*")
  return result == nothing ? nothing : Italic(result)
end

function asterisk_bold(stream::IO)
  result = parse_inline_wrapper(stream, "**")
  return result == nothing ? nothing : Bold(result)
end

function inline_code(stream::IO)
  result = parse_inline_wrapper(stream, "`")
  return result == nothing ? nothing : Code(result)
end

function image(stream::IO)
  start = position(stream)
  while true
    startswith(stream, "![") || break
    alt = readuntil(stream, "]")
    alt == nothing && break
    skipwhitespace(stream)
    startswith(stream, "(") || break
    url = readuntil(stream, ")")
    url == nothing && break
    return Image(url, alt)
  end
  seek(stream, start)
  return nothing
end

function link(stream::IO)
  start = position(stream)
  while true
    startswith(stream, "[") || break
    text = readuntil(stream, "]")
    text == nothing && break
    skipwhitespace(stream)
    startswith(stream, "(") || break
    url = readuntil(stream, ")")
    url == nothing && break
    return Link(text, url)
  end
  seek(stream, start)
  return nothing
end

# Punctuation

function en_dash(stream::IO)
  if startswith(stream, "--")
    return "–"
  end
end

const escape_chars = "\\`*_#+-.!{}[]()"

function escapes(stream::IO)
  pos = position(stream)
  if startswith(stream, "\\") && !eof(stream) && (c = peek(stream)) in escape_chars
    return read(stream, Char) |> string
  end
  seek(stream, pos)
  return
end

# Config
# ––––––

standard = Config(
  # Block elements
  ["```", '#', underline_header_trigger],
  [list, indented_code, blockquote, underline_header, hash_header, paragraph],
  # Inline elements
  "\\-`*![", [escapes, en_dash, inline_code, asterisk_bold, asterisk_italic, image, link])

flavours[:standard] = standard
