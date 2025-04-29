xquery version "3.0";

module namespace topic="http://clarin.ids-mannheim.de/standards/topic";

(: Define the methods for accessing topic data
   @author margaretha
:)

(: Select all unhidden topics and sort it by title :)
declare variable $topic:topics := 
    for $topic in doc('/data/topics.xml')/topics/topic[not(data(@display)='hide')]    
    order by $topic/titleStmt/title/text()
    return $topic;

(: Select a topic by id :)
declare function topic:get-topic($id as xs:string){
    $topic:topics[@id=$id]
};