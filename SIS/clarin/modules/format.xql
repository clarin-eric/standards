xquery version "3.0";

module namespace fm ="http://clarin.ids-mannheim.de/standards/format-module";
import module namespace app="http://clarin.ids-mannheim.de/standards/app" at "app.xql";
import module namespace spec="http://clarin.ids-mannheim.de/standards/specification" at "../model/spec.xqm";
import module namespace format="http://clarin.ids-mannheim.de/standards/format" at "../model/format.xqm";

(:  Define format-related functions
    @author margaretha
:)

(: Retrieve a format node by its id :)
declare function fm:get-format($id as xs:string){
    format:get-format($id)
};


(: Generate the list of formats :)
declare function fm:list-formats(){
    for $format in $format:formats
        let $format-id := data($format/@id)
        let $format-name := $format/titleStmt/title/text()
        let $format-snippet := $format/info[@type="description"]/p[1]/text()  
        let $link := <a href="{app:link(concat("views/view-format.xq?id=", $format-id))}"> More...</a>
        
    return
        <div>
            <li>
               <span class="list-text pointer" 
                onclick="openEditor('{$format-id}')">{$format-name}</span>
                <img class="copy-icon pointer" src="{app:resource("copy.png","img")}" width="14"  
                onclick="copyTextToClipboard('{$format-id}','{$format-name}')"/>
                <span class="hint" id="hint-{$format-id}">copied</span>
            </li>
            {if ($format-name !='Other') then
               <span id="{$format-id}" style="display:block">
                    <p>{$format-snippet, $link}</p>
                </span>
             else ()}
        </div>
};

