xquery version "3.0";

module namespace format="http://clarin.ids-mannheim.de/standards/format";

import module namespace data = "http://clarin.ids-mannheim.de/standards/data" at "../model/data.xqm";
import module namespace functx = "http://www.functx.com" at "../resources/lib/functx-1.0-doc-2007-01.xq";

declare variable $format:formats := collection("/db/apps/clarin/data/formats")/format;

declare function format:get-format($id as xs:string){
    $format:formats/descendant-or-self::node()[@id=$id]
};

