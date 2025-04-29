xquery version "3.0";

module namespace vvm="http://clarin.ids-mannheim.de/standards/view-version";

import module namespace app="http://clarin.ids-mannheim.de/standards/app" at "app.xql";
import module namespace bib="http://clarin.ids-mannheim.de/standards/bibliography" at "bib.xql";
import module namespace vsm="http://clarin.ids-mannheim.de/standards/view-spec" at "view-spec.xql";
import module namespace sbm="http://clarin.ids-mannheim.de/standards/sb-module" at "../modules/sb.xql";

import module namespace xsd = "http://clarin.ids-mannheim.de/standards/schema" at "../model/schema.xqm";
import module namespace spec="http://clarin.ids-mannheim.de/standards/specification" at "../model/spec.xqm";
import module namespace centre="http://clarin.ids-mannheim.de/standards/centre" at "../model/centre.xqm";

(: Define methods for viewing of standard versions
   @author margaretha
:)

declare function vvm:getVersionClass($node){    
        if ($node = "version")
        then "version"
        else "part-version"        
};

(: Print the versions of a standard :)
declare function vvm:print-version($spec,$parent,$node){    
    let $spec-id := $spec/@id
    let $length := count($parent/version)
    for $index in (1 to $length)
        let $version := $parent/version[$index]
        let $version-id := $version/data(@id)
        let $isLast := if ($index = $length) then fn:true() else fn:false()
        return
          <div class="{vvm:getVersionClass($node)}" id="{$version-id}">
              { vvm:print-clarin-approval($version)}          
              { vvm:print-version-name("Version Title: ",$spec-id,$version,$version-id) }
              { vvm:print-version-abbr($spec-id,$version,$version-id) }              
              { vvm:print-version-number($spec-id,$version-id,$version) }
              { vvm:print-version-status($spec-id,$version,$version-id) }
              { vvm:print-version-date($spec-id,$version,$version-id) }              
              { vvm:print-version-respStmt($spec-id,$version,$version-id) }
              { vvm:print-version-description($spec-id,$version,$version-id) }     
              <!--{ vvm:add-version-respStmt($spec-id,$version-id) }-->              
              { vvm:print-version-features($spec-id,$version,$version-id) }                     
              { vvm:print-version-url($spec-id,$version,$version-id) }
              { vvm:print-version-recommendation($version) }
              { vvm:print-version-relation($spec-id,$version,$version-id,fn:false()) }
              { vvm:print-version-centre($version)}
              { vvm:print-version-references($spec-id,$version,$version-id) }
          </div>
};

declare function vvm:print-version-centre($version){
    let $version-centres := 
        for $centre-id in tokenize(data($version/@usedInCLARINCentre),' ')
            let $c := centre:get-centre($centre-id)
            order by $c/name/text()
            return $c
   return
        if (count($version-centres) > 0)
        then (
            <div>
                <span class="heading3" >Used in CLARIN centre(s): </span>
                <ul>
                {
                for $c in $version-centres                
                    let $cl := <a href="{$c/a/@href}">{$c/name/text()}</a>
                return                
                    <li>{$cl}</li>
               }
               </ul>
           </div>
        )
        else ()
};

declare function vvm:print-clarin-approval($version){
    if ($version/@CLARINapproved)
    then <div style="float:right">[CLARIN Approved]</div>
    else ()
};

(: Print the version title and its edit form :)
declare function vvm:print-version-name($title-label,$spec-id,$version,$version-id){    
    let $version-title := $version/titleStmt/title/text()
    return (
        if ($version-title)
        then <div class="heading3" >{$title-label}
            <span id="vname{$version-id}text" style="text-decoration:underline;">{$version-title}</span>            
            {(:vsm:print-edit-button(concat("editvname",$version-id)):)}
            </div>
        else () 
        (:,
        if (session:get-attribute("user") = 'webadmin')
        then 
             <div id="editvname{$version-id}" style="display:none">                   
                 <input id="vname{$version-id}" name="vname" value="{$version-title}" type="text" class="inputText" 
                    placeholder="Insert a version name" style="width:450px;"/>                 
                 <button type="button" class="button" onclick="update('{$spec-id}','vname{$version-id}','vname{$version-id}',
                    'editvname{$version-id}');">Submit</button>                        
             </div>
        else()
        :)
   )
};

