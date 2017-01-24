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

import module namespace functx = "http://www.functx.com" at "../resources/lib/functx-1.0-doc-2007-01.xq";

declare function vsm:get-spec($id as xs:string){
    spec:get-spec($id)
};

declare function vsm:get-spec-topic($spec){
    spec:get-topics($spec)
};

declare function vsm:get-spec-json($spec){
    let $ids := $spec/descendant-or-self::version/@id
    let $ids := fn:insert-before($ids,1,$spec/@id)    
    let $ids := functx:value-union($ids,$spec//*/@target)
        
    let $relations := xsd:get-relations()
    let $spec-links :=
        for $version in $spec/descendant-or-self::version
            let $spec-index := fn:index-of($ids,data($spec/@id))-1
            let $version-index := fn:index-of($ids,data($version/@id))-1
        return graph:create-link($version-index, $spec-index, graph:get-color($relations,"isVersionOf"))        
    let $version-links := graph:create-version-link($spec,$ids,$relations)        
    
    let $json-nodes := string-join(
        for $id in $ids 
        return graph:create-spec-node(vsm:get-spec($id))
    , ",")
        
    let $json-links := string-join(
        functx:value-union($spec-links,$version-links)
    ,",")
    
    let $json := concat("{", 
        graph:write-json-array("nodes", $json-nodes) ,",",
        graph:write-json-array("links", $json-links),
    "}") 
      
    return fn:replace($json,"\n+\s*"," ")
};

declare function vsm:print-edit-button($arg){
    if (session:get-attribute("user") = 'webadmin')
    then <button class="edit" type="button" onclick="openEditor('{$arg}');">Edit</button>    
    else ()
};

declare function vsm:print-spec-name($spec, $spec-name){
    let $spec-abbr := $spec/titleStmt/abbr/text()
    return (
        <div>
         { if ($spec-abbr and $spec-abbr !='') 
           then ( <span id="nametext" class="title">{$spec-name}</span>, 
                  <span id="abbrtext" class="title"> ({$spec-abbr})</span>)
           else (<span id="nametext" class="title"> {$spec-name}</span>,<span id="abbrtext" class="title"/>)
         }
         {vsm:print-edit-button("editname")}         
       </div>,
       if (session:get-attribute("user") = 'webadmin')
       then 
            <div id="editname" style="display:none">                   
                <input id="name" value="{$spec-name}" type="text" class="inputText" placeholder="Insert a standard name" style="width:450px;"/>
                <input id="abbr" value="{$spec-abbr}" type="text" placeholder="Insert an abbreviation" class="inputText" style="width:142px; margin-left:2px;"/>
                <button type="button" class="button" 
                  onclick="update('{$spec/@id}','name','name','editname');update('{$spec/@id}','abbr','abbr','editname');">Submit</button>
                <span  id="errorname" style="display:none; color:red; font-size:13px; margin=0;">* Please insert a name.</span>
            </div>
       else()
   )
};

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

declare function vsm:print-spec-sb($spec-sb, $spec-id){
        <div>{ if (sb:get-sb($spec-sb)[@type != "org"])
               then <span class="heading">Designer: </span>
               else <span class="heading">Standard body: </span>
             }            
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

declare function vsm:print-spec-keywords($keywords, $spec-id){
    let $keywords := for $k in $keywords order by $k return $k
    let $numkeys := count($keywords)
    let $max := fn:max(($numkeys,1))
    return (
        if (session:get-attribute("user") = 'webadmin' or $numkeys > 0)
         then 
         <div><span class="heading">Keywords: </span>
             <span id="keytext">
                 {for $k in (1 to $numkeys)
                  order by $keywords[$k]
                  return 
                     if ($k=$numkeys) then $keywords[$k]
                     else ($keywords[$k], ", ")}
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

declare function vsm:print-keyword-links($spec){    
    for $keyword in $spec/keyword[text() != $spec/titleStmt/abbr/text()]
        let $a := $spec:specs[titleStmt/abbr/text()=$keyword]
        return
            if ($a)
            then <a style="font-size:15px;" href="{app:link(concat('views/view-spec.xq?id=',$a/@id))}">{$keyword/text()}</a>
            else <a style="font-size:15px;" onclick="return false">{$keyword/text()}</a>
            
};

declare function vsm:print-sb-link($sb){
    if ($sb != "SBOther")
    then <a style="font-size:15px;" href="{app:link(concat("views/view-sb.xq?id=",$sb))}">
       {sb:get-sb($sb)/titleStmt/abbr}</a>
    else ()

};

declare function vsm:print-version-links($spec,$keywords){    
    let $spec-versions := $spec/descendant-or-self::version/@id
    let $relation-targets := $spec/descendant-or-self::version/relation/@target        

    for $id in functx:value-union($relation-targets,$spec-versions)
        let $target-node := $spec:specs/descendant-or-self::*[@id=$id]
         
        let $target-name :=
            if ($target-node/titleStmt/abbr/text()) 
                then $target-node/titleStmt/abbr/text()
            else if ($target-node/titleStmt/title/text()) 
                then $target-node/titleStmt/title/text()
            else if ($target-node/ancestor::node()/titleStmt/abbr/text()) 
                then $target-node/ancestor::node()/titleStmt/abbr/text()
            else $target-node/ancestor::node()/titleStmt/title/text()
            
        let $target-name := if (fn:string-length($target-name) > 40) 
        then fn:concat(fn:substring($target-name,1,40),"...") 
        else $target-name
        
        let $link := 
            if ($target-node/@standardSettingBody)
            then concat('views/view-spec.xq?id=',$target-node/data(@id))
            else concat('views/view-spec.xq?id=',$target-node/ancestor::spec/data(@id),'#',data($target-node/@id))
        
        let $text := concat($target-name," ", $target-node/versionNumber[@type="major"], " ", $target-node/versionNumber[@type="minor"])
            
        return
         if (functx:is-value-in-sequence($text,$keywords))
            then ()
            else
                if (functx:is-value-in-sequence($id,$relation-targets))
                then <a style="font-size:15px" href="{app:link($link)}">{$text}</a>
                else <a style="font-size:12px" href="{app:link($link)}">{$text}</a>
};

declare function vsm:print-spec-description($p, $spec-id){
    (<span id="desctext">{$p}</span>,
    if (session:get-attribute("user") = 'webadmin')
    then <button class="edit" type="button" onclick="openEditor('editdesc');">Edit description</button>    
    else (),
    if (session:get-attribute("user") = 'webadmin')
    then 
    <table id="editdesc" style="display:none">
        <tr>
            <td><textarea id="editedtext" class="inputText" style="width:550px; height:150px; resize: none; font-size:11px;">
                {for $t in $p/text() return (fn:replace($t,"\n",""),"&#xa;&#xa;")} </textarea> </td>
            <td valign="top"><button type="button" class="button" onclick="update('{$spec-id}','desc','editedtext','editdesc')">Submit</button></td>
        </tr>
    </table>
    else()
   )      

                
    (:let $pids := for $i in $p/@id return concat('"',data($i),'"')
    let $pids := concat("[",fn:string-join($pids,","),"]")
    
    for $i in (1 to count($p))           
       let $pid := $p[$i]/@id                        
       return (
            <p id="desc{$pid}"> <span id="desc{$pid}text">{$p[$i]/*}</span> 
               {if (session:get-attribute("user") = 'webadmin')
                then ( <button class="edit" type="button" onclick="openEditor('editdesc{$pid}');">Edit</button>,
                      <button class="edit" type="button" onclick="openEditor('adddesc{$pid}');">Add</button>)
                else ()}
            </p>,
            <table id="editdesc{$pid}" style="display:none">
               <tr>
               <td><textarea id="editedtext{$pid}" class="inputText" 
                   style="width:550px; height:150px; resize: none; font-size:11px;">
                   {$p[$i]/text()}</textarea></td>
               <td valign="top"><button type="button" class="button" style="margin-top:1px;" 
                   onclick="update('{$spec-id}','desc{$pid}','editedtext{$pid}','editdesc{$pid}')">Submit</button></td>
               </tr>
           </table>,
           <table id="adddesc{$pid}" style="display:none">
               <tr>
               <td><textarea id="newtext{$pid}" class="inputText" placeholder="Describe a new paragraph here."
                   style="width:550px; height:150px; resize: none; font-size:11px;"/></td>
               <td valign="top"><button type="submit" class="button" style="margin-top:1px;" 
                   onclick="addDesc('{$spec-id}','{$pid}',{$pids})">Submit</button></td>
               </tr>
           </table>:)
    
};

declare function vsm:print-spec-assets($spec-id,$ref){    
    let $numrefs := count($ref)
    return
    
    if (session:get-attribute("user") or (session:get-attribute("user") = 'webadmin' or count($ref)>0))
        then
            <div>
                <span class="heading">Reference(s): </span>
                <span id="reftext">
                    {for $k in (1 to $numrefs)
                        let $comma := if ($k > 1) then ", " else ()
                        let $link := app:link(concat("data/doc/",$ref[$k]/@href))
                        
                     return (
                        <span id="reftext{$k}">{$comma} <a href="{$link}">{$ref[$k]/text()}</a></span>,
                        if (session:get-attribute("user") = 'webadmin')
                        then <button id="reftext{$k}button" class="edit" style="margin:0 3px 0 3px;" type="button"  
                             onclick="removeElement('{$spec-id}','reftext{$k}','{$ref[$k]/text()}');">Remove</button>                            
                        else ()
                     )
                    }
                </span>
                { if (session:get-attribute("user") = 'webadmin')
                  then <button class="edit" style="margin-left:3px" type="button" onclick="openEditor('editref');">Upload</button>
                  else ()
                }
            </div>             
         else(),
         if (session:get-attribute("user") = 'webadmin')
         then 
         <div id="editref" style="display:none">
             <form enctype="multipart/form-data" method="post" 
                 action="{session:encode-url(xs:anyURI(concat("../edit/edit-process.xq?id=", $spec-id,"&amp;task=upload" )))}">
                 <input id="ref1" name="ref1" type="file" class="inputFile" style="display:inline"/>
                 <button type="button" id="addref" class="button" style="margin-bottom:3px;" 
                      onclick="addElement('ref','input','file',1)">Add</button>                      
                <button type="submit" name="submitButton" class="button" style="margin-bottom:3px;">Upload</button>
             </form>
         </div>
        else()
};

declare function vsm:print-spec-bibliography($bib){
    if ($bib)
    then <div><span class="heading">Recommended Reading: </span><br/>
            <ul> {bib:get-references($bib)}</ul>
         </div>
    else ()
};

declare function vsm:print-topic-specs($spec-id,$spec-topics){
    let $specs := functx:distinct-nodes(
        for $topic-id in $spec-topics
        return $spec:specs[contains(@topic,$topic-id) and @id!=$spec-id]
    )
    return 
    if ($specs) then 
        <div><span class="heading">Other standards in the same topic(s):</span>
            <ul>{for $spec in $specs
                 order by $spec/titleStmt/title/text()
                 return <li><a href="view-spec.xq?id={$spec/@id}">
                    {$spec/titleStmt/title/text()}</a></li>
                }
            </ul>
        </div>
    else ()
};

declare function vsm:print-spec-part($spec){
    for $part in $spec/part
    return vvm:print-version($spec,$part,"part")    
};

declare function vsm:print-add-button($spec-id){
    let $part-uri := concat("views/add-spec-part.xq?id=",$spec-id)
    let $version-uri := concat("views/add-spec-version.xq?id=",$spec-id)
    return
(:change to URL    :)
    if (session:get-attribute("user") = 'webadmin')
    then <div style="margin-bottom:20px">
            <button type="button" class="button" style="width:110px;" onclick="location.href='{app:link($part-uri)}'">Add Part</button>
            <span style="display:inline-block; width:2px"/>
            <button type="button" class="button" style="width:110px;" onclick="location.href='{app:link($version-uri)}'">Add Version</button>           
         </div> 
    else ()
};

declare function vsm:print-spec-version($spec){
    vvm:print-version($spec,$spec,"version")
};

declare function vsm:print-graph($spec-relations){
    let $spec-relations := fn:distinct-values($spec-relations)
    let $relations := xsd:get-relations()    
    let $idx := fn:index-of($relations,"isVersionOf")
    return    
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
                 {if (not(functx:is-value-in-sequence("isVersionOf",$spec-relations)))
                 then
                    <tr>
                         <td><hr style="border:0; color:{$graph:colors[$idx]}; background-color:{$graph:colors[$idx]}; height:2px; width:20px" /></td>
                         <td>isVersionOf</td>
                     </tr>
                 else ()
                 }
             </table>
           </div>    
        </div>
  
};
