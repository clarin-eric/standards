xquery version "3.0";

module namespace rsm ="http://clarin.ids-mannheim.de/standards/register-spec-module";

import module namespace spec = "http://clarin.ids-mannheim.de/standards/specification" at "../model/spec.xqm";
import module namespace app="http://clarin.ids-mannheim.de/standards/app" at "app.xql";
import module namespace asm ="http://clarin.ids-mannheim.de/standards/add-spec-module" at "add-spec.xql";
import module namespace functx = "http://www.functx.com" at "../resources/lib/functx-1.0-doc-2007-01.xq";

declare function rsm:get-input-class($submitted, $field){
    if($submitted and not($field)) then "inputTextError" else "inputText"
};

declare function rsm:get-select-class($submitted, $field){
    if($submitted and not($field)) then "inputSelectError" else "inputSelect"
};

declare function rsm:validate-spec($name,$topicRef,$description,$standard-setting-body){
    if ($name and $topicRef and $description and $standard-setting-body) 
    then rsm:store-spec($name,$topicRef,$description,$standard-setting-body) 
    else ()
};

declare function rsm:store-spec($name,$topicRef,$description,$standard-setting-body){
    let $abbr := request:get-parameter('abbr', '')
    let $scope := request:get-parameter('scope', '')
    let $keyword := request:get-parameter('keyword', '')
    
    let $id := concat('Spec',translate($name,' ',''))
    let $file := concat($id,'.xml')
    let $results := functx:get-matches-and-non-matches($keyword,'\s?,\s?')
    let $review-collection := '/db/clarin/review'
       
    let $spec :=  
        <spec xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" id="{$id}" 
              standardSettingBody="{$standard-setting-body}" topic="{$topicRef}" 
              xsi:noNamespaceSchemaLocation="../schemas/spec.xsd">
        	<titleStmt>
        		<title>{$name}</title>
        		<abbr>{$abbr}</abbr>
        	</titleStmt>
        	{if ($scope) then <scope>{$scope}</scope> else ()}
        	{for $key in $results/text()
               return
                   if (not(contains($key,',')))
                   then <keyword>{$key}</keyword>
                   else ()
        	}
        	{if($description) 
        	 then util:parse(asm:get-description($description)) 
        	 else <info type="description"></info>}        	
        </spec>    
    let $store := spec:store-review($file,$spec)
    let $part-uri := concat("views/register-part.xq?id=",$id)
    return response:redirect-to(app:link($part-uri))
};