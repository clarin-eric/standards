xquery version "3.1";

module namespace fm = "http://clarin.ids-mannheim.de/standards/format-module";
import module namespace app = "http://clarin.ids-mannheim.de/standards/app" at "app.xql";

import module namespace spec = "http://clarin.ids-mannheim.de/standards/specification" at "../model/spec.xqm";
import module namespace format = "http://clarin.ids-mannheim.de/standards/format" at "../model/format.xqm";
import module namespace recommendation = "http://clarin.ids-mannheim.de/standards/recommendation-model"
at "../model/recommendation-by-centre.xqm";

(:  Define format-related functions
    @author margaretha
:)

(: Retrieve a format node by its id :)
declare function fm:get-format($id as xs:string) {
    format:get-format($id)
};

(: Provide the number of formats defined in the SIS :)
declare function fm:count-defined-formats() {
    let $formats := format:get-all-ids()
    return count($formats)
};

(: Generate the list of formats :)
declare function fm:list-formats() {
    for $format in $format:formats
    let $format-id := data($format/@id)
    let $format-name := $format/titleStmt/title/text()
    let $format-abbr := $format/titleStmt/abbr/text()
    (:let $format-snippet := $format/info[@type="description"]/p[1]/text():)
    let $mime-type := $format/mimeType/text()
    let $file-ext := $format/fileExt/text()
    let $link := app:link(concat("views/view-format.xq?id=", $format-id))
        order by fn:lower-case($format-abbr)
    let $link-title := concat($format-abbr, " (",$format-name,")")
    let $mime-types := fm:print-multiple-values($format/mimeType, "MIME types:")    
    return
        <div>
            <li>
                <span class="list-text"><a href="{$link}">{$link-title}</a></span>
                {
                    app:create-copy-button($format-id,$format-id,"Copy ID to clipboard","Format ID copied"),
                    if ($format-name != 'Other' and ($mime-type or $file-ext)) then
                        <p>{if ($mime-types) then ($mime-types,<br/>) else ()}
                            {fm:print-multiple-values($format/fileExt, "File extensions:")}</p>
                    else
                        ()
                }
            </li>
        </div>
};

declare function fm:count-orphan-format-ids(){
    let $orphan-ids := fm:list-orphan-format-ids()
return count($orphan-ids) 
};

declare function fm:list-orphan-format-ids(){
    let $recommended-ids := $recommendation:centres/formats/format/descendant-or-self::node()/@id
    let $orphan-ids := $format:formats/@id[not (. = $recommended-ids )]
        for $id in $orphan-ids
    order by lower-case($id)
    return
        <li><a href="{app:link(concat("views/view-format.xq?id=",$id))}">{data($id)}</a></li> 
};

declare function fm:count-missing-format-ids(){
    let $format-ids := data(fm:list-missing-format-ids())
    return count($format-ids)
};

declare function fm:list-missing-format-ids(){
    let $format-ids := fn:distinct-values($recommendation:centres/formats/format/@id)
    for $id in $format-ids
    order by lower-case($id)
    return
        if (format:get-format($id)) then ()
            else <li><a href="{app:getGithubIssueLink($id)}">{$id}</a></li> 
};

(:@Deprecated:)
declare function fm:list-missing-format-abbrs(){
    let $format-abbrs := fn:distinct-values($recommendation:centres/formats/format/name)
    for $abbr in $format-abbrs
    order by lower-case($abbr)
    return
        if (format:get-format-by-abbr($abbr)) then ()
            else <li>{$abbr}</li> 
};

declare function fm:print-multiple-values($list, $label) {
    let $numOfItems := count($list)
    let $max := fn:max(($numOfItems, 1))
    let $list := fn:sort($list)
    return
        if ($list)
        then
            (
            <span>{$label}&#160;</span>,
            <span
                id="keytext">
                {
                    for $k in (1 to $numOfItems)
                    return
                        ($list[$k]/text(),
                        if ($list[$k]/@type)
                        then
                            (<span
                                id="abbrinternalText"
                                style="margin-left:5px;">({data($list[$k]/@type)})</span>)
                        else
                            (),
                        if ($list[$k][@recommended = "yes"])
                        then
                            (<span
                                id="abbrinternalText"
                                style="font-size:10px;margin-left:5px;">[recommended]</span>)
                        else
                            (),
                        if ($k = $numOfItems) then
                            ()
                        else
                            ", "
                        )
                }
            </span>
            
            )
        else
            ()
};

declare function fm:list-mime-types() {
    let $mime-types := fn:distinct-values($format:formats/mimeType/text())
    for $type in $mime-types
       let $list := $format:formats[mimeType = $type]
       let $numOfItems := count($list)
       let $links : = 
           for $k in (1 to $numOfItems)
               let $format := $list[$k]
               let $abbr := $format/titleStmt/abbr
               let $id := data($format/@id)
               let $link := <a href="{app:link(concat("views/view-format.xq?id=",$id))}">{$abbr}</a>
               return 
                   if ($k = $numOfItems) then
                       ($link)
                   else
                       ($link, ", ")
       
        order by $type
    return
        <tr>
            <td class="row">{$type}</td>
            <td class="row">{$links}</td>
        </tr>
};

declare function fm:list-extensions() {
    let $extensions := fn:distinct-values($format:formats/fileExt/text())
    for $e in $extensions
       let $list := $format:formats[fileExt = $e]
       let $numOfItems := count($list)
       let $links : = 
           for $k in (1 to $numOfItems)
               let $format := $list[$k]
               let $abbr := $format/titleStmt/abbr
               let $id := data($format/@id)
               let $link := <a href="{app:link(concat("views/view-format.xq?id=",$id))}">{$abbr}</a>
               return 
                   if ($k = $numOfItems) then
                       ($link)
                   else
                       ($link, ", ")
       
        order by fn:lower-case($e)
    return
        <tr>
            <td class="row"><span
                class="list-text">{$e}</span></td>
            <td class="row">{$links}</td>
        </tr>
};

declare function fm:get-formats-without-extensions() {
    let $list := $format:formats[not(fileExt) or fileExt = ""]
    let $numOfItems := count($list)
    for $k in (1 to $numOfItems)
        let $format := $list[$k]
        let $abbr := $format/titleStmt/abbr
        let $id := data($format/@id)
        let $link := <a href="{app:link(concat("views/view-format.xq?id=",$id))}">{$abbr}</a>
        return <li>{$link}</li>
};

declare function fm:get-formats-without-mime-types() {
    let $list := $format:formats[not(mimeType) or mimeType = ""]
    let $numOfItems := count($list)
    for $k in (1 to $numOfItems)
        let $format := $list[$k]
        let $abbr := $format/titleStmt/abbr
        let $id := data($format/@id)
        let $link := <a href="{app:link(concat("views/view-format.xq?id=",$id))}">{$abbr}</a>
        return <li>{$link}</li>
    
};

declare function fm:get-format-families($sortBy){
    for $format in $format:formats
    let $id := data($format/@id)
    let $ff := $format/formatFamily
    let $order := if ($sortBy eq "ff") then $ff else $id
    order by fn:lower-case($order)
    return
        <tr>
            <td class="row">{$id}</td>
            <td class="row">{$ff}</td>
        </tr>
        
};
