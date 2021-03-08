xquery version "3.0";

module namespace format="http://clarin.ids-mannheim.de/standards/format";

import module namespace data = "http://clarin.ids-mannheim.de/standards/data" at "../model/data.xqm";
import module namespace functx = "http://www.functx.com" at "../resources/lib/functx-1.0-doc-2007-01.xq";

declare variable $format:formats := collection("/db/apps/clarin/data/formats")/format;
declare variable $format:recommendations := doc("../data/incoming/incomingRecommendations.xml")/incomingRecommendations/centre;
declare variable $format:domains := doc("../data/domains.xml")/domains/domain;

declare function format:get-format($id as xs:string){
    $format:formats/descendant-or-self::node()[@id=$id]
};


declare function format:get-all-ids(){
    data($format:formats/descendant-or-self::node()/@id)
};


declare function format:get-recommendations($format-id){
    $format:recommendations/format[@fid=$format-id]
};

