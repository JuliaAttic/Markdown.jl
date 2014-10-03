# Block elements
# ––––––––––––––

function paragraph(stream::IO, md::MD, config::Config)
  buffer = IOBuffer()
  p = Paragraph()
  push!(md, p)
  skipwhitespace(stream)
  while !eof(stream)
    char = read(stream, Char)
    if char == '\n' || char == '\r'
      if blankline(stream) || parse(stream, md, config, breaking = true)
        break
      else
        write(buffer, ' ')
      end
    else
      write(buffer, char)
    end
  end
  p.content = parseinline(seek(buffer, 0), config)
  return true
end

@breaking true ->
function hashheader(stream::IO, md::MD, config::Config)
  startswith(stream, "#") || return false
  level = 1
  while startswith(stream, "#")
    level += 1
  end
  h = readline(stream) |> chomp
  h = match(r"\s*(.*)(?<![#\s])", h).captures[1]
  buffer = IOBuffer()
  print(buffer, h)
  if !isempty(h)
    push!(md.content, Header(parseinline(seek(buffer, 0), config), level))
    return true
  else
    return false
  end
end

function indentcode(stream::IO, block::MD, config::Config)
  withstream(stream) do
    buffer = IOBuffer()
    while startswith(stream, "    ") || startswith(stream, "\t")
      write(buffer, readline(stream))
    end
    code = takebuf_string(buffer)
    !isempty(code) && (push!(block, Code(chomp(code))); return true)
    return false
  end
end

# TODO: Laziness
@breaking true ->
function blockquote(stream::IO, block::MD, config::Config)
  withstream(stream) do
    buffer = IOBuffer()
    while startswith(stream, ">")
      startswith(stream, " ")
      write(buffer, readline(stream))
    end
    md = takebuf_string(buffer)
    if !isempty(md)
      push!(block, BlockQuote(parse(md, flavour = config).content))
      return true
    else
      return false
    end
  end
end

# Todo: ordered lists, inline formatting
function list(stream::IO, block::MD, config::Config)
  withstream(stream) do
    skipwhitespace(stream)
    startswith(stream, ["* ", "• "]) || return false
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
          if next == '\n'
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
end

# Inline elements
# –––––––––––––––

@trigger '*' ->
function asterisk_italic(stream::IO)
  result = parse_inline_wrapper(stream, "*")
  return result == nothing ? nothing : Italic(result)
end

@trigger '*' ->
function asterisk_bold(stream::IO)
  result = parse_inline_wrapper(stream, "**")
  return result == nothing ? nothing : Bold(result)
end

@trigger '`' ->
function inline_code(stream::IO)
  result = parse_inline_wrapper(stream, "`")
  return result == nothing ? nothing : Code(result)
end

@trigger '!' ->
function image(stream::IO)
  withstream(stream) do
    startswith(stream, "![") || return
    alt = readuntil(stream, ']', match = '[')
    alt ≡ nothing && return
    skipwhitespace(stream)
    startswith(stream, '(') || return
    url = readuntil(stream, ')', match = '(')
    url ≡ nothing && return
    return Image(url, alt)
  end
end

@trigger '[' ->
function link(stream::IO)
  withstream(stream) do
    startswith(stream, '[') || return
    text = readuntil(stream, ']', match = '[')
    text ≡ nothing && return
    skipwhitespace(stream)
    startswith(stream, '(') || return
    url = readuntil(stream, ')', match = '(')
    url ≡ nothing && return
    return Link(text, url)
  end
end

# Punctuation

@trigger '-' ->
function en_dash(stream::IO)
  if startswith(stream, "--")
    return "–"
  end
end

const escape_chars = "\\`*_#+-.!{[("

@trigger '\\' ->
function escapes(stream::IO)
  withstream(stream) do
    if startswith(stream, "\\") && !eof(stream) && (c = read(stream, Char)) in escape_chars
      return string(c)
    end
  end
end

# Config
# ––––––

@flavour common [list, indentcode, blockquote, hashheader, paragraph,
                 escapes, en_dash, inline_code, asterisk_bold, asterisk_italic, image, link]
