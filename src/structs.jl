# Superclass for all HTML tag struct types.
abstract type HtmlTag end

# General struct for normal HTML tags.
mutable struct NormalTag <: HtmlTag
    tag::String
    id::String
    classes::Vector{String}
    styles::Dict{String, Any}
    attrs::Dict{String, Any}
    content::Vector{HtmlTag}

    function NormalTag( name::SSymb, content::AbstractArray{T}; id="",
        classes::Vector{S}=String[],
        styles::Dict{String, A1}=Dict{String, Any}(),
        attrs::Dict{String, A2}=Dict{String, Any}(),
        kwargs... ) where {T <: HtmlTag, S <: AbstractString, A1, A2}
        newtag = new()
        set_tag( newtag, name )
        set_attributes( newtag, id=id, classes=classes, styles=styles,
            attrs=attrs; kwargs... )
        newtag.content = deepcopy(content)
        newtag
    end  # NormalTag( name, content; id, classes, styles, attrs, kwargs... )
end  # mutable struct NormalTag


# General struct for void HTML tags.
mutable struct VoidTag <: HtmlTag
    tag::String
    id::String
    classes::Vector{String}
    styles::Dict{String, Any}
    attrs::Dict{String, Any}

    function VoidTag( name::AbstractString; id="", classes::Vector{S}=String[],
        styles::Dict{String,A1}=Dict{String,Any}(),
        attrs::Dict{String,A2}=Dict{String,Any}(),
        kwargs... ) where {S <: AbstractString, A1, A2}
        newtag = new()
        set_tag( newtag, name )
        set_attributes( newtag, id=id, classes=classes, styles=styles,
            attrs=attrs; kwargs... )
        newtag
    end
end  # mutable struct VoidTag


# Internal type to represent a normal string as content of a Html tag
struct Text <: HtmlTag
    content::String

    Text( str::AbstractString ) = new(string(str))
end  # struct Text

Text( parts... ) = parts |> collect |> join |> Text


# This function sets the name of the HTML tag.
set_tag( newtag::HtmlTag, name::AbstractString ) =
    (newtag.tag = name |> string)


# This function sets all the attributes,a nd puts the id, style, and class in a
#   separate field of the tag.
function set_attributes( newtag::HtmlTag; id="",
    classes::Vector{S}=String[],
    styles::Dict{String, A1}=Dict{String, Any}(),
    attrs::Dict{String, A2}=Dict{String, Any}(),
    kwargs... ) where {S <: AbstractString, A1, A2}
    newtag.id = id |> string
    newtag.classes = classes
    newtag.styles = styles |> Dict{String,Any}
    newtag.attrs = process_attrs( attrs |> Dict{String,Any},
        Pair{Symbol,Any}[kwargs...] )

    combineclasses( newtag.classes, get( newtag.attrs, "class", "" ) )
    delete!( newtag.attrs, "class" )
end  # set_attributes( newtag; id, classes, styles, attrs, kwargs... )


# Processes the keyword attributes and adds them to the ones already in the
#   attrs Dict.
function process_attrs( attrs::Dict{String, T},
    kwargs::Vector{Pair{Symbol, Any}} ) where T
    attrs = Dict{String,Any}(lowercase(attr[1] |> strip) => attr[2] for attr in attrs)

    for (attr, val) in kwargs
        val isa Nothing && continue
        attrs[process_attr(attr)] = val
    end  # for (attr, val) in kwargs

    attrs
end  # process_attrs( attrs, kwargs )


# Processes the name of the attribute to overcome the issue of disallowed
#   symbols.
function process_attr( attr::Symbol )
    attr = attr |> string |> lowercase
    attr = replace( attr, "__" => "-" )
    startswith( attr, '-' ) && (attr = string( '@', attr[2:end] ))
    attr = replace( attr,  "!!" => ":" )
    attr = replace( attr, "!" => "." )
end  # process_attr( attr )
