xquery version "3.0";

module namespace format="http://clarin.ids-mannheim.de/standards/format";

declare variable $format:formats := collection("/db/apps/clarin/data/formats")/format;
declare variable $format:domains := doc("../data/domains.xml")/domains/domain;
declare variable $format:family := doc("../data/format-families.xml")/family-ties;

declare variable $format:titles := $format:formats/titleStmt/title/text();
declare variable $format:ids := data($format:formats/@id);
declare variable $format:abbrs := $format:formats/titleStmt/abbr/text();

declare variable $format:keywords := fn:distinct-values($format:formats/keyword);

declare function format:get-format($id as xs:string){
    $format:formats[@id=$id]
};

(: Select a format by abbr :)
declare function format:get-format-by-abbr($abbr as xs:string){
    $format:formats[titleStmt/abbr=$abbr]
};

declare function format:get-all-ids(){
    data($format:formats/@id)
};

declare function format:get-formats-with-keyword($key as xs:string){
    $format:formats[keyword=$key]
};

