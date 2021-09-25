Try AsciiDoc
------------

There is _no reason_ to prefer http://daringfireball.net/projects/markdown/[Markdown]:
it has *all the features*
footnote:[See http://asciidoc.org/userguide.html[the user guide].]
and more!

NOTE: Great projects use it, including Git, WeeChat and Pacman!

=== Comparison

.Snippets of markup footnote:[More snippets in http://powerman.name/doc/asciidoc[the cheatsheet]]
[cols=",2*<"]
|===
.3+^.^s| Link |AsciiDoc |`http://example.com[Dummy]`
              |Markdown |`[Dummy](http://example.com)`
              |Textile |`"Dummy":http://example.com`

.3+^.^s| Face |AsciiDoc |`Either *bold* or _italic_`
              |Markdown |`Either **bold** or *italic*`
 |Textile  |`Either *bold* or _italic_`

.3+^.^s| Header |AsciiDoc |`== Level 2 ==`
                |Markdown |`## Level 2`
                |Textile  |`h2.  Level 2`
|===

=== Ruby code to render AsciiDoc

[source,ruby]
----
require 'asciidoctor'  # <1>

puts Asciidoctor.render_file('sample.adoc', :header_footer => true)  # <2>
----
<1> Imports the library
<2> Reads, parses and renders the file


And here is some silly math:
e^πi^ + 1 = 0 and H~2~O.