(: Print the version abbreviation and its edit form :)
declare function vvm:print-version-abbr($spec-id,$version,$version-id){
    let $version-abbr := $version/titleStmt/abbr
    let $display :=  if (data($version-abbr/@internal) = "yes") then "inline" else "none"
    return (
        if ($version-abbr)
        then <div>
                <span class="heading3">Abbreviation: </span>            
                <span class="heading3" id="vabbr{$version-id}text">{$version-abbr}</span>
                <span id="vabbr{$version-id}internalText" style="font-size:10px;margin-left:5px;display:{$display}">
                [not official, only for reference in this website]</span>
                {(:vsm:print-edit-button(concat("editvabbr",$version-id)):)}
            </div>
        else () 
       (:,
        if (session:get-attribute("user") = 'webadmin')
        then 
             <div id="editvabbr{$version-id}" style="display:none">
                 <input id="vabbr{$version-id}" name="vabbr" value="{$version-abbr}" type="text" 
                    placeholder="Insert an abbreviation" class="inputText" style="width:345px; margin-left:2px;"/>
                    <select id="vabbr{$version-id}internal" name="vabbr{$version-id}internal" 
                        class="inputSelect" style="margin-left:3px; width:100px;">
                        {if (data($version-abbr/@internal) = 'yes')
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
                 <button type="button" class="button" onclick="update('{$spec-id}','vabbr{$version-id}','vabbr{$version-id}',
                    'editvabbr{$version-id}');">Submit</button>                        
             </div>
       else()
       :)
     )
};

(: Print the version number and its edit form:)
declare function vvm:print-version-number($spec-id, $version-id, $version){
    let $version-number-major := $version/versionNumber[@type='major']/text() 
    let $version-number-minor := $version/versionNumber[@type='minor']/text()
    
    return (      
        if ( $version-number-major or $version-number-minor)
        then <div><span class="heading3">Version Number: </span>
                  <span id="vnomajor{$version-id}text" style="margin-right:5px;">{$version-number-major}</span>
                  <span id="vnominor{$version-id}text">{$version-number-minor}</span>
             </div>
        else ()
    )
};

(: Print the version status and its edit form :)
declare function vvm:print-version-status($spec-id,$version,$version-id){
    let $version-status := data($version/@status)
    return  (
        if (($version-status)) 
        then <div><span class="heading3">Status: </span> 
                 <span id="vstatustext">{$version-status} </span>
            </div> 
        else ()
        (:,
        if (session:get-attribute("user") = 'webadmin')
        then
            <div id="editvstatus{$version-id}" style="display:none">
                <select id="vstatus{$version-id}" class="inputSelect" style="width:455px; margin-right:3px;">
                    <option value=""/>
                    {f:list-options(xsd:get-statuses(),$version-status)}
                </select>
                <button type="button" class="button" 
                    onclick="update('{$spec-id}','vstatus','vstatus{$version-id}','editvstatus{$version-id}');">Submit</button>                         
             </div>
         else()
         :)
     )
};

(: Print the version date and its edit form :)
declare function vvm:print-version-date($spec-id,$version,$version-id){
    let $version-date := $version/date
    return (    
        if ($version-date) 
        then <div><span class="heading3">Release Date: </span>
               <span id="vdatetext">{$version-date}</span>               
          </div>
        else()        
    )
};

(: Print the version description and its edit form :)
declare function vvm:print-version-description($spec-id,$version,$version-id){
    let $uri := concat("edit/edit-process.xq?id=", $spec-id,"&amp;vid=",$version-id,"&amp;path=desc")
    let $error := request:parameter(concat("errorDesc",$version-id),"")
    let $desc := $version/info[@type="description"]
    return    
        if ($desc) then 
            <div>
                <span class="heading3">Description: </span><br/>
                {vsm:print-desc($version-id,$desc,$uri,$error)}
            </div>
        else ()
};


