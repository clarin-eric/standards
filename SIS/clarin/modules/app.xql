xquery version "3.0";

module namespace app="http://clarin.ids-mannheim.de/standards/app";
import module namespace web="https://clarin.ids-mannheim.de/standards/web" at "../model/web.xqm";


(: Define general functions
   @author margaretha
:)

(: Base URL :)
(:declare variable $app:base as xs:string := "https://standards.clarin.eu/sis/";
declare variable $app:securebase as xs:string := "https://standards.clarin.eu/sis/";
:)

(: Local Base URL :)
declare variable $app:base as xs:string := "http://localhost:8889/exist/apps/clarin/";


(: Wrap a link with the current session :)
declare function app:link($path as xs:string) {
    fn:resolve-uri($path,$app:base)
};

(: Resolve a resource location :)
declare function app:resource($filename as xs:string, $type as xs:string){
    let $path := "../resources/"
    return    
        if ($type = "css") then concat($path,"css/",$filename)
        else if ($type = "js") then concat($path,"scripts/",$filename)
        else concat($path,"images/",$filename)    
};

(: Set a display value :)
declare function app:get-display(){
    if (session:get-attribute('user')='webadmin')
    then 'inline' else 'none'
};

(: Define the class attribute of an input field :)
declare function app:get-input-class($submitted, $field){
    if($submitted and not($field)) then "inputTextError" else "inputText"
};

declare function app:getGithubIssueLink() {
    let $ghLink := 'https://github.com/clarin-eric/standards/issues/new?assignees=&amp;labels=SIS%3Aformats%2C+templatic&amp;template=incorrect-missing-format-description.md&amp;title=' 
    let $ghLink := concat($ghLink, 'commitId=',$web:commitId)
    return $ghLink
};

declare function app:getGithubIssueLink($format-id) {
    let $ghLink := 'https://github.com/clarin-eric/standards/issues/new?assignees=&amp;labels=SIS%3Aformats%2C+templatic&amp;template=incorrect-missing-format-description.md&amp;title=Suggestion regarding the description of format ID="' 
    let $ghLink := concat($ghLink, $format-id, '", commitId=',$web:commitId)
    return $ghLink
};

declare function app:footer(){
    let $githubLink := concat("https://github.com/clarin-eric/standards/commit/", $web:commitId)
    return
       
    <div style="text-align: right">
        <span><b>Web-version</b>: <a href="{$githubLink}">{$web:commitId}</a></span>
    </div>
    
};