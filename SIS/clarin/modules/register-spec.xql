xquery version "3.0";

module namespace rsm ="http://clarin.ids-mannheim.de/standards/register-spec-module";
import module namespace data = "http://clarin.ids-mannheim.de/standards/data" at "../model/data.xqm";
import module namespace spec = "http://clarin.ids-mannheim.de/standards/specification" at "../model/spec.xqm";
import module namespace app="http://clarin.ids-mannheim.de/standards/app" at "app.xql";
import module namespace asm ="http://clarin.ids-mannheim.de/standards/add-spec-module" at "add-spec.xql";
import module namespace functx = "http://www.functx.com" at "../resources/lib/functx-1.0-doc-2007-01.xq";

(: Declare functions for registering a standard 
   @author margaretha
:)

(: Define the class attribute of an input field :)
declare function rsm:get-input-class($submitted, $field){
    if($submitted and not($field)) then "inputTextError" else "inputText"
};

(: Define the class for the id field :)
declare function rsm:get-id-class($submitted, $field, $valid){
    if($submitted and (not($field) or not($valid))) then "inputTextError" else "inputText"
};

(: Get the display value for an error message :)
declare function rsm:get-display-error($id,$valid){
    if ($id and not($valid)) then "table-row" else "none"
};

(: Get the field width for abbreviation edit form :)
declare function rsm:get-width(){
   if (session:get-attribute('user')='webadmin')
    then '295px' else '400px'
};

(: Define the class of an input select field :)
declare function rsm:get-select-class($submitted, $field){
    if($submitted and not($field)) then "inputSelectError" else "inputSelect"
};

(: Validate id :)
declare function rsm:validate-id($param-id){
    let $id := if (starts-with($param-id,"Spec")) then $param-id else (concat("Spec",$param-id))    
    let $ids := data:get-all-ids()
    return
    if (not($param-id) or 
        fn:matches($param-id,"[^a-zA-Z0-9\.\-]") or
        functx:is-value-in-sequence($id,$ids))    
        then fn:false()        
        else fn:true()
};

(: Validate necessary fields for a standard :)
declare function rsm:validate-spec($submitted,$validate-id,$id,$name,$scope,$topicRef,$description,$standard-setting-body){    
    if ($submitted) then
        if ($validate-id and $name and $scope and $topicRef and $description and $standard-setting-body) 
        then rsm:store-spec($id,$name,$scope,$topicRef,$description,$standard-setting-body)
        else ()        
    else ()
};

(: Define a new standard and store it to review/ for a submission from a user,
   or to specifications/ for a submission from a web-admin :)
declare function rsm:store-spec($id,$name,$scope,$topicRef,$description,$standard-setting-body){    
    let $keyword := request:get-parameter('keyword', '')
    let $abbr := request:get-parameter('abbr', '')
    let $internal := request:get-parameter('internal', '')
    let $id := request:get-parameter('id', '')
    let $id := if (starts-with($id,"Spec")) then $id else (concat("Spec",$id))
        
    let $file := concat($id,'.xml')
    let $results := functx:get-matches-and-non-matches($keyword,'\s?,\s?')
    let $review-collection := '/db/clarin/review'
    let $schema := "../../schemas/spec.xsd"
    
    let $abbr-node :=
        if ($abbr) then <abbr internal="no">{$abbr}</abbr>
        else <abbr internal="yes">{substring($name,1,6)}</abbr>    
        
    let $spec :=  
        <spec xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" id="{$id}" 
              standardSettingBody="{$standard-setting-body}" topic="{$topicRef}" 
              xsi:noNamespaceSchemaLocation="{$schema}">
        	<titleStmt>
        		<title>{$name}</title>
        		{$abbr-node}
        	</titleStmt>
        	<scope>{$scope}</scope>
        	{for $key in $results/text()
               return
                   if (not(contains($key,',')))
                   then <keyword>{$key}</keyword>
                   else ()
        	}
        	{if($description) 
        	 then fn:parse-xml(asm:get-description($description)) 
        	 else <info type="description"></info>}        	
        </spec>    
    let $store := 
        if (session:get-attribute('user')='webadmin') 
        then spec:store-new-spec($file,$spec,$data:spec-path)
        else spec:store-new-spec($file,$spec,$data:review-path)
        
    let $part-uri := concat("views/register-part.xq?id=",$id)
    return response:redirect-to(app:link($part-uri))
};