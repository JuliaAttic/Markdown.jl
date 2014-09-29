module Markdown

include("standard/types.jl")
include("parse/parse.jl")
include("standard/standard.jl")
# include("GitHub/GitHub.jl")
# include("doc/doc.jl")

# include("render/plain.jl")
include("render/html.jl")
# include("render/latex.jl")

# include("render/terminal/render.jl")

export readme, license

parse(markdown::String; flavour = julia) = parse(IOBuffer(markdown), flavour = flavour)
parse_file(file::String; flavour = julia) = parse(readall(file), flavour = flavour)

readme(pkg::String; flavour = julia) = parse_file(Pkg.dir(pkg, "README.md"), flavour = flavour)
readme(pkg::Module; flavour = julia) = readme(string(pkg), flavour = flavour)

license(pkg::String; flavour = julia) = parse_file(Pkg.dir(pkg, "LICENSE.md"), flavour = flavour)
license(pkg::Module; flavour = julia) = license(string(pkg), flavour = flavour)

end
