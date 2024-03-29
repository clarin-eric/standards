xquery version "3.0";

module namespace tm ="http://clarin.ids-mannheim.de/standards/topic-module";
import module namespace app="http://clarin.ids-mannheim.de/standards/app" at "app.xql";
import module namespace spec="http://clarin.ids-mannheim.de/standards/specification" at "../model/spec.xqm";
import module namespace topic="http://clarin.ids-mannheim.de/standards/topic" at "../model/topic.xqm";

(:  Define topic-related functions
    @author margaretha
:)

(: Retrieve a topic node by its topic id :)
declare function tm:get-topic($id as xs:string){
    topic:get-topic($id)
};

(: Generate a list of links to the standards whose topic is the given topic:)
declare function tm:get-specs-by-topic($topic-id as xs:string, $option as xs:string){
    for $spec in $spec:specs
    where contains(data($spec/@topic),$topic-id)
    return
        <li>
            <a href="{app:link(concat("views/view-spec.xq?id=",$spec/@id))}">{$spec/titleStmt/title/text()}</a>
            
            <!-- Generate links to the standard parts also -->
            {if ($option = "part")
             then 
                <ul style="padding-left:15px;list-style-type: circle;"> 
                    {if (count($spec/part)>0) then 
                        for $p in (1 to count($spec/part)) 
                            let $i:= fn:string-join(data($spec/part[$p]/version/@id)[1]," ")
                            let $uri := concat("views/view-spec.xq?id=",$spec/@id,"#",$i)
                        return 
                            <li>
                                <a href="{app:link($uri)}">{$spec/part[$p]/titleStmt/title/text()}</a>
                            </li>
                    else ()}
                </ul>
            else() }
        </li>
}; 

(: Generate the list of topics :)
declare function tm:list-topics(){
    for $topic in $topic:topics
        let $topic-id := $topic/@id
        let $topic-name := $topic/titleStmt/title/text()
        let $topic-snippet := $topic/info[@type="description"]/p[1]/text()     
        let $link := <a href="{app:link(concat("views/view-topic.xq?id=",$topic-id))}"> More...</a>
    return
        <div>
            <li>
               <span class="list-text pointer" onclick="openEditor('{$topic-id}')">{$topic-name}</span>
            </li>
            {if ($topic-name !='Others') then
               <span id="{$topic-id}" style="display:none">
                    <p>{$topic-snippet,$link}</p>
                    <p>Specification categorized in {$topic-name}:</p>
                    <ul style="padding:0px; margin-left:25px;">
                        {tm:get-specs-by-topic($topic-id, "part")}
                    </ul>
                </span>
             else ()}
        </div>
};

(: Print the standard topic(s) as link(s) :)
declare function tm:print-topic($spec,$spec-topics,$option){
    let $num-of-topics := count($spec-topics)
    for $i in (1 to $num-of-topics)
        let $topic := topic:get-topic($spec-topics[$i])
    return (
        <a id="topicid" href="{app:link(concat('views/view-topic.xq?id=',$topic/@id))}">
            {$topic/titleStmt/title/text()}</a> ,
            
        if ($i=$num-of-topics or $num-of-topics=1 or $option="tag") then ()
        (: Multiple topics (for standard view) are separated with a comma :)
        else ', '
    )
            
};

(: Generate a sequence of topics as javascript array objects :)
declare function tm:get-topic-options(){
    for $topic in $topic:topics
      let $topic-name := $topic/titleStmt/title/text()
      let $topic-id := data($topic/@id)       
      return
        concat("['", $topic-id , "','",$topic-name,"']")
};

(: Generate options for all the topics :)
declare function tm:list-topic-options($selectedTopic){
    for $topic in $topic:topics
      let $topic-name := $topic/titleStmt/title/text()
      let $topic-id := data($topic/@id)       
      return
        if ($selectedTopic=$topic-id)
        then <option selected="true" value="{$topic-id}">{$topic-name}</option>
        else <option value="{$topic-id}">{$topic-name}</option>
};