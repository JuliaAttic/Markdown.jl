# Block elements
# ––––––––––––––

function paragraph(stream::IO, block::Block, config::Config)
  skip_blank_lines(stream) > 0 && return true
  buffer = IOBuffer()
  md = Paragraph()
  push!(block, md)
  skip_whitespace(stream)
  while !eof(stream)
    char = read(stream, Char)
    if char == '\n' || char == '\r'
#       char == '\n' && starts_with(stream, "\r")
      if starts_with(stream, ["\n", "\r"], padding = true, newlines = false) || stop(stream, config.triggers)
        break
      else
        write(buffer, ' ')
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

# Currently only supports level = 1
function hash_header(stream::IO, md::Block, config::Config)
  starts_with(stream, "#") || return false
  level = 1
  while starts_with(stream, "#")
    level += 1
  end
  skip_whitespace(stream, newlines = false)
  h = readline(stream) |> chomp
  if !isempty(h)
    push!(md.content, Header(h, level))
    return true
  else
    return false
  end
end

function has_plain_last(md::Block)
  return !isempty(md) && isa(md[end], Paragraph) &&
    !isempty(md[end]) && isa(md[end][1], Plain)
end

function underline_header(stream::IO, md::Block, config::Config)
  if has_plain_last(md) && next_line_contains_only(stream, whitespace*"=", eat = true)
    md[end] = Header(md[end][1].text)
    return true
  else
    return false
  end
end

underline_header_trigger(stream::IO) = next_line_contains_only(stream, "=")

function indented_code(stream::IO, block::Block, config::Config)
  start = position(stream)
  skip_blank_lines(stream)
  buffer = IOBuffer()
  while starts_with(stream, "    ")
    write(buffer, readline(stream))
  end
  code = takebuf_string(buffer)
  !isempty(code) && (push!(block, Code(chomp(code))); return true)
  seek(stream, start)
  return false
end

# Todo: ordered lists, inline formatting
function list(stream::IO, block::Block, config::Config)
  start = position(stream)
  skip_whitespace(stream)
  starts_with(stream, ["* ", "• "]) || (seek(stream, start); return false)
  the_list = List()
  buffer = IOBuffer()
  fresh_line = false
  while !eof(stream)
    if fresh_line
      skip_whitespace(stream)
      if starts_with(stream, ["* ", "• "])
        push!(the_list, Plain(takebuf_string(buffer)))
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
  push!(the_list, Plain(takebuf_string(buffer)))
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

function en_dash(stream::IO)
  if starts_with(stream, "--")
    return Plain("–")
  end
end

function image(stream::IO)
  start = position(stream)
  while true
    starts_with(stream, "![") || break
    alt = read_until(stream, "]")
    alt == nothing && break
    skip_whitespace(stream)
    starts_with(stream, "(") || break
    url = read_until(stream, ")")
    url == nothing && break
    return Image(url, alt)
  end
  seek(stream, start)
  return nothing
end

standard = Config(
  # Block elements
  ["```", '#', underline_header_trigger],
  [list, indented_code, underline_header, hash_header, paragraph],
  # Inline elements
  "-`*!", [en_dash, inline_code, asterisk_bold, asterisk_italic, image])

flavours[:standard] = standard
