xquery version "3.0";

module namespace app="http://clarin.ids-mannheim.de/standards/app";

(: Base URL - enable for a production system :)
(:declare variable $app:base as xs:string := "http://clarin.ids-mannheim.de/standards/";
declare variable $app:securebase as xs:string := "https://clarin.ids-mannheim.de/standards/";:)


(: Local Base URL :)
declare variable $app:base as xs:string := "http://localhost:8889/exist/apps/clarin/";
declare variable $app:securebase as xs:string := "https://localhost:8444/exist/apps/clarin/";


declare function app:link($path as xs:string) {
    session:encode-url(fn:resolve-uri($path,$app:base))
};

declare function app:secure-link($path as xs:string){    
    session:encode-url(fn:resolve-uri($path,$app:securebase))
};

declare function app:resource($filename as xs:string, $type as xs:string){
    let $path := "../resources/"
    return    
        if ($type = "css") then concat($path,"css/",$filename)
        else if ($type = "js") then concat($path,"scripts/",$filename)
        else concat($path,"images/",$filename)    
};

declare function app:name($element){
    let $title := $element/titleStmt/title/text()
    let $abbr := $element/titleStmt/abbr/text()
    
    return
        if ($abbr and $abbr !='') then $abbr else $title
};

declare function app:wrap-links($links){
    for $link in $links
    let $url := app:link(data($link/@href))
    return 
        if (contains($links,".xq")) 
        then <a href="{$url}">{$link/text()}</a>
        else $link
};

declare function app:footer(){
    ("This site is work in progress.")
};