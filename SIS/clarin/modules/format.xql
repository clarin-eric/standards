xquery version "3.1";

module namespace fm = "http://clarin.ids-mannheim.de/standards/format-module";
import module namespace app = "http://clarin.ids-mannheim.de/standards/app" at "app.xql";

import module namespace spec = "http://clarin.ids-mannheim.de/standards/specification" at "../model/spec.xqm";
import module namespace format = "http://clarin.ids-mannheim.de/standards/format" at "../model/format.xqm";

(:  Define format-related functions
    @author margaretha
:)

(: Retrieve a format node by its id :)
declare function fm:get-format($id as xs:string) {
    format:get-format($id)
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
    let $mime-types := fm:print-multiple-values($format/mimeType, "MIME types:")    
    return
        <div>
            <li>
                <span
                    class="list-text"><a
                        style="color:black;"
                        href="{$link}">{$format-abbr} ({$format-name})</a></span>
                <img
                    class="copy-icon pointer"
                    src="{app:resource("copy.png", "img")}"
                    width="14"
                    onclick="copyTextToClipboard('{$format-id}','{$format-id}')"/>
                <span
                    class="hint"
                    id="hint-{$format-id}">Format ID copied</span>
                {
                    if ($format-name != 'Other' and ($mime-type or $file-ext)) then
                        <p>{if ($mime-types) then ($mime-types,<br/>) else ()}
                            {fm:print-multiple-values($format/fileExt, "File extensions:")}</p>
                    else
                        ()
                }
            </li>
        </div>
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
        <li><span
                class="list-text">{$type}</span>
             <p>Formats: {$links}</p>
        </li>
};

declare function fm:get-formats-without-mime-types() {
    
    let $list := $format:formats[not(mimeType) or mimeType = ""]
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
    
    return
        <li><span
                class="list-text">No media types</span>
            <p>Formats: {$links}</p>
        </li>
};
