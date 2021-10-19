xquery version "3.1";

module namespace stm = "http://clarin.ids-mannheim.de/standards/statistics-module";

import module namespace format = "http://clarin.ids-mannheim.de/standards/format" at "../model/format.xqm";
import module namespace recommendation = "http://clarin.ids-mannheim.de/standards/recommendation-model" 
at "../model/recommendation-by-centre.xqm";
import module namespace domain = "http://clarin.ids-mannheim.de/standards/domain" at "../model/domain.xqm";

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
    order by fn:lower-case($domain)
    return 
    <tr>
        <td>{$domain}</td>
        <td style="text-align:right;">{count(recommendation:get-formats-by-domain($domain))}</td>
    </tr>
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
