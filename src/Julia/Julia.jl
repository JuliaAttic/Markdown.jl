"""
This file contains markdown extensions designed to make documenting
Julia easy peasy.

We start by borrowing GitHub's `fenced_code` extension – more to follow.
"""

@flavour julia [hashheader, list, indented_code, fenced_code, blockquote, paragraph,
                en_dash, inline_code, asterisk_bold, asterisk_italic, image, link]
