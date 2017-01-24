xquery version "3.0";

module namespace topic="http://clarin.ids-mannheim.de/standards/topic";

import module namespace data="http://clarin.ids-mannheim.de/standards/data" at "data.xqm";

declare variable $topic:topics := 
    for $topic in doc('/db/apps/clarin/data/topics.xml')/topics/topic[not(data(@display)='hide')]    
    order by $topic/titleStmt/title/text()
    return $topic;

declare function topic:get-topic($id as xs:string){
    $topic:topics[@id=$id]
};

declare function topic:get-spec-topics($topic-ids){
    $topic:topics[@id=$topic-ids]
};
