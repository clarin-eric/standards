xquery version "3.0";

declare namespace exist="http://exist.sourceforge.net/NS/exist";
declare option exist:serialize "method=text media-type=text/html indent=yes doctype-system=about:legacy-compat";

for $x in doc("SpecSemAF.xml")/spec/par/version/titleStmt/title
order by $x/title
return $x/title