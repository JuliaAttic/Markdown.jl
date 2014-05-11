module Markdown

lorem = """
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed egestas
ultrices eros non consectetur. Duis luctus tortor velit, sed varius sem
tristique at. Sed consectetur luctus diam, nec eleifend sapien suscipit
sit amet. Ut at dui at nibh varius egestas vel in mauris. Cras et nisl
eu leo lacinia consectetur. Maecenas ornare massa magna, in faucibus
tortor condimentum vel. Aliquam feugiat purus sit amet fringilla mollis.
Proin a enim massa. Curabitur cursus velit quam, sit amet feugiat sem
eleifend id. Ut velit leo, porta eget facilisis sed, suscipit vel felis.
Aliquam at sem ac metus tempor tincidunt et non mi. Proin ipsum nunc,
molestie vel urna eget, gravida aliquam neque. Praesent elementum, quam
et rutrum fringilla, mi tortor gravida nisl, non tempor mi urna sed
urna. Cras vel viverra dui, id eleifend nunc. Ut diam tortor, sagittis
ut venenatis in, fermentum id risus.
"""

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
