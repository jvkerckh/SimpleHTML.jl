export  @Tag_str, @tag_str, fa,
        setTagAttribute!, clearTagAttribute!,
        addTagClass!, removeTagClass!,
        setTagStyle!, clearTagStyle!

"""
Use: `@Tag_str( name::AbstractString )`

Shortcut: `Tag"name"`

This macro generates a function that allows the user to create a `Tag` (HTML tag) struct.

Example:

`Tag"p"( "This is a HTML paragraph", id="htmlp" )`
"""
macro Tag_str( name::AbstractString )
    quote
        ( content...; kwargs... ) ->
            Tag( $name, content...; kwargs... )
    end
end  # @Tag_str( name )


"""
Use: `@tag_str( name::AbstractString )`

Shortcut: `tag"name"`

This macro generates a function that allows the user to get the HTML string representation of a `HtmlTag` (HTML tag) struct.

Example:

`tag"p"( "This is a HTML paragraph", id="htmlp" )` will generate `"<p id="htmlp">This is a HTML paragraph</p>"`
"""
macro tag_str( name::AbstractString )
    # This has to be done in this manner instead of with a quote because of the @Tag_str macro that is called.
    """render ∘ Tag\"$name\"""" |> Meta.parse |> esc
end  # @tag_str( name )


"""
```
fa( icon::AbstractString; class::AbstractString="", kwargs... )
```

This function creates and returns an `i` HTML tag that represents the icon `icon` from the Font Awesome 4 set.
"""
function fa( icon::AbstractString; class::AbstractString="", kwargs... )
    faclass = string( "fa", " fa-", icon, isempty(class) ? "" : " ", class )
    Tag"i"( class=faclass; kwargs... )
end  # fa( icon; class, kwargs... )


"""
```
setTagAttribute!( attr::Union{Symbol, AbstractString}, val )
setTagAttribute!( tag::HtmlTag, attr::Union{Symbol, AbstractString}, val )
```

This function sets the attribute `attr` of the `HtmlTag` object `tag` to `val`. If this value is `nothing`, the attribute gets removed instead.

The first version of the function permits the use of Julia function chaining: `tag |> setTagAttribute!( :id, "test" )`
"""
setTagAttribute!( attr::SSymb, val ) =
    tag::HtmlTag -> setTagAttribute!( tag, attr, val )

function setTagAttribute!( tag::HtmlTag, attr::SSymb, val )
    atstr = attr |> string
    val isa Nothing && return clearTagAttribute!( tag, attr )
    tag.attrs[atstr] = val
    tag
end  # setTagAttribute!( tag, attr, val )


"""
```
clearTagAttribute!( attr::Union{Symbol, AbstractString} )
clearTagAttribute!( tag::HtmlTag, attr::Union{Symbol, AbstractString} )
```

This function clears the attribute `attr` of the `HtmlTag` object `tag`.

The first version of the function permits the use of Julia function chaining: `tag |> clearTagAttribute!( :id )`
"""
clearTagAttribute!( attr::SSymb ) =
    tag::HtmlTag -> clearTagAttribute!( tag, attr )

function clearTagAttribute!( tag::HtmlTag, attr::SSymb )
    delete!( tag.attrs, attr |> string )
    tag
end  # clearTagAttribute!( tag, attr )


"""
```
addTagClass!( class::Union{Symbol, AbstractString} )
addTagClass!( tag::HtmlTag, class::Union{Symbol, AbstractString} )
```

This function adds the class `class` to the `HtmlTag` object `tag`.

The first version of the function permits the use of Julia function chaining: `tag |> addTagClass!( "test" )`
"""
addTagClass!( class::SSymb ) =
    tag::HtmlTag -> addTagClass!( tag, class )

function addTagClass!( tag::HtmlTag, class::SSymb )
    cstr = class |> string
    cind = findfirst( tag.classes .== cstr )
    cind isa Nothing && push!( tag.classes, cstr )
    tag
end  # addTagClass!( tag, class )


"""
```
removeTagClass!( class::Union{Symbol, AbstractString} )
removeTagClass!( tag::HtmlTag, class::Union{Symbol, AbstractString} )
```

This function removes the class `class` from the `HtmlTag` object `tag`.

The first version of the function permits the use of Julia function chaining: `tag |> clearTagAttribute!( :id )`
"""
removeTagClass!( class::SSymb ) =
    tag::HtmlTag -> removeTagClass!( tag, class )

function removeTagClass!( tag::HtmlTag, class::SSymb )
    cstr = class |> string
    cind = findfirst( tag.classes .== cstr )
    cind isa Nothing || deleteat!( tag.classes, cind )
    tag
end  # removeTagClass!( tag, class )


"""
```
setTagStyle!( attr::Union{Symbol, AbstractString}, val )
setTagStyle!( tag::HtmlTag, attr::Union{Symbol, AbstractString}, val )
```

This function sets the attribute `attr` of the `HtmlTag` object `tag` to `val`. If this value is `nothing`, the attribute gets removed instead.

The first version of the function permits the use of Julia function chaining: `tag |> setTagStyle!( :id, "test" )`
"""
setTagStyle!( attr::SSymb, val ) =
    tag::HtmlTag -> setTagStyle!( tag, attr, val )

function setTagStyle!( tag::HtmlTag, attr::SSymb, val )
    atstr = attr |> string
    val isa Nothing && return clearTagStyle!( tag, attr )
    tag.styles[atstr] = val
    tag
end  # setTagStyle!( tag, attr, val )


"""
```
clearTagStyle!( attr::Union{Symbol, AbstractString} )
clearTagStyle!( tag::HtmlTag, attr::Union{Symbol, AbstractString} )
```

This function clears the attribute `attr` of the `HtmlTag` object `tag`.

The first version of the function permits the use of Julia function chaining: `tag |> clearTagStyle!( :id )`
"""
clearTagStyle!( attr::SSymb ) =
    tag::HtmlTag -> clearTagStyle!( tag, attr )

function clearTagStyle!( tag::HtmlTag, attr::SSymb )
    delete!( tag.styles, attr |> string )
    tag
end  # clearTagStyle!( tag, attr )


# The generic function to create a HTML tag object.
function Tag( name::AbstractString, content...; id="",
    classes::Vector{S1}=String[], class::AbstractString="",
    styles::Dict{S2, A1}=Dict{String, Any}(),
    attrs::Dict{S3, A2}=Dict{String, Any}(),
    kwargs... ) where {S1 <: AbstractString, S2 <: AbstractString, S3 <: AbstractString, A1, A2}
    classes = combineclasses( classes, class )

    Symbol(name |> lowercase) ∈ VOID_TAGS &&
        return VoidTag( name, id=id, classes=classes, styles=styles,
            attrs=attrs; kwargs... )

    NormalTag( name, process_content(content), id=id, classes=classes,
        styles=styles, attrs=attrs; kwargs... )
end  # Tag( name, content; id, classes, styles, attrs, kwargs... )


# This function combines the class and classes attribute
function combineclasses( classes::Vector{S},
    class::AbstractString ) where S <: AbstractString
    tmpclasses = isempty(class) ? deepcopy(classes) : vcat( classes, split( class, " " ) )
    filter!( cl -> !isempty(cl), tmpclasses ) |> unique! |> Vector{String}
end  # combineclasses( classes, class )


# These functions ensure that the content of a HTML tag call gets formatted
#   properly to fit inside the data structure.
process_content( content::Tuple ) = process_content(content |> collect)
process_content( content::AbstractArray ) = isempty(content) ? [Text("")] :
    process_content.(content)[:]
process_content( content::HtmlTag ) = content
process_content( content ) = Text(content |> string)