(: Print the version responsible statement(s) :)
declare function vvm:print-version-respStmt($spec-id,$version,$version-id){
    let $new-id := random:uuid()
    return
    if ($version/titleStmt/respStmt)
    then
        for $respStmt in $version/titleStmt/respStmt
            let $resp-id := data($respStmt/@id)
            let $resp-names := fn:string-join(for $name in $respStmt/name/text() return $name, ", ")
            let $resp-type := data($respStmt/name/@type)[1]
            let $resp-sbid := data($respStmt/name/@id)[1]
            let $tokens := fn:tokenize($respStmt/name/text(),'/')
            return (
            <div><span class="heading3" id="resp{$resp-id}text">{$respStmt/resp}: </span>
                
                <ol id="resp{$resp-id}nametext">{                           
                      for $name in $respStmt/name
                      let $respStmtItem := $name/text()
                      return 
                        <li style="list-style-image:url('../resources/images/person_icon.png');">
                            { if ($name/@id and not(data($name/@id) ="")) 
                              then <a href="{app:link(concat("views/view-sb.xq?id=", data($name/@id)))}">
                                {$respStmtItem}</a> 
                              else $respStmtItem
                        }</li>
                    }
                </ol>                        	
            </div>
          )
    else(
         <div><span class="heading3" id="resp{$new-id}text">RespStmt:</span> 
         <ol id="resp{$new-id}nametext"></ol>
         </div>
     )
};    
      
      (: <table id="editvresp{$resp-id}" style="display:none; border-spacing:0; border-collapse:collapse;">
                <tr><td>
                        <textarea id="resp{$resp-id}" class="inputText" style="width:445px; height:100px; 
                            resize: none; font-size:11px" placeholder="Describe one Responsible Statement with &lt;respStmt&gt; as the root element.">
                            {$respStmt}</textarea>
                    </td>
                    <td valign="top">
                        <button type="button" class="button" style="margin-top:1px;" 
                        onclick="update('{$spec-id}','resp{$resp-id}','{$version-id}','editvresp{$resp-id}');">
                        Submit</button>
                    </td>
                </tr>
            </table>   :)

(:
declare function vvm:add-version-respStmt($spec-id,$version-id){
    if (session:get-attribute("user") = 'webadmin') 
     then (<div id="addvresp{$version-id}button">
            <button class="edit" type="button" onclick="openEditor('addvresp{$version-id}')">
                Add Responsible Statement</button></div>,
                                    
            <table id="addvresp{$version-id}" style="display:none; border-spacing:0; border-collapse:collapse;">
                <tr><td>
                        <textarea id="newresp{$version-id}" class="inputText" style="width:445px; height:100px; 
                            resize: none; font-size:11px" placeholder="Describe one Responsible Statement with &lt;respStmt&gt; as the root element."/>
                    </td>
                    <td valign="top">
                        <button type="button" class="button" style="margin-top:1px;" 
                        onclick="update('{$spec-id}','newresp{$version-id}','{$version-id}','addvresp{$version-id}');">
                        Submit</button>
                    </td>
                </tr>
            </table>            
            )
    else ()
};:)

