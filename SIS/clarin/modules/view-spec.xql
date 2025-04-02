xquery version "3.0";

module namespace vsm="http://clarin.ids-mannheim.de/standards/view-spec";

import module namespace spec="http://clarin.ids-mannheim.de/standards/specification" at "../model/spec.xqm";
import module namespace sb="http://clarin.ids-mannheim.de/standards/standardbody" at "../model/sb.xqm";
import module namespace xsd = "http://clarin.ids-mannheim.de/standards/schema" at "../model/schema.xqm";

import module namespace app="http://clarin.ids-mannheim.de/standards/app" at "app.xql";
import module namespace tm ="http://clarin.ids-mannheim.de/standards/topic-module" at "../modules/topic.xql";
import module namespace sbm="http://clarin.ids-mannheim.de/standards/sb-module" at "../modules/sb.xql";
import module namespace graph="http://clarin.ids-mannheim.de/standards/graph" at "../modules/graph.xql";
import module namespace bib="http://clarin.ids-mannheim.de/standards/bibliography" at "../modules/bib.xql";
import module namespace vvm="http://clarin.ids-mannheim.de/standards/view-version" at "../modules/view-version.xql";

import module namespace functx = "http://www.functx.com";

(:  Define standard-relation functions
    @author margaretha
    @date Dec 2013
:)

(: Retrieve the spec node of the given spec-id :)
declare function vsm:get-spec($id as xs:string){
    spec:get-spec($id)
};

(: Get the topic of the given standard :)
declare function vsm:get-spec-topic($spec){
    spec:get-topics($spec)
};

