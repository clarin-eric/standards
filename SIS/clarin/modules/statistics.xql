xquery version "3.1";

module namespace stm = "http://clarin.ids-mannheim.de/standards/statistics-module";

import module namespace format = "http://clarin.ids-mannheim.de/standards/format" at "../model/format.xqm";
import module namespace recommendation = "http://clarin.ids-mannheim.de/standards/recommendation-model" 
at "../model/recommendation-by-centre.xqm";
import module namespace domain = "http://clarin.ids-mannheim.de/standards/domain" at "../model/domain.xqm";
import module namespace app = "http://clarin.ids-mannheim.de/standards/app" at "../modules/app.xql";
import module namespace rf = "http://clarin.ids-mannheim.de/standards/recommended-formats" at "../modules/recommended-formats.xql";
import module namespace functx = "http://www.functx.com" at "../resources/lib/functx-1.0-doc-2007-01.xq";

declare function stm:list-formats-by-recommendation-level(){
    for $level in ("Recommended","Acceptable","Deprecated")
    let $l := lower-case($level)
    return
    <tr>
        <td>{$level}</td>
        <td style="text-align:right;">{count(recommendation:get-formats-by-recommendation-level($l))}</td>
    </tr>

};

declare function stm:list-format-by-domain(){
    for $domain in $domain:domains/name
    let $recommendations := recommendation:get-formats-by-domain($domain)
    order by fn:lower-case($domain)
    return 
    <tr>
        <td>{$domain}</td>
        <td style="text-align:right;">{count($recommendations)}</td>
    </tr>
};

declare function stm:get-formats-per-domain($threshold as xs:int){
    let $min-recommendations := if ($threshold) then $threshold else 1
    for $domain in $domain:domains/name
        let $recommendations := recommendation:get-formats-by-domain($domain)
        let $format-ids := fn:distinct-values($recommendations/@id)
        
        let $sorted :=
            for $id in $format-ids
             let $sum := count($recommendations[@id=$id])
             let $format-link := app:link(concat("views/view-format.xq?id=",$id))
             let $format-abbr := format:get-format($id)/titleStmt/abbr/text()
             order by $sum descending
             return
             if ($sum ge $min-recommendations)
             then
                <tr>
                    <td>{$domain}</td>
                    <td>{
                        if ($format-abbr) 
                        then <a href="{$format-link}">{$format-abbr }</a>
                        else rf:print-missing-format-link($id)
                    }
                    </td>
                    <td>{$sum}</td>
                </tr>
            else()
            
        order by fn:lower-case($domain)
        return $sorted 
};

declare function stm:filterTop3Values(){
    let $sorted := stm:get-formats-per-domain(1)
    
    for $domain in $domain:domains/name
        let $recommendations-by-domain := $sorted[td = $domain]
        let $unique-sum := fn:reverse(functx:sort-as-numeric(fn:distinct-values($recommendations-by-domain/td[3])))
        let $top-number := min((count($unique-sum),3))
        let $min-value := xs:int(fn:subsequence($unique-sum,$top-number,1))
        
        order by fn:lower-case($domain)
    return 
        for $r in $recommendations-by-domain
        let $sum := xs:int($r/td[3])
        order by $sum descending
        return 
            if ($sum ge $min-value)
            then $r
            else ()
    };

declare function stm:getMimeTypes(){
    fn:distinct-values($format:formats/mimeType/text())
};

declare function stm:list-format-by-media-types(){
    let $mime-types := stm:getMimeTypes()
    for $type in $mime-types
    order by fn:lower-case($type)
    return 
    <tr>
        <td>{$type}</td>
        <td style="text-align:right;">{count($format:formats[mimeType=$type])}</td>
    </tr>
};
