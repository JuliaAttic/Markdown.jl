# Markdown

```julia
Markdown.parse("file.md")
readme("Markdown") # or any other installed package
```

**Markdown.jl** is a flexible and efficient markdown parser for Julia.
It currently supports parsing of the most common elements and display
in a terminal.

Currently supported flavours:

  * Standard Markdown (:standard)
  * GitHub Flavoured Markdown (:github)
  * A custom flavour for documentation (:julia)

`:julia` is the default, but others can be chosen with the `flavour`
keyword argument.

In the near future Markdown.jl will provide support for "Literate Julia"
files, as well as output of those files to HTML, PDF, the terminal, and
IJulia notebook format.

![Markdown.jl Example](test.png)
