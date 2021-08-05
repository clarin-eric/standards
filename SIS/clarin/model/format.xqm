xquery version "3.0";

module namespace format="http://clarin.ids-mannheim.de/standards/format";

declare variable $format:formats := collection("/db/apps/clarin/data/formats")/format;
declare variable $format:domains := doc("../data/domains.xml")/domains/domain;

declare function format:get-format($id as xs:string){
    $format:formats/descendant-or-self::node()[@id=$id]
};


declare function format:get-all-ids(){
    data($format:formats/descendant-or-self::node()/@id)
};
