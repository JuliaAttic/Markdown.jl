module Markdown

include("types.jl")
include("parse/parse.jl")
include("parse/standard.jl")
include("parse/GitHub.jl")
include("parse/doc.jl")

include("render/plain.jl")
include("render/html.jl")

include("terminal/render.jl")
include("terminal/pager.jl")

parse(markdown::String; flavour = julia) = parse(IOBuffer(markdown), flavour = flavour)
parse_file(file::String; flavour = julia) = parse(readall(file), flavour = flavour)

export readme, license

readme(pkg::String; flavour = julia) = parse_file(Pkg.dir(pkg, "README.md"), flavour = flavour)
readme(pkg::Module; flavour = julia) = readme(string(pkg), flavour = flavour)

license(pkg::String; flavour = julia) = parse_file(Pkg.dir(pkg, "LICENSE.md"), flavour = flavour)
license(pkg::Module; flavour = julia) = license(string(pkg), flavour = flavour)

end
