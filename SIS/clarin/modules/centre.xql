xquery version "3.0";

module namespace cm = "http://clarin.ids-mannheim.de/standards/centre-module";
import module namespace centre = "http://clarin.ids-mannheim.de/standards/centre" at "../model/centre.xqm";

declare function cm:list-centre() {
    for $c in $centre:centres
    let $status-text := data($c/nodeInfo/ri/@status)
    let $statuses :=
    if (fn:contains($status-text, ","))
    then
        <span>{
                for $status in fn:tokenize(data($c/nodeInfo/ri/@status), ",")
                return
                    ($status, <br/>)
            }
        </span>
    else
        $status-text
    
    return
        <tr>
            <td class="recommendation-row">{data($c/@id)}</td>
            <td class="recommendation-row">{$c/name/text()}</td>
            <td class="recommendation-row">{$c/nodeInfo/ri/text()}</td>
            <td class="recommendation-row">{$statuses}</td>
        </tr>
};