(: Print version features :)
declare function vvm:print-version-features($spec-id,$version,$version-id){
    let $version-features := $version/features/*
    return (
        if ($version-features)
        then (<div>
                <span class="heading3">Features: </span>
                <!--{vsm:print-edit-button(concat("editfeatures",$version-id))}-->
                
                          
                <span id="features{$version-id}text"> {for $fs in $version/features/fs
                return
                    <ul class="fs" >
                       {for $f in $fs/f
                        let $f-name := $f/@name
                        return 
                            <li>
                                {concat($f-name,': ')}
                                {if ($f/*/@value) then $f/*/data(@value) else $f//text()}
                            </li>
                        }
                    </ul>
                }</span>
             </div>)
        else()
        
    )
};

(: Print version URL and its edit form :)
declare function vvm:print-version-url($spec-id,$version,$version-id){
    let $version-urls := $version/address[@type='URL']
    let $numurls := count($version-urls)
    
    return (
        if ($version/address)
        then <div><span class="heading3">URL(s): </span>
                <span id="vurltext{$version-id}">
                {for $i in (1 to $numurls)                     
                 return (<a href="{$version-urls[$i]/text()}">{$version-urls[$i]/text()}</a>,
                     if ($i < $numurls) then ', ' else ())
                }
                </span>
                                                     
                 <!-- {for $add in $version/address[not(@type='URL')]
                  return <span>{$add/text()}</span>
                  }-->
              </div>
          else ()          
       )
};

(: Print version recommended reading:)
declare function vvm:print-version-recommendation($version){
    if ($version/info[@type="recReading"])
    then <div><span class="heading3">Recommended Reading: </span><br/>
        <ul> {bib:get-references($version/info[@type="recReading"]/biblStruct)}</ul>
      </div>
    else ()
};

(: Print version relations and the edit forms :)
declare function vvm:print-version-relation($spec-id,$version,$version-id,$isFormat as xs:boolean){
    
    let $version-relations := $version/relation
    let $numrels := count($version-relations)
    let $relations := xsd:get-relations()
    
    return (
        if ($version-relations)
          then(<div><span class="heading3"> Related Standard(s):</span>
                    <ul id="vrel{$version-id}ul">
          			{for $r in (1 to $numrels)
                        let $target := data($version-relations[$r]/@target)
                        let $type := data($version-relations[$r]/@type)
                        let $target-node := spec:get-spec($target)
                        let  $target-link := 
                            if ($target-node/@standardSettingBody)
                            then app:link(concat('views/view-spec.xq?id=',$target-node/data(@id)))
                            else app:link(concat('views/view-spec.xq?id=',$target-node/../data(@id),'#',data($target-node/@id)))                        
                         let $target-name := 
                            if ($target-node/titleStmt/abbr/text())
                            then $target-node/titleStmt/abbr/text()
                            else concat($target-node/ancestor::spec/titleStmt/abbr/text(),
                                    "-",substring($target-node/date,1,4))
                        order by $target
                        return (
                      		   <li id="vrel{$version-id}--{$r}li">
                      		       <span id="vrel{$version-id}--{$r}pid" style="display:none">{$target}</span>
                      		       <a id="vrel{$version-id}--{$r}link" href="{$target-link}">
                      		            {$target-name}
                      			   </a> 
                        		                                         
                      		 	   <span id="vrel{$version-id}--{$r}text"> { $version-relations[$r]/info/* } </span>                      			 	   
                      		 	</li>
                             
                             (:,             
                      		 	if (session:get-attribute("user") = 'webadmin'and not($isFormat)) 
                      		 	then
                      		 	     <span id='editvrel{$version-id}--{$r}' style="display:none; margin-bottom:15px;">
                      		 	        <select id="vrel{$version-id}--{$r}" class="inputSelect" style="width:173px; margin-right:3px;">
                                            <option value=""/>
                                            {f:list-options($relations,$type)}                
                                        </select>
                                        <select id="vrel{$version-id}--{$r}target" class="inputSelect" style="width:280px">
                                            <option value=""/>
                                            {f:list-targets($target)}
                                        </select>                    
                                        <button type="button" class="button" style="margin-left:3px;"
                                            onclick="update('{$spec-id}','vrel{$version-id}--{$r}','','editvrel{$version-id}--{$r}')"
                                            >Submit</button>
                                        <textarea id="vrel{$version-id}--{$r}desc" class="inputText" placeholder="Describe the relation in one paragraph." 
                                            style="width:450px; margin-top:2px; height:50px; resize: none; font-size:11px;">{$version-relations[$r]/info/p/text()}</textarea>
                                    </span>
                                else()           
                                :)           			 	   
                       	   )
                    }
                    </ul>
               </div>)
          else()
          (:,
          if (session:get-attribute("user") = 'webadmin' and not($isFormat)) 
           then (<div>
                    <button class="edit" type="button" 
                    onclick="openEditor('addvrel{$version-id}');setrel({f:get-options(xsd:get-relations())},{f:get-target-options()})">
                    Add Relation</button>
                 </div>,
                 <div id='addvrel{$version-id}' style="display:none; margin-bottom:15px;">
                       <select id="newvrel{$version-id}" class="inputSelect" style="width:173px; margin-right:3px;">
                        <option value=""/>
                        {f:list-options($relations,'')}                
                    </select>
                    <select id="newvrel{$version-id}target" class="inputSelect" style="width:280px">
                        <option value=""/>
                        {f:list-targets('')}
                    </select>                    
                    <button type="button" class="button" style="margin-left:3px;"
                        onclick="update('{$spec-id}','newvrel{$version-id}',{$numrels},'addvrel{$version-id}')"
                        >Submit</button>
                    <textarea id="newvrel{$version-id}desc" class="inputText" placeholder="Describe the relation in one paragraph." 
                        style="width:450px; margin-top:2px; height:50px; resize: none; font-size:11px;"/>
                </div>
                )
           else()
           :)
       )
               
};

(: Print the version documents and its uplaod form :)
declare function vvm:print-version-references($spec-id,$version,$version-id){                
    let $refv := $version/asset/a
    let $numrefv := count($refv)
    let $d := request:parameter(concat("display",$version-id),"none")
    return (
        if (count($refv)>0)
        then
            <div>
                <span class="heading3">Reference(s): </span>
                <span id="ref{$version-id}text">                        
                    {for $k in (1 to $numrefv)
                     let $comma := if ($k > 1) then ", " else ()
                     let $link := app:link(concat("data/doc/",$refv[$k]/@href))
                        return (
                            <span id="ref{$version-id}text{$k}">{$comma} <a href="{$link}">{$refv[$k]/text()}</a></span>
                        )
                    }
                </span>
                
            </div>             
        else()
        
    )

};



