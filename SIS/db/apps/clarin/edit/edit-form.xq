xquery version "1.0";

module namespace f = "http://clarin.ids-mannheim.de/standards/module/form";

import module namespace spec = "http://clarin.ids-mannheim.de/standards/specification" at "../model/spec.xqm";
import module namespace xsd = "http://clarin.ids-mannheim.de/standards/schema" at "../model/schema.xqm";

import module namespace functx = "http://www.functx.com" at "../lib/functx-1.0-doc-2007-01.xq";

declare function f:validate-date($date) {
    if ($date) then matches($date,'^(19|20)\d\d-(0[1-9]|1[012])-(0[1-9]|[12][0-9]|3[01])$') 
    else fn:true()
};

declare function f:validate-url($url){
    if ($url) 
    then matches($url,'(^(ht|f)tp(s?)://)?([a-zA-Z\d\-]+\.)+[a-zA-Z]{2,3}(:[a-zA-Z\d]*)?/?([a-zA-Z\d:#@%/;$()~_?\+-=\\\.&amp;])*$') 
    else fn:true()
};

declare function f:list-options($list,$selected){
    for $item in $list/xs:enumeration
        let $i := data($item/@value)
        order by $i
        return
            if ($selected=$i)
            then <option selected= "true" value="{$selected}">{$selected}</option>
            else <option value="{$i}"> {$i} </option>
};

declare function f:list-targets($relation-target){
    for $spec in $spec:specs
        let $spec-id := data($spec/@id)
        let $spec-abbr := $spec/titleStmt/abbr/text()
        let $spec-name := if ($spec-abbr) then $spec-abbr else $spec/titleStmt/title/text()
        order by $spec-name
        return (
            if($relation-target = $spec-id)
            then <option value="{$spec-id}" selected="true">{$spec-name}</option>
            else <option value="{$spec-id}">{$spec-name}</option>,                                            
            
            for $version in $spec/descendant-or-self::version
                let $version-id := data($version/@id)
                let $version-number:= fn:string-join($version/versionNumber/text()," ")
                let $version-abbr := $version/titleStmt/abbr/text()
                let $version-name := if ($version-abbr) then $version-abbr else $version/titleStmt/title/text()
                return
                    if ($version-number and $relation-target = $version-id)
                    then <option value="{$version-id}" selected="true">{concat($spec-name," ",$version-number)}</option>
                    else if ($version-number)
                    then <option value="{$version-id}">{concat($spec-name," ",$version-number)}</option>
                    else if ($version-name)
                    then <option value="{$version-id}">{$version-name}</option>
                    else <option value="{$version-id}">{$version-id}</option>
            )
};

declare function f:get-parameters($param-names,$field,$num){
    for $i in (1 to $num)
        let $param := concat($field,$i)
        return
            if (functx:is-value-in-sequence($param,$param-names))
            then request:get-parameter($param, '')
            else ()
};

declare function f:get-param-names($param-names,$field){
    for $param in $param-names
        return if (fn:starts-with($param,$field)) then $param else ()
};

declare function f:get-options($list){
    let $options := 
        for $item in $list/xs:enumeration
        return concat("'", data($item/@value),"'")
    return concat("[",fn:string-join($options,","),"]")
}; 

declare function f:get-target-options(){
    let $targets:=
        for $spec in $spec:specs
            let $spec-id := data($spec/@id)
            let $spec-abbr := $spec/titleStmt/abbr/text()
            let $spec-name := if ($spec-abbr) then $spec-abbr else $spec/titleStmt/title/text()
            
            let $versions := 
                for $version in $spec/descendant-or-self::version
                    let $version-id := data($version/@id)
                    let $version-number:= fn:string-join($version/versionNumber/text()," ")
                    let $version-abbr := $version/titleStmt/abbr/text()
                    let $version-name := if ($version-abbr) then $version-abbr else $version/titleStmt/title/text()
                    return
                        if ($version-number) 
                        then concat("['", $version-id, "','",concat($spec-name," ",$version-number),"']")
                        else if ($version-name) then concat("['", $version-id, "','",$version-name,"']")
                        else concat("['", $version-id, "','",$version-id,"']")
            order by $spec-name
            return 
                if ($spec/version)                                            
                then concat("['", $spec-id , "','",$spec-name,"'],", fn:string-join($versions,","))
                else concat("['", $spec-id , "','",$spec-name,"']")
                
    return concat("[",fn:string-join($targets,","),"]")
};

