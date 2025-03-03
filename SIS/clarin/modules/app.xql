xquery version "3.1";

module namespace app = "http://clarin.ids-mannheim.de/standards/app";
import module namespace web = "https://clarin.ids-mannheim.de/standards/web" at "../model/web.xqm";
import module namespace request = "http://exist-db.org/xquery/request";

(:declare namespace request="http://exist-db.org/xquery/request";
declare namespace functx = "http://www.functx.com";

declare variable $app:request-module := load-xquery-module("http://exist-db.org/xquery/request");
declare variable $app:functx-module :=load-xquery-module("http://www.functx.com");
:)
(: Define general functions
   @author margaretha
:)

(: Base URI :)
declare variable $app:base as xs:string := app:determine-base-uri();

(:declare function app:determine-base-uri(){
    let $get-server-name := $app:request-module?functions?(xs:QName("request:get-server-name"))
    (\:let $get-server-name := $app:request-module?functions(xs:QName("request:get-server-name"))?0:\)
    let $server-name := request:get-server-name()
    (\:let $server-name := $app:functx-module?functions(xs:QName('functx:substring-after-last'))?2('This-is-a-test.','is'):\)
    return     
       if ($server-name eq "localhost") 
       then concat("http://", $server-name, ":", $app:request-module?functions?get-server-port(),"/exist/apps/clarin/")
       else if ($server-name eq "standards.clarin.eu")
       then concat("https://",$server-name,"/sis/")
       else concat("https://",$server-name,"/standards/")
       
};:)

declare function app:determine-base-uri() {
    let $server-name := request:get-server-name()
    return
        if ($server-name eq "localhost")
        then
            concat("http://", $server-name, ":", request:get-server-port(), "/exist/apps/clarin/")
        else
            if ($server-name eq "standards.clarin.eu")
            then
                concat("https://", $server-name, "/sis/")
            else
                concat("https://", $server-name, "/standards/")
};

(: Wrap a link with the current session :)
declare function app:link($path as xs:string) {
    fn:resolve-uri($path, $app:base)
};

declare function app:favicon(){
    app:resource("medal-sis.png", "image")
};

(: Resolve a resource location :)
declare function app:resource($filename as xs:string, $type as xs:string) {
    let $path := "../resources/"
    return
        if ($type = "css") then
            concat($path, "css/", $filename)
        else
            if ($type = "js") then
                concat($path, "scripts/", $filename)
            else
                concat($path, "images/", $filename)
};

declare function app:create-collapse-expand($id, $label, $content, $customStyle) {
    let $basic := "display:none;"
    let $style :=
        if ($customStyle) then concat($basic,$customStyle)
        else $basic
    return
    (<span class="pointer" onclick="showHide('dots-{$id}','inline');
        showHide('{$id}','block')">
        {$label}
    </span>,
    <span id="dots-{$id}" style="display:inline;">...</span> 
    ,
    <ul id="{$id}" style="{$style}">
        {$content}
    </ul>)
};

declare function app:create-copy-button($id, $copy-text, $tooltiptext, $hint) {
    (
    <span class="tooltip">
        <img class="copy-icon pointer" src="{app:resource("copy.png", "img")}"
            width="14" onclick="copyTextToClipboard('{$id}','{$copy-text}')"/>
        <span class="tooltiptext" style="width:160px;">{$tooltiptext}
        </span>
    </span>,
    <span
        class="hint"
        id="hint-{$id}">{$hint}</span>
    )
};

declare function app:getGithubIssueLink() {
    let $ghLink := 'https://github.com/clarin-eric/standards/issues/new?assignees=&amp;labels=SIS%3Aformats%2C+templatic&amp;template=incorrect-missing-format-description.md&amp;title='
    let $ghLink := concat($ghLink, 'commitId=', web:get-short-commitId())
    return
        $ghLink
};

declare function app:getGithubIssueLink($format-id) {
    let $ghLink := 'https://github.com/clarin-eric/standards/issues/new?assignees=&amp;labels=SIS%3Aformats%2C+templatic&amp;template=incorrect-missing-format-description.md&amp;title=Suggestion regarding the description of format ID="'
    let $ghLink := concat($ghLink, $format-id, '", commitId=', web:get-short-commitId())
    return
        $ghLink
};

declare function app:footer() {
    let $githubLink := concat("https://github.com/clarin-eric/standards/commit/", $web:commitId)
    return
        
        <div style="text-align: right">
            <span><b>Version ID</b>: <a href="{$githubLink}">{web:get-short-commitId()}</a></span>
        </div>

};
