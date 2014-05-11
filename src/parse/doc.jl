#jewel module Markdown

"""
This file contains markdown extensions designed to make documenting
Julia easy peasy.

We start by borrowing GitHub's `fenced_code` extension – more to follow.
"""

julia = Config(
  # Block elements
  ["```", '#', underline_header_trigger],
  [hash_header, list, indented_code, fenced_code, underline_header, paragraph],
  # Inline elements
  "-`*!", [en_dash, inline_code, asterisk_bold, asterisk_italic, image])

flavours[:julia] = julia
