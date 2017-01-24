xquery version "3.0";

module namespace sb="http://clarin.ids-mannheim.de/standards/standardbody";

import module namespace data="http://clarin.ids-mannheim.de/standards/data" at "data.xqm";

declare variable $sb:sbs := doc('../data/sbs.xml')/sbs/sb;

declare function sb:get-org(){
    $sb:sbs[not(@display='hide') and @type="org"]
};

declare function sb:get-sb($id){
    $sb:sbs[@id=$id]
};