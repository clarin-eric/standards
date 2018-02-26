xquery version "3.0";

module namespace app="http://clarin.ids-mannheim.de/standards/app";

(: Define general functions
   @author margaretha
:)

(: Base URL :)
declare variable $app:base as xs:string := "http://standards.clarin.eu/sis/";
declare variable $app:securebase as xs:string := "http://standards.clarin.eu/sis/";


(: Local Base URL :)
(:declare variable $app:base as xs:string := "http://localhost:8889/exist/apps/clarin/";
declare variable $app:securebase as xs:string := "http://localhost:8889/exist/apps/clarin/";:)


(: Wrap a link with the current session :)
declare function app:link($path as xs:string) {
    session:encode-url(fn:resolve-uri($path,$app:base))
};

(: Wrap a link with the current session and the secure port :)
declare function app:secure-link($path as xs:string){    
    session:encode-url(fn:resolve-uri($path,$app:securebase))
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

declare function app:footer(){
    ("This site is work in progress.")
};