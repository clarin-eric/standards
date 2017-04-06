xquery version "3.0";

module namespace sb="http://clarin.ids-mannheim.de/standards/standardbody";

import module namespace data="http://clarin.ids-mannheim.de/standards/data" at "data.xqm";

(:  Define methods to access the standard body data
    @author margaretha
    @date Dec 2013
:)

(: Select all standard bodies :)
declare variable $sb:sbs := doc('../data/sbs.xml')/sbs/sb;

(: Select all unhidden standard bodies which are organizations :)
declare function sb:get-org(){
    $sb:sbs[not(@display='hide') and @type="org"]
};

(: Select the standard body of the given id :)
declare function sb:get-sb($id){
    $sb:sbs[@id=$id]
};