export  render, htmldoc

"""
```
render( obj )
```

If given a HTML tag or array of tags, this function returns the string representation of the tag(s). For other objects, the `render` function is identical to the `string` function.
"""
render( htmltag::NormalTag ) = string( join( makeprefix(htmltag), " " ), ">",
    render.(htmltag.content) |> join, "</$(htmltag.tag)>" )
render( htmltag::VoidTag ) = join( push!( makeprefix(htmltag), "/>" ), " " )
render( txt::Text ) = txt.content
render( arr::AbstractArray ) = render.( arr ) |> join
render( str::AbstractString ) = str
render( obj ) = obj |> string


"""
```
htmldoc( headpart, bodypart )
```

This function creates and returns a string representing a HTML page with head section `headpart` and body section `bodypart`. If needed, these parts first get wrapped into a `head` resp. `body` tag.
"""
function htmldoc( headpart, bodypart )
    (headpart isa NormalTag && headpart.tag == "head") ||
        (headpart = Tag"head"(headpart))
    (bodypart isa NormalTag && bodypart.tag == "body") ||
        (bodypart = Tag"body"(bodypart))

    string( "<!DOCTYPE html>\n", Tag"html"( headpart, bodypart ) |> render )
end  # htmldoc( headpart, bodypart )


"""
```
htmldoc( obj )
```

This function creates and returns a string representing a HTML page with empty header and body section `bodypart`.
"""
htmldoc( obj ) = htmldoc( "", obj )


# This function creates the opening tag.
function makeprefix( htmltag::HtmlTag, name::AbstractString )
    prefix = ["<$name"]
    htmltag.id == "" || push!( prefix, string( "id=\"", htmltag.id, "\"" ) )
    isempty(htmltag.classes) || push!( prefix, string( "class=\"",
        join( htmltag.classes, " " ), "\"" ) )
    styles = htmltag.styles
    isempty(styles) || push!( prefix, string( "style=\"",
        join( ["$key: $(styles[key])" for key in keys(styles)], "; " ), "\"" ) )
    attrs = htmltag.attrs
    isempty(attrs) ||
        append!( prefix, [attrs[key] == "" ? "$key" :
            "$key=\"$(attrs[key])\"" for key in keys(attrs)] )
    prefix
end  # makeprefix( htmltag, name )

makeprefix( htmltag::HtmlTag ) = makeprefix( htmltag, htmltag.tag )
