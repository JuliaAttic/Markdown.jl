module Markdown

include("types.jl")
include("terminal/render.jl")
include("terminal/pager.jl")

pager(s::Content) =
  isdefined(Markdown, :tty) ?
    pager(tty, lines(terminal_str(s, columns = size(tty).width))) :
    error("Please evaluate `fft_doc` first.")

# Test

export fft_doc, pager

lorem = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed egestas ultrices eros non consectetur. Duis luctus tortor velit, sed varius sem tristique at. Sed consectetur luctus diam, nec eleifend sapien suscipit sit amet. Ut at dui at nibh varius egestas vel in mauris. Cras et nisl eu leo lacinia consectetur. Maecenas ornare massa magna, in faucibus tortor condimentum vel. Aliquam feugiat purus sit amet fringilla mollis. Proin a enim massa. Curabitur cursus velit quam, sit amet feugiat sem eleifend id. Ut velit leo, porta eget facilisis sed, suscipit vel felis. Aliquam at sem ac metus tempor tincidunt et non mi. Proin ipsum nunc, molestie vel urna eget, gravida aliquam neque. Praesent elementum, quam et rutrum fringilla, mi tortor gravida nisl, non tempor mi urna sed urna. Cras vel viverra dui, id eleifend nunc. Ut diam tortor, sagittis ut venenatis in, fermentum id risus."

fft_doc = Block(
  Header("The Fast Fourier Transform"),
  Paragraph(Plain("Use the "), Code("fft"), Plain(" function to carry out a "),
            Bold("Fast Fourier Transform"), Plain(". Do "), Italic("not"),
            Plain(" use it if you wish to perform a slow fourier transform – see "),
            Code("sft"), Plain(".")),
  Code("""
  fft([1,2,3]) ==
    [6.0+0.0im, -1.5+0.866025im, -1.5-0.866025im]"""),
  Paragraph(Plain("Lorem ipsum dolor sit amet:")),
  List(Block(Plain("Consectetur adipiscing "), Bold("elit"), Plain(".")),
       Plain("Sed egestas ultrices eros non consectetur."),
       Plain("Duis luctus tortor velit, sed varius sem tristique at.")),
  Paragraph(Plain(lorem)))

end
