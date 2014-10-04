# Writing Julia Documentation

Julia documentation is interpreted as Markdown. There's no enforced structure, so simple one-liner descriptions are fine. However, following a couple of lightweight conventions will allow rich environments to take advantage of extra information to provide better autocompletion and help.

## Structure & Style

Many functions have a well-defined meaning and API regardless of the types they operate on. A good example is `push!`, which might be documented like so:

```julia
"""
    push!(collection, items...) -> collection

Append items to the collection.

This will modify the original collection, as
indicated by the `!` modifier.
"""
function push!(...
```

This follows the general structure of "generalised example, one line summary, further information".  For functions like this it's good practice to avoid mentioning types and instead try to capture the *meaning* of a function.

As mentioned above, Julia's rich environments are often able to take advantage of this structure; for example, the argument names will be displayed in the autocomplete menu when the `push!` function is typed, and hovering over the function displays an annotation like so:

```julia
push!(xs, a, b) # Append a, b to the xs.
```

Where the arguments have automatically been interpolated into the docstring. This immediate feedback is a huge help for both writing and reading code.

## Other Notes

Any object displayable as HTML can be interpolated directly into documentation. For example:

```julia
"""
Returns a random walk, which will look something like:

$(plot(y=randwalk(100), x=1:100))

* `n`: The number of samples in the walk.
"""
randwalk(n) = cumsum(rand(n))
```