(: Create the json object for the relation graph in a standard page :)
declare function vsm:get-spec-json($spec){
    let $part-ids := $spec/descendant-or-self::part/@id
    let $version-ids := $spec/descendant-or-self::version/@id
    let $ids := functx:value-union($part-ids,$version-ids)    
    let $ids := fn:insert-before($ids,1,$spec/@id)    
    let $ids := functx:value-union($ids,$spec//*/@target)
        
    let $relations := xsd:get-relations()    
    let $isVersionOf := graph:get-color($relations,"isVersionOf")
    (: Create links between the spec and the spec versions :)
    let $isVersionOf-links :=
        for $version in $spec/descendant-or-self::version            
            let $version-index := fn:index-of($ids,data($version/@id))-1
            let $parent-index := fn:index-of($ids,$version/parent::node()/@id)-1
        return graph:create-link($version-index, $parent-index, $isVersionOf)
        
    (: Create links between the spec and the spec parts :)    
    let $spec-index := fn:index-of($ids,data($spec/@id))-1
    let $isPartOf := graph:get-color($relations,"isPartOf")
    let $isPartOf-links :=
        for $part in $spec/descendant-or-self::part            
            let $part-index := fn:index-of($ids,data($part/@id))-1            
        return graph:create-link($part-index, $spec-index, $isPartOf)
        
    (: Create links of the version relations :)
    let $version-links := graph:create-version-link($spec,$ids,$relations)
    let $spec-relations := 
        for $sr in $spec/relation         
        let $sr-index := fn:index-of($ids,data($sr/@target))-1
        let $sr-color := graph:get-color($relations,$sr/@type)
        return graph:create-link($spec-index,$sr-index,$sr-color)
    
    let $json-nodes := string-join(
        for $id in $ids 
        return graph:create-spec-node(vsm:get-spec($id))
    , ",")
        
    let $json-links := string-join(
        functx:value-union(
            functx:value-union($isPartOf-links, 
                functx:value-union($isVersionOf-links,$version-links)),
            $spec-relations)
    ,",")
    
    let $json := concat("{", 
        graph:write-json-array("nodes", $json-nodes) ,",",
        graph:write-json-array("links", $json-links),
    "}") 
      
    return fn:replace($json,"\n+\s*"," ")
    
};

(: Define the edit button for web-admin :)
declare function vsm:print-edit-button($arg){
    if (session:get-attribute("user") = 'webadmin')
    then <button class="edit" type="button" onclick="openEditor('{$arg}');">Edit</button>    
    else ()
};

(: Define the standard name view and its edit form :)
declare function vsm:print-spec-name($spec){
    let $spec-name := $spec/titleStmt/title/text()
    return (
        <div class="title">
            <span id="nametext">{$spec-name}</span>
            {vsm:print-edit-button("editname")}         
       </div>,
       if (session:get-attribute("user") = 'webadmin')
       then 
            <div id="editname" style="display:none">                   
                <input id="name" value="{$spec-name}" type="text" class="inputText" placeholder="Insert a standard name" style="width:450px;"/>                
                <button type="button" class="button" 
                  onclick="update('{$spec/@id}','name','name','editname');">Submit</button>
                <span  id="errorname" style="display:none; color:red; font-size:13px; margin=0;">* Please insert a name.</span>
            </div>
       else()
   )
};

(: Define the standard abbreviation view and its edit form :)
declare function vsm:print-spec-abbr($spec){
    let $spec-abbr := $spec/titleStmt/abbr
    let $display :=  if (data($spec-abbr/@internal) = "yes") then "inline" else "none"
    return (
        <div>
            <span class="heading">Abbreviation: </span>
            <span id="abbrtext" class="heading"> {$spec-abbr}</span>
            
            <!-- Comments for non-official abbreviations -->
            <span id="abbrinternalText" style="font-size:10px;margin-left:5px;display:{$display}">
                [not official, only for reference in this website]</span>
                
            {vsm:print-edit-button("editabbr")}
        </div>,
        if (session:get-attribute("user") = 'webadmin')
        then
            <div id="editabbr" style="display:none">
            <input id="abbr" value="{$spec-abbr}" type="text" placeholder="Insert an abbreviation" 
                class="inputText" style="width:345px; margin-left:2px;"/>
            <select id="abbrinternal" name="internal" class="inputSelect" style="margin-left:3px; width:100px;">
                {if (data($spec-abbr/@internal) = 'yes')
                 then (
                    <option selected='selected' value="internal">internal</option>,
                    <option value="official">official</option>
                    )
                 else (
                    <option value="internal">internal</option>,
                    <option selected='selected' value="official">official</option>
                    ) 
                }
            </select>
            <button type="button" class="button" 
              onclick="update('{$spec/@id}','abbr','abbr','editabbr');">Submit</button>
            <span  id="errorabbr" style="display:none; color:red; font-size:13px; margin=0;">* Please insert an abbr.</span>
            </div>
       else()
     )
};

declare function vsm:print-recommendation($spec,$spec-id){
    let $recommendations := $spec/ClarinRecommendation/recommendation
    let $n := count($recommendations)
    return 
        if ($recommendations)
        then 
            <div><span class="heading">Use in CLARIN: </span>
            {for $i in 1 to $n
                let $id := data($recommendations[$i]/@specId)
                let $link := concat("views/view-spec.xq?id=",$spec-id,"#",$id)
                let $type := data($recommendations[$i]/@type)
             return 
                if ($spec-id = $id)
                then $type
                else (<a href="{app:link($link)}">{vsm:get-spec($id)/titleStmt/abbr/text()}</a>, 
                    concat(" (",$type,")",if ($i < $n) then ", " else ()))
            }
           </div>
       else ()
};

(: Define the standard scope view and its edit form :)
declare function vsm:print-spec-scope($spec){
   (
   <div><span class="heading">Scope: </span><span id="scopetext">{$spec/scope/text()}</span>
    {vsm:print-edit-button("editscope")}    
   </div> ,
   if (session:get-attribute("user") = 'webadmin')
   then 
    <div id="editscope" style="display:none">
      <input id="scope" value="{$spec/scope/text()}" placeholder="Describe the standard purpose, e.g. Corpus annotation." type="text" 
        class="inputText" style="width:450px;"/>
      <button type="button" class="button" onclick="update('{$spec/@id}','scope','scope','editscope')">Submit</button>
    </div>
    else()
   )      
};

(: Define the standard topic view and its edit form :)
declare function vsm:print-spec-topic($spec,$spec-topic){        
    let $numtopics := count($spec-topic)
    let $topic-options := concat("[",fn:string-join(tm:get-topic-options(),","),"]")
    
    return (
    
        <div><span class="heading">Topic: </span>
           <span id="topictext">{tm:print-topic($spec,$spec-topic,"")}</span>   
           {vsm:print-edit-button("edittopic")}           
         </div>,
         if (session:get-attribute("user") = 'webadmin')
         then 
              <div id="edittopic" style="display:none">           
                  { for $i in (1 to $numtopics)
                      return (
                          <select id="topic{$i}" name="topic{$i}" class="inputSelect" style="margin-bottom:3px; display:inline">
                            <option value=""/>
                            {tm:list-topic-options($spec-topic[$i])}                            
                        </select>,
                        if ($i=1)
                        then (<button type="button" id="addtopic" class="button" style="margin-bottom:3px;" 
                                onclick="addTopic('topic',{$numtopics},{$topic-options})">Add</button>,                                    
                              <button type="button" class="button" style="margin-bottom:3px;" 
                                onclick="update('{$spec/@id}','topic',{$numtopics},'edittopic')">Submit</button>)
                        else ()                                                
                    )
                  }
                  <span  id="errortopic" style="display:none; color:red; font-size:13px; margin=0;">* Please select a topic.</span>
                </div>
           else()
    )
};

declare function vsm:print-spec-relation($spec,$spec-id,$isFormat as xs:boolean){
    vvm:print-version-relation($spec-id,$spec,$spec-id,$isFormat)
};

(: Define the standard body view and its edit form :)
declare function vsm:print-spec-sb($spec-sb, $spec-id){
        <div>            
             <span class="heading">Standard body: </span>
             <span id="sbtext">{sbm:print-sb-link($spec-sb)}</span>
             {vsm:print-edit-button("editsb")}            
         </div>,
         if (session:get-attribute("user") = 'webadmin')
         then 
            <div id="editsb" style="display:none">
                   <select id="sb" name="sb" class="inputSelect">
                  <option value=""/>
                    {sbm:list-sbs-options($spec-sb)}
                  </select>
                  <button type="button" class="button" onclick="update('{$spec-id}','sb','sb','editsb')">Submit</button>
                  <span  id="errorsb" style="display:none; color:red; font-size:13px; margin=0;">* Please select a standard body.</span>
            </div>
         else()
};

(: Print the standard keywords and the edit form :)
declare function vsm:print-spec-keywords($keywords, $spec-id){
    (:let $keywords := for $k in $keywords order by $k return $k:)
    let $numkeys := count($keywords)
    let $max := fn:max(($numkeys,1))
    return (
        if (session:get-attribute("user") = 'webadmin' or $numkeys > 0)
         then 
         <div><span class="heading">Keywords: </span>
             <span id="keytext">
                 {for $k in (1 to $numkeys)
                  (:order by $keywords[$k]:)
                  return (
                     $keywords[$k],
                     if ($k=$numkeys) then () else ", "
                  )
                 }
             </span>
              {vsm:print-edit-button("editkey")}              
         </div>
         else (),
         if (session:get-attribute("user") = 'webadmin')
         then 
                <div id="editkey" style="display:none">
                    { for $i in (1 to $max)
                          return (
                              <input id="key{$i}" name="key{$i}" type="text" value="{$keywords[$i]}" 
                                   class="inputText" style="width:450px; margin-bottom:3px; display:inline"/>,        	             
                            if ($i=1)
                            then (<button type="button" id="addkey" class="button" style="margin-bottom:3px;" 
                                    onclick=" addElement('key','input','text',{$max})">Add</button>,
                                  <button type="button" class="button" style="margin-bottom:3px;" 
                                    onclick="update('{$spec-id}','key',{fn:max($max)},'editkey')">Submit</button>)
                            else ()) 
                    }
                </div>
         else()
     )
};

(: Print links from standard keywords for the tag cloud :)
declare function vsm:print-keyword-links($spec){    
    for $keyword in $spec/keyword[text() != $spec/titleStmt/abbr/text()]
        let $a := $spec:specs[titleStmt/abbr/text()=$keyword]
        return
            if ($a)
            then <a style="font-size:15px;" href="{app:link(concat('views/view-spec.xq?id=',$a/@id))}">{$keyword/text()}</a>
            else <a style="font-size:15px;" onclick="return false">{$keyword/text()}</a>            
};

(: Print the standard body link for the tag cloud :)
declare function vsm:print-sb-link($sb){
    if ($sb != "SBOther")
    then <a style="font-size:15px;" href="{app:link(concat("views/view-sb.xq?id=",$sb))}">
       {sb:get-sb($sb)/titleStmt/abbr}</a>
    else ()
};

(: Print the links to the standard versions for the tag cloud :)
declare function vsm:print-version-links($spec,$keywords){    
    let $spec-versions := $spec/descendant-or-self::version/@id
    let $relation-targets := $spec/descendant-or-self::version/relation/@target        

    for $id in functx:value-union($relation-targets,$spec-versions)
        let $target-node := $spec:specs/descendant-or-self::*[@id=$id]
         
        let $target-name :=
            if ($target-node/titleStmt/abbr/text()) 
                then $target-node/titleStmt/abbr/text()                           
            else concat($target-node/ancestor::spec/titleStmt/abbr/text(),
                "-",substring($target-node/date,1,4))            
        
        let $link := 
            if ($target-node/@standardSettingBody)
            then concat('views/view-spec.xq?id=',$target-node/data(@id))
            else concat('views/view-spec.xq?id=',$target-node/ancestor::spec/data(@id),'#',data($target-node/@id))
        
        let $text := $target-name 
        return
         if (functx:is-value-in-sequence(lower-case($text),$keywords))
            then ()
            else
                if (functx:is-value-in-sequence($id,$relation-targets))
                then <a style="font-size:15px" href="{app:link($link)}">{$text}</a>
                else <a style="font-size:12px" href="{app:link($link)}">{$text}</a>
};

(: Print the description and its edit form :)
declare function vsm:print-desc($id,$desc,$uri,$error){
    let $display := if ($error) then "block" else "none"
    return 
    (
    <span id="desctext{$id}" class="desctext">{$desc}</span>,
         if (session:get-attribute("user") = 'webadmin')
         then <button class="edit" type="button" onclick="openEditor('editdesc{$id}');">Edit description</button>    
         else (),
         if (session:get-attribute("user") = 'webadmin')
         then
            <form method="post" action="{app:link($uri)}">
                <table id="editdesc{$id}" style="display:{$display};">
                    <tr>
                        <td>
                            <textarea name="value" class="desctext" style="width:550px; height:150px; resize: none; font-size:11px;">
                            { for $d in $desc/* return 
                                <p> {
                                    for $p in $d/node() return
                                        if (functx:node-kind($p) = "text") 
                                        then replace($p,"&lt;","&amp;lt;")
                                        else $p
                                     }
                                </p>
                            } </textarea> 
                        </td>
                        <td valign="top">
                            <button type="submit" name="submitButton" class="button">Submit</button>
                        </td>           
                    </tr>
                    <tr>
                         <td colspan="2" style="color:red">
                            { if ($error ='')
                              then ()                  
                              else if ($error = 'empty')
                              then ("Please write some description.")
                              else $error}
                        </td>
                    </tr>
                </table>
            </form>           
        else()
    )
};

(: Print standard description :)
declare function vsm:print-spec-description($desc, $spec-id){
    let $uri := concat("edit/edit-process.xq?id=", $spec-id,"&amp;vid=&amp;path=desc")
    let $error := request:get-parameter(concat("errorDesc",$spec-id),"")        
    return (<span class="heading">Description: </span>,vsm:print-desc($spec-id,$desc,$uri,$error))
};

(: Print the links to standard documents such as examples, and the upload form :)
declare function vsm:print-spec-assets($spec-id,$ref){    
    let $numrefs := count($ref)    
    let $d := request:get-parameter(concat("display",$spec-id),"none")
    return
        if (session:get-attribute("user") or (session:get-attribute("user") = 'webadmin' or count($ref)>0))
        then (
            <div>
                <span class="heading">Reference(s): </span>
                <span id="ref{$spec-id}text">
                    {for $k in (1 to $numrefs)
                        let $comma := if ($k > 1) then ", " else ()
                        let $link := app:link(concat("data/doc/",$ref[$k]/@href))
                        
                     return (
                        <span id="ref{$spec-id}text{$k}">{$comma} <a href="{$link}">{$ref[$k]/text()}</a></span>,
                        if (session:get-attribute("user") = 'webadmin')
                        then <button id="ref{$spec-id}text{$k}button" class="edit" style="margin:0 3px 0 3px;" type="button"  
                             onclick="removeElement('{$spec-id}','ref{$spec-id}text{$k}','{$ref[$k]/text()}');">Remove</button>                            
                        else ()
                     )
                    }
                </span>
                { if (session:get-attribute("user") = 'webadmin')
                  then <button class="edit" style="margin-left:3px" type="button" onclick="openEditor('editref');">Upload</button>
                  else ()
                }
            </div>
            ,
            if (session:get-attribute("user") = 'webadmin')
            then 
             <div id="editref" style="display:{$d}">
                 <form enctype="multipart/form-data" method="post" 
                     action="{xs:anyURI(concat("../edit/edit-process.xq?id=", $spec-id,"&amp;task=upload&amp;pid=",$spec-id ))}">
                     <input id="ref{$spec-id}1" name="ref{$spec-id}1" type="file" class="inputFile" style="display:inline"/>
                     <button type="button" id="addref" class="button" style="margin-bottom:3px;" 
                          onclick="addElement('ref{$spec-id}','input','file',1)">Add</button>                      
                    <button type="submit" name="submitButton" class="button" style="margin-bottom:3px;">Upload</button>
                 </form>
                 <span id="errorRev{$spec-id}" style="display:{$d}; 
                    color:red; font-size:13px; margin=0;">* The upload was unsucccesful.</span>
             </div>
            else()
        )
        else()
};


(: Print the standard bibliography :)
declare function vsm:print-spec-bibliography($bib){
    if ($bib)
    then <div><span class="heading">Recommended Reading: </span><br/>
            <ul> {bib:get-references($bib)}</ul>
         </div>
    else ()
};

(: Print related standard whose the same topic(s) as the given standard :)
declare function vsm:print-topic-specs($spec-id,$spec-topics){
    let $specs := functx:distinct-nodes(
        for $topic-id in $spec-topics
        return $spec:specs[contains(@topic,$topic-id) and @id!=$spec-id]
    )
    return 
    if ($specs) then 
        <div><span class="heading">Other standards in the same topic(s):</span>
            <ul>{for $spec in $specs
                 let $link := app:link(concat("views/view-spec.xq?id=",$spec/@id))
                 order by $spec/titleStmt/title/text()
                 return <li><a href="{$link}">
                    {$spec/titleStmt/title/text()}</a></li>
                }
            </ul>
        </div>
    else ()
};

(: Print standard parts :)
declare function vsm:print-spec-part($spec){
    for $part in $spec/part
    let $spec-id := $spec/@id
    let $part-id := $part/@id
    return 
        <div class="version" id="{$part/@id}">
            {vvm:print-version-name("Part title: ",$spec-id,$part,$part-id)}
            {vvm:print-version-abbr($spec-id,$part,$part-id) }           
            {vvm:print-version-description($spec-id,$part,$part-id) }
            { vvm:print-version-recommendation($part) }
            {vvm:print-version($spec,$part,"part")}
        </div>    
};

(: Print the add part and add version buttons for web-admin :)
declare function vsm:print-add-button($spec-id){
    let $part-uri := concat("views/add-spec-part.xq?id=",$spec-id)
    let $version-uri := concat("views/add-spec-version.xq?id=",$spec-id)
    return

    if (session:get-attribute("user") = 'webadmin')
    then <div style="margin-bottom:20px">
            <button type="button" class="button" style="width:110px;" onclick="location.href='{app:link($part-uri)}'">Add Part</button>
            <span style="display:inline-block; width:2px"/>
            <button type="button" class="button" style="width:110px;" onclick="location.href='{app:link($version-uri)}'">Add Version</button>           
         </div> 
    else ()
};

(: Print standard versions :)
declare function vsm:print-spec-version($spec){
    vvm:print-version($spec,$spec,"version")
};

(: Print the standard relation graph :)
declare function vsm:print-graph($spec){
    
    let $spec-relations := fn:distinct-values($spec/descendant-or-self::*/relation/@type)
    let $relations := xsd:get-relations()
    let $idx := fn:index-of($relations,"isVersionOf")
    let $ispartOf-idx := fn:index-of($relations,"isPartOf")
    
    return 
    if (count($spec-relations)>0)
    then 
        <div id="chart" class="version">
            <div><span class="heading3">Relations</span></div>
            <div class="version" style="width:140px; float:right; padding:0px">
             <table>
                 <tr>
                     <td colspan="2"><b>Legend:</b></td>                    
                 </tr>                             
                 {for $r in $spec-relations
                     let $color := graph:get-color($relations,$r)
                     return
                         <tr>
                             <td><hr style="border:0; color:{$color}; background-color:{$color}; height:2px; width:20px" /></td>
                             <td>{data($r)}</td>
                         </tr>
                 }
                {if($spec/descendant-or-self::version)
                then
                <tr>
                     <td><hr style="border:0; color:{$graph:colors[$idx]}; background-color:{$graph:colors[$idx]}; height:2px; width:20px" /></td>
                     <td>isVersionOf</td>
                </tr>
                else ()
                }
                {if ($spec/descendant-or-self::part)
                then 
                <tr>
                     <td><hr style="border:0; color:{$graph:colors[$ispartOf-idx]}; background-color:{$graph:colors[$ispartOf-idx]}; height:2px; width:20px" /></td>
                     <td>isPartOf</td>
                </tr>
                else ()
                }                 
             </table>
           </div>    
        </div>
    
    else ()
};


declare function vsm:print-url($spec){
    let $urls := $spec/address[@type='URL']
    let $numurls := count($urls)
    
    return (
        if ($spec/address)
        then <div><span class="heading3">URL(s): </span>
                <span id="urltext{$spec/@id}">
                {for $i in (1 to $numurls)                     
                 return (<a href="{$urls[$i]/text()}">{$urls[$i]/text()}</a>,
                     if ($i < $numurls) then ', ' else ())
                }
                </span>                
              </div>
          else ()          
       )
};
