xquery version "3.0";

module namespace vvm="http://clarin.ids-mannheim.de/standards/view-version";

import module namespace f = "http://clarin.ids-mannheim.de/standards/module/form" at "../edit/edit-form.xq";

import module namespace app="http://clarin.ids-mannheim.de/standards/app" at "app.xql";
import module namespace bib="http://clarin.ids-mannheim.de/standards/bibliography" at "bib.xql";
import module namespace vsm="http://clarin.ids-mannheim.de/standards/view-spec" at "view-spec.xql";

import module namespace xsd = "http://clarin.ids-mannheim.de/standards/schema" at "../model/schema.xqm";
import module namespace spec="http://clarin.ids-mannheim.de/standards/specification" at "../model/spec.xqm";

declare function vvm:print-version-title($node,$spec-id,$version,$version-id){
    let $title-label := if ($node ="version") then "Version Title: " else "Part Title: "
    let $version-abbr := $version/titleStmt/abbr/text()
    let $version-title := $version/titleStmt/title/text()
    return (
        if ($version-title or (session:get-attribute("user") = 'webadmin'))
        then <div class="heading3" >{$title-label}
            <span id="vnametext" style="text-decoration:underline;">{$version-title}</span>
            <span id="vabbrtext">
                {if ($version-abbr and $version-abbr !='')
                 then concat(" (",$version-abbr,")")
                 else ()
                }
            </span>
            {vsm:print-edit-button(concat("editvname",$version-id))}
            </div>
        else () 
       , 
        if (session:get-attribute("user") = 'webadmin')
        then 
             <div id="editvname{$version-id}" style="display:none">                   
                 <input id="vname{$version-id}" name="vname" value="{$version-title}" type="text" class="inputText" 
                    placeholder="Insert a version name" style="width:400px;"/>
                 <input id="vabbr{$version-id}" name="vabbr" value="{$version-abbr}" type="text" 
                    placeholder="Insert an abbreviation" class="inputText" style="width:142px; margin-left:2px;"/>
                 <button type="button" class="button" onclick="update('{$spec-id}','vname','vname{$version-id}',
                    'editvname{$version-id}'); update('{$spec-id}','vabbr','vabbr{$version-id}',
                    'editvname{$version-id}');">Submit</button>                        
             </div>
        else()  
    )
};

declare function vvm:print-version-number($spec-id, $version-id, $version){
    let $version-number-major := $version/versionNumber[@type='major']/text() 
    let $version-number-minor := $version/versionNumber[@type='minor']/text()
    
    return (      
        if ( $version-number-major or $version-number-minor or (session:get-attribute("user") = 'webadmin'))
        then <div><span class="heading3">Version Number: </span>
                  <span id="vnomajortext" style="margin-right:5px;">{$version-number-major}</span>
                  <span id="vnominortext">{$version-number-minor}</span>
                  {vsm:print-edit-button(concat("editvno",$version-id))}
             </div>
        else ()
      ,
       if (session:get-attribute("user") = 'webadmin')
        then
            <div id="editvno{$version-id}" style="display:none">     
                <input id="vnomajor{$version-id}" value="{$version-number-major}" type="text" class="inputText" style="width:220px;" placeholder="Major"/>
                <input id="vnominor{$version-id}" value="{$version-number-minor}" type="text" class="inputText" style="margin-left:3px; width:220px;" placeholder="Minor"/>
                <button type="button" class="button" 
                    onclick="update('{$spec-id}','vnomajor','vnomajor{$version-id}','editvno{$version-id}');
                    update('{$spec-id}','vnominor','vnominor{$version-id}','editvno{$version-id}');">Submit</button>                         
             </div>
        else()
    )
};

declare function vvm:print-version-status($spec-id,$version,$version-id){
    let $version-status := data($version/@status)
    return  (
        if (($version-status) or (session:get-attribute("user") = 'webadmin')) 
        then <div><span class="heading3">Status: </span> 
                 <span id="vstatustext">{$version-status} </span>
                 {vsm:print-edit-button(concat("editvstatus",$version-id))}                 
            </div> 
        else ()
        ,
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
     )
};

declare function vvm:print-version-date($spec-id,$version,$version-id){
    let $version-date := $version/date
    return (    
        if ($version-date or (session:get-attribute("user") = 'webadmin')) 
        then <div><span class="heading3">Release Date: </span>
               <span id="vdatetext">{$version-date}</span>
               {vsm:print-edit-button(concat("editvdate",$version-id))}               
          </div>
        else()
        , 
        if (session:get-attribute("user") = 'webadmin')
        then
         <div id="editvdate{$version-id}" style="display:none">
             <input id="vdate{$version-id}" value="{$version-date}" placeholder="YYYY-MM-DD" type="text" class="inputText" style="width:450px;"/>
             <button type="button" class="button" 
                 onclick="update('{$spec-id}','vdate','vdate{$version-id}','editvdate{$version-id}');">Submit</button>
             <span id="errorvdate" style="color:red; font-size:13px;display:none">* Please insert a date in YYYY-MM-DD format.</span>
          </div>
        else()
    )
};

