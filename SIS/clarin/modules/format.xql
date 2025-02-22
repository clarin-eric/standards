xquery version "3.1";

module namespace fm = "http://clarin.ids-mannheim.de/standards/format-module";
import module namespace app = "http://clarin.ids-mannheim.de/standards/app" at "app.xql";

import module namespace spec = "http://clarin.ids-mannheim.de/standards/specification" at "../model/spec.xqm";
import module namespace format = "http://clarin.ids-mannheim.de/standards/format" at "../model/format.xqm";
import module namespace recommendation = "http://clarin.ids-mannheim.de/standards/recommendation-model"
at "../model/recommendation-by-centre.xqm";
import module namespace rf = "http://clarin.ids-mannheim.de/standards/recommended-formats" 
at "../modules/recommended-formats.xql";

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

declare function fm:list-search-suggestion(){
    let $formats := $format:formats
    let $format-name := $formats/titleStmt/title/text()
    let $format-abbr := $formats/titleStmt/abbr/text()
    (:let $mime-types := distinct-values($formats/mimeType)
    let $file-exts := distinct-values($formats/fileExt):)
        
    let $union := 
        for $item in ($format-name,$format-abbr)
        (:,$mime-types,$file-exts):) 
        order by fn:lower-case($item) 
        return $item 

    return fn:string-join($union,",")
    
};

declare function fm:create-format-link($format-id, $format-abbr, $format-name){
        let $link := app:link(concat("views/view-format.xq?id=", $format-id))
            
        let $link-title := 
            if (exists($format-name))
                then $format-abbr
                else concat($format-abbr, " (",$format-name,")")
                
        return <a href="{$link}">{$link-title}</a>
};

(: Generate the list of formats :)
declare function fm:list-formats($keyword,$searchItem) {
    let $formats :=
        if ($searchItem) 
            then $format:formats[titleStmt/abbr/text()=$searchItem or 
                titleStmt/title/text()=$searchItem]
        else if ($keyword) then $format:formats[keyword=$keyword]
        else $format:formats

    for $format in $formats
        let $format-id := data($format/@id)
        let $format-name := $format/titleStmt/title/text()
        let $format-abbr := $format/titleStmt/abbr/text()
        (:let $format-snippet := $format/info[@type="description"]/p[1]/text():)
        let $mime-types := $format/mimeType
        let $file-exts := $format/fileExt
      (:  let $link := app:link(concat("views/view-format.xq?id=", $format-id))
            order by fn:lower-case($format-abbr)
        let $link-title := concat($format-abbr, " (",$format-name,")"):)
        order by fn:lower-case($format-abbr)
    return
        <tr>
            <td class="row" style="vertical-align:top">
                <span class="list-text">{fm:create-format-link($format-id,$format-abbr,$format-name)}
                <!--<a href="{$link}">{$link-title}</a>-->
                </span>
                {app:create-copy-button($format-id,$format-id,"Copy ID to clipboard","Format ID copied")}
            </td>
            <td class="row">
            {      
                if ($format-name != 'Other' and $mime-types) 
                then  fm:print-multiple-values($mime-types)
                else ()
                }
            </td>
            <td class="row">
            {
                if ($format-name != 'Other' and $file-exts)
                then fm:print-multiple-values($file-exts)
                else ()
            }
            </td>
        </tr>
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

declare function fm:get-missing-format-ids(){
    let $format-ids := fn:distinct-values($recommendation:centres/formats/format/@id)
    for $id in $format-ids
        return
               if (format:get-format($id)) then ()
               else ($id)
};

declare function fm:count-missing-format-ids(){
    let $format-ids := fm:get-missing-format-ids()
    return count($format-ids)
};

declare function fm:list-missing-format-ids($sortBy){
    let $missingFormatIds := fm:get-missing-format-ids()
    let $isAscending := if ($sortBy eq "id") then fn:true() else fn:false()

    let $results := 
    for $id in $missingFormatIds
        let $recommendations := recommendation:get-recommendations-for-format($id)
        let $numOfRecommendations := count($recommendations)
        let $sortBy := if ($sortBy eq "id") then $id else $numOfRecommendations 
        order by $sortBy
        descending
        return 
            <li>
                <span class="pointer" onclick="showHide('{$id}','block')"> 
                    {fn:substring($id, 2)} ({$numOfRecommendations}) </span>
                {rf:print-missing-format-link($id)}
                {app:create-copy-button($id,$id,"Copy ID to clipboard","Format ID copied")}
                <ul id="{$id}" style="display:none; padding-left:15px;">
                    {for $r in $recommendations
                        let $centre-id := data($r/header/centre/@id)
                        order by lower-case($centre-id)
                        return
                        <li><a href="{app:link(concat("views/view-centre.xq?id=", $centre-id))}">{$centre-id}</a></li>
                    }
                </ul> 
            </li>
      
      return
      if ($isAscending) then fn:reverse($results) else $results
};



declare function fm:list-centre-with-missing-formats(){
    let $missingFormatIds := fm:get-missing-format-ids()
    
    let $centres := 
        for $r in $recommendation:centres
        let $format-ids := $r/formats/format/@id
        let $actualMissingFormatIds :=
            for $id in $format-ids
            return
                if (contains($missingFormatIds,$id)) then $id else ()
        let $numOfMissingFormats := count($actualMissingFormatIds)
        let $centre-id := data($r/header/centre/@id)
        order by $numOfMissingFormats
        descending
        return 
        if ($numOfMissingFormats = 0 ) then () 
        else <li><a href="{app:link(concat("views/view-centre.xq?id=", $centre-id))}">{$centre-id}</a> 
            ({$numOfMissingFormats})</li>
    
    for $c in $centres[position()]
    return $c
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

declare function fm:print-multiple-values($list) {
    let $numOfItems := count($list)
    let $list := fn:sort($list)
    let $text-width := 25
    
    for $k in (1 to $numOfItems)
        let $text := $list[$k]/text()
        return
            (fm:substring-every-width($text,$text-width),
            (:if ($list[$k][@recommended = "yes"] )
            then
                (<span
                    id="abbrinternalText"
                    style="font-size:10px;margin-left:5px;">[recommended]</span>)
            else
                (),:)
            if ($k = $numOfItems) then () else ", "
            )
};

declare function fm:substring-every-width($text,$text-width){
        let $text-length := string-length($text)
        return
            if ($text-length > $text-width) then
                for $i in 0 to $text-length idiv $text-width
                let $pos := $i * $text-width + 1
                return substring($text, $pos, $text-width)
            else $text
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
