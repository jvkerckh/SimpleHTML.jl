using SimpleHTML
using Test

@testset "SimpleHTML.jl" begin
  
@testset "Tag tests" begin
  ptag = Tag"p"( "This is a HTML paragraph", id="htmlp" )
  @test ptag |> render == "<p id=\"htmlp\">This is a HTML paragraph</p>"

  faicon = fa( "test", width=100 )
  @test "fa" ∈ faicon.classes &&
    "fa-test" ∈ faicon.classes &&
    faicon.attrs["width"] == 100

  ptag |>
    setTagAttribute!( "height", 200 ) |>
    addTagClass!("wbold") |>
    addTagClass!("wslim") |>
    setTagStyle!( "font", "Idunno" )
  @test ptag.attrs["height"] == 200 &&
    "wbold" ∈ ptag.classes &&
    "wslim" ∈ ptag.classes &&
    ptag.styles["font"] == "Idunno"

  ptag |>
    clearTagAttribute!("height") |>
    removeTagClass!("wslim") |>
    clearTagStyle!("font")
  @test !haskey( ptag.attrs, "height" ) &&
    "wbold" ∈ ptag.classes &&
    "wslim" ∉ ptag.classes &&
    !haskey( ptag.styles, "font" )
end  # @testset "Tag tests"

@testset "Render tests" begin
  
end  # @testset "Render tests"
  ttag = Tag"title"( "Title of the app" )
  ptag = Tag"p"( "This is a HTML paragraph", id="htmlp" )
  resstr = """<!DOCTYPE html>
  <html><head><title>Title of the app</title></head><body><p id="htmlp">This is a HTML paragraph</p></body></html>"""
  redstr = replace( resstr, "<title>Title of the app</title>" => "" )
  
  @test htmldoc( Tag"head"(ttag), Tag"body"(ptag) ) == resstr
  @test htmldoc( ttag, ptag ) == resstr
  @test htmldoc( ttag |> render, ptag |> render ) == resstr

  @test htmldoc( Tag"body"(ptag) ) == redstr
  @test htmldoc( ptag ) == redstr
  @test htmldoc( ptag |> render ) == redstr
end  # @testset "SimpleHTML.jl"