declare function vvm:print-version-description($version){
    if ($version/info[@type="description"])
    then <div><span class="heading3">Description: </span><br/>
      {$version/info[@type="description"]}
      </div>
    else ()
};

declare function vvm:print-version-respStmt($spec-id,$version,$version-id){    
    for $respStmt in $version/titleStmt/respStmt
        let $resp-id := data($respStmt/@id)
        let $resp-names := fn:string-join(for $name in $respStmt/name/text() return $name, ", ")
        let $resp-type := data($respStmt/name/@type)[1]
        let $resp-sbid := data($respStmt/name/@id)[1]
        let $tokens := fn:tokenize($respStmt/name/text(),'/')
        return (
        <div><span class="heading3" id="resp{$resp-id}text">{$respStmt/resp}: </span>
            {vsm:print-edit-button(concat("editvresp",$resp-id))}   
            
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
        </div>,
        if (session:get-attribute("user") = 'webadmin')
        then
            
            <table id="editvresp{$resp-id}" style="display:none; border-spacing:0; border-collapse:collapse;">
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
            </table>   
          else()   
      )
};

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
};

declare function vvm:print-version-features($spec-id,$version,$version-id){
    let $version-features := $version/features/*
    return (
        if ($version-features or session:get-attribute("user") = 'webadmin')
        then (<div>
                <span class="heading3">Features: </span>
                {vsm:print-edit-button(concat("editfeatures",$version-id))}        
                          
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
        ,
        if (session:get-attribute("user") = 'webadmin')
        then <table id='editfeatures{$version-id}' style="display:none; border-spacing:0; border-collapse:collapse;">
                <tr><td style="width:250px;">
                    <textarea id="features{$version-id}" class="inputText" style="width:445px; height:150px; resize: none; font-size:11px;"
                     placeholder='Describe features in one root element, e.g. &lt;fs&gt; &lt;f name= "metalanguage"&gt;&lt;symbol value="SGML"/&gt;&lt;/f&gt; &lt;f name= "constraintLanguage"&gt;&lt;symbol value="DTD"/&gt;&lt;/f&gt; &lt;/fs&gt;'>
                        {$version-features}</textarea></td>
                    <td valign="top">
                        <button type="button" class="button" style="margin-top:1px;" 
                         onclick="update('{$spec-id}','features{$version-id}','features{$version-id}','editfeatures{$version-id}');">
                         Submit</button>
                     </td>
                 </tr>
             </table>
        else ()
    )
};

declare function vvm:print-version-url($spec-id,$version,$version-id){
    let $version-urls := $version/address[@type='URL']
    let $numurls := count($version-urls)
    
    return (
        if ($version/address or session:get-attribute("user") = 'webadmin')
        then <div><span class="heading3">URL(s): </span>
                <span id="vurltext{$version-id}">
                {for $i in (1 to $numurls)                     
                 return (<a href="{$version-urls[$i]/text()}">{$version-urls[$i]/text()}</a>,
                     if ($i < $numurls) then ', ' else ())
                }
                </span>
                {vsm:print-edit-button(concat("editvurl",$version-id))}      
                                                     
                 <!-- {for $add in $version/address[not(@type='URL')]
                  return <span>{$add/text()}</span>
                  }-->
              </div>
          else ()
          ,
          if (session:get-attribute("user") = 'webadmin') then (
                <div id= 'editvurl{$version-id}' style="display:none;margin-bottom:0px">
                {for $i in (1 to fn:max(($numurls,1)))                        
                 return (
                    <input id="vurl{$version-id}{$i}" value="{$version-urls[$i]/text()}" type="text" class="inputText" style="width:450px;"/>,                        
                    if ($i=1) then
                        (<button type="button" class="button" style="margin-bottom:3px;" 
                         onclick="addElement('vurl{$version-id}','input','text',{fn:max(($numurls,1))});">Add</button>,
                         <button type="button" class="button" style="margin-bottom:3px;"
                         onclick="update('{$spec-id}','vurl{$version-id}',{fn:max(($numurls,1))},'editvurl{$version-id}');">
                         Submit</button>)
                    else())
                 }
                </div>,
                <div id="errorvurl{$version-id}" style="color:red; font-size:13px;display:none; margin-top:0px">
                    * Please insert a valid URL.</div>
               )
           else()
       )
};

declare function vvm:print-version-recommendation($version){
    if ($version/info[@type="recReading"])
    then <div><span class="heading3">Recommended Reading: </span><br/>
        <ul> {bib:get-references($version/info[@type="recReading"]/biblStruct)}</ul>
      </div>
    else ()
};

declare function vvm:print-version-relation($spec-id,$version,$version-id){
    
    let $version-relations := $version/relation
    let $numrels := count($version-relations)
    let $relations := xsd:get-relation-enumeration()
    
    return (
        if ($version-relations or session:get-attribute("user") = 'webadmin')
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
                        let $n := $target-node/ancestor-or-self::node()/titleStmt/title/text()
                        let $nn := count($n)
                        let $vn := $target-node/versionNumber
                        return (
                      		   <li id="vrel{$version-id}--{$r}li">
                      		       <span id="vrel{$version-id}--{$r}pid" style="display:none">{$target}</span>
                      		       <a id="vrel{$version-id}--{$r}link" href="{$target-link}">
                      		       {if ($vn) then (concat($n[$nn],' ',$vn[count($vn)]/text())) else $n[$nn]}
                      			   </a> 
                        		   {if (session:get-attribute("user") = 'webadmin') 
                                    then (<button class="edit" type="button" onclick="openEditor('editvrel{$version-id}--{$r}');">Edit</button>,
                                          <button class="edit" style="margin-left:3px;" type="button"  
                                            onclick="removeElement('{$spec-id}','vrel{$version-id}--{$r}','');">Remove</button>)
                                    else()}                                        
                      		 	   <span id="vrel{$version-id}--{$r}text"> { $version-relations[$r]/info/* } </span>                      			 	   
                      		 	</li>,             
                      		 	if (session:get-attribute("user") = 'webadmin') then
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
                       	   )
                    }
                    </ul>
               </div>)
          else()
          ,
          if (session:get-attribute("user") = 'webadmin') 
           then (<div>
                    <button class="edit" type="button" 
                    onclick="openEditor('addvrel{$version-id}');setrel({f:get-options(xsd:get-relation-enumeration())},{f:get-target-options()})">
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
       )
               
};

declare function vvm:print-version-references($spec-id,$version,$version-id){                
    let $refv := $version/asset/a
    let $numrefv := count($refv)
    
    return (
        if ((session:get-attribute("user") and count($refv)>0) or (session:get-attribute("user") = 'webadmin'))
        then
            <div>
                <span class="heading3">Reference(s): </span>
                <span id="refv{$version-id}text">                        
                    {for $k in (1 to $numrefv)
                     let $comma := if ($k > 1) then ", " else ()
                        return (
                            <span id="refv{$version-id}text{$k}">{$comma} {$refv[$k]}</span>,
                            if (session:get-attribute("user") = 'webadmin')
                            then <button id="refv{$version-id}text{$k}button" class="edit" style="margin:0 3px 0 3px;" type="button"  
                                 onclick="removeElement('{$spec-id}','refv{$version-id}text{$k}','{$refv[$k]/text()}');">Remove</button>                            
                            else ()
                        )
                    }
                </span>
                { if (session:get-attribute("user") = 'webadmin')
                  then <button class="edit" style="margin-left:3px" type="button" onclick="openEditor('editrefv{$version-id}');">Upload</button>
                  else ()
                }
            </div>             
        else()
        ,
        if (session:get-attribute("user") = 'webadmin')
        then 
            <div id="editrefv{$version-id}" style="display:none">
                <form enctype="multipart/form-data" method="post" 
                    action="{session:encode-url(xs:anyURI(concat("../edit/edit-process.xq?id=", $spec-id,"&amp;task=uploadversion&amp;pid=", $version-id)))}">
                    <input id="refv{$version-id}1" name="refv{$version-id}1" type="file" class="inputFile" style="display:inline"/>
                    <button type="button" id="addref" class="button" style="margin-bottom:3px;" 
                         onclick="addElement('refv{$version-id}','input','file',1)">Add</button>                      
                   <button type="submit" name="submitButton" class="button" style="margin-bottom:3px;">Upload</button>
                </form>
            </div>
        else()
    )

};

declare function vvm:print-version($spec,$parent,$node){
    
    (:let $spec-ids := data($data/spec/@id):)
    let $spec-id := $spec/@id
    
    for $version in $parent/version        
        let $version-id := $version/data(@id)
        (:let $part-name := $parent/titleStmt/title/text():)        
        return
          <div class="version" id="{$version-id}">
              { vvm:print-version-title($node,$spec-id,$version,$version-id) }              
              { vvm:print-version-number($spec-id,$version-id,$version) }
              { vvm:print-version-status($spec-id,$version,$version-id) }              
              { vvm:print-version-date($spec-id,$version,$version-id) }              
              { vvm:print-version-description($version) }             
              { vvm:print-version-respStmt($spec-id,$version,$version-id) }
              { vvm:add-version-respStmt($spec-id,$version-id) }              
              { vvm:print-version-features($spec-id,$version,$version-id) }                     
              { vvm:print-version-url($spec-id,$version,$version-id) }              
              { vvm:print-version-recommendation($version) }
              { vvm:print-version-relation($spec-id,$version,$version-id) }          
              { vvm:print-version-references($spec-id,$version,$version-id) }
          </div>
};

