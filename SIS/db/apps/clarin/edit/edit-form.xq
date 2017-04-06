xquery version "1.0";

module namespace f = "http://clarin.ids-mannheim.de/standards/module/form";

import module namespace spec = "http://clarin.ids-mannheim.de/standards/specification" at "../model/spec.xqm";
import module namespace xsd = "http://clarin.ids-mannheim.de/standards/schema" at "../model/schema.xqm";

import module namespace functx = "http://www.functx.com" at "../lib/functx-1.0-doc-2007-01.xq";

(: Define functions needed in edit or add forms
   @author margaretha
:)

(: Validate date :)
declare function f:validate-date($date) {
    if ($date) then matches($date,'^(19|20)\d\d-(0[1-9]|1[012])-(0[1-9]|[12][0-9]|3[01])$') 
    else fn:true()
};

(: Validate url :)
declare function f:validate-url($url){
    if ($url) 
    then matches($url,'(^(ht|f)tp(s?)://)?([a-zA-Z\d\-]+\.)+[a-zA-Z]{2,3}(:[a-zA-Z\d]*)?/?([a-zA-Z\d:#@%/;$()~_?\+-=\\\.&amp;])*$') 
    else fn:true()
};

(: Generate a list of options from the given list :)
declare function f:list-options($list,$selected){
    for $item in $list        
        order by $item
        return 
            if ($selected=$item)
            then <option selected= "true" value="{$selected}">{$selected}</option>
            else <option value="{$item}"> {$item} </option>
};

(: Generate options of standard versions as the target of a standard relation :)
declare function f:list-targets($relation-target){
    for $spec in $spec:specs
        let $spec-id := data($spec/@id)
        let $spec-abbr := $spec/titleStmt/abbr/text()        
        order by $spec-abbr
        return (
            if($relation-target = $spec-id)
            then <option value="{$spec-id}" selected="true">{$spec-abbr}</option>
            else <option value="{$spec-id}">{$spec-abbr}</option>,                                            
            
            for $version in $spec/descendant-or-self::version
                let $version-id := data($version/@id)                
                let $version-abbr := $version/titleStmt/abbr/text()
                let $version-date := substring($version/date,1,4)
                let $version-name := 
                    if ($version-abbr) then $version-abbr else concat($spec-abbr,"-",$version-date)                
                return
                    if ($relation-target = $version-id)
                    then <option value="{$version-id}" selected="true">{$version-name}</option>
                    else <option value="{$version-id}">{$version-name}</option>            
            )
};

(: Get the values of some request parameters :)
declare function f:get-parameters($param-names,$field,$num){
    for $i in (1 to $num)
        let $param := concat($field,$i)
        return
            if (functx:is-value-in-sequence($param,$param-names))
            then request:get-parameter($param, '')
            else ()
};

(: Get a group of the request parameters of some field :)
declare function f:get-param-names($param-names,$field){
    for $param in $param-names
        return if (fn:starts-with($param,$field)) then $param else ()
};

(: Create a sequence of options as a json array :)
declare function f:get-options($list){
    let $options := 
        for $item in $list
        return concat("'", $item,"'")
    return concat("[",fn:string-join($options,","),"]")
}; 


(: Create a sequence of standards and standard version as a json array :)
declare function f:get-target-options(){
    let $targets:=
        for $spec in $spec:specs
            let $spec-id := data($spec/@id)
            let $spec-abbr := $spec/titleStmt/abbr/text()            
            
            let $versions := 
                for $version in $spec/descendant-or-self::version
                    let $version-id := data($version/@id)                    
                    let $version-abbr := $version/titleStmt/abbr/text()
                    let $version-date := substring($version/date,1,4)
                    let $version-name := 
                        if ($version-abbr) then $version-abbr else concat($spec-abbr,"-",$version-date)   
                    return concat("['", $version-id, "','",$version-name,"']")
                        
            order by $spec-abbr
            return 
                if ($spec/version)                                            
                then concat("['", $spec-id , "','",$spec-abbr,"'],", fn:string-join($versions,","))
                else concat("['", $spec-id , "','",$spec-abbr,"']")
                
    return concat("[",fn:string-join($targets,","),"]")
};

(: Generate a random id of length 6 characters :)
declare function f:generateRandomId($ids){
    
    let $login := xmldb:login('/db/clarin/data', 'webadmin', 'webadmin')
    let $alpha := functx:chars("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghiklmnopqrstuvwxyz")
    let $alpha_length := count($alpha)    
    let $chars := functx:chars("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghiklmnopqrstuvwxyz")
    let $char_length := count($chars)
    let $string_length := 6
    let $id := fn:string-join(
        for $i in (1 to $string_length)
           let $index := 
                if ($i=1)
                then util:random($alpha_length)+1
                else util:random($char_length)+1
           let $char :=
                if ($i=1)
                then $alpha[$index]
                else $chars[$index]
           return $char
       , "")
    return 
        if (fn:index-of($ids,$id)>0) then f:generateRandomId($ids)
        else $id
};
