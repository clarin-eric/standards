xquery version "3.1";

import module namespace app = "http://clarin.ids-mannheim.de/standards/app" at "../modules/app.xql";
import module namespace menu = "http://clarin.ids-mannheim.de/standards/menu" at "../modules/menu.xql";
import module namespace vsm ="http://clarin.ids-mannheim.de/standards/view-spec" at "../modules/view-spec.xql";
import module namespace asm ="http://clarin.ids-mannheim.de/standards/add-spec-module" at "../modules/add-spec.xql";
import module namespace rsm ="http://clarin.ids-mannheim.de/standards/register-spec-module" at "../modules/register-spec.xql";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "html";
declare option output:media-type "text/html";
declare option output:indent "yes";
declare option output:html-version "5";

(: Define the adding standard part page
   @author margaretha
:)

let $id := request:get-parameter('id', '')
let $spec := asm:get-spec($id)
let $spec-name := asm:get-spec-name($spec)

let $submitted := request:get-parameter("submitPart","")
let $part-id := request:get-parameter("pid","")
let $part-name := request:get-parameter("pname","")
let $part-abbr := request:get-parameter("pabbr","")
let $part-scope := request:get-parameter("pscope","")
let $part-keyword := request:get-parameter("pkeyword","")
let $part-description := request:get-parameter("pdescription","")

let $validate-id := rsm:validate-id($part-id)
let $validation := asm:validate-part($submitted,$spec,$validate-id,$part-id,
    $part-name,$part-abbr,$part-scope,$part-keyword,$part-description)  

return

<html lang="en">
    <head>
       <title>Adding a Part of {$spec-name}</title>       
        <link rel="icon" type="image/x-icon" href="{app:favicon()}"/>
        <link rel="stylesheet" type="text/css" href="{app:resource("style.css","css")}"/>
        <script type="text/javascript" src="{app:resource("edit.js","js")}"/>
        <script type="text/javascript" src="{app:resource("tinymce/tinymce.min.js","js")}"/>
        <script type="text/javascript" src="{app:resource("xmleditor.js","js")}"/>
    </head>   
    <body>
        <div id="all">
        <div class="logoheader"/>		
             {menu:view()}
        <div class="content">
             <div class="navigation">
                &gt; <a href="{app:link("views/list-specs.xq?sortBy=name&amp;page=1")}">Standards</a>
                &gt; <a href="{app:link(concat("views/view-spec.xq?id=", $id))}">{$spec-name}</a> 
                &gt; <a href="{app:link(concat("views/add-spec-part.xq?id=", $id))}">Adding Part</a>
             </div>
             <div><span class="title">Adding a Part of {$spec-name}</span></div>             
             
             <div><p>Please fill in and submit the form below. A new part will be added to the {$spec-name} 
             following any other existing parts. <b>A part must have at least one version.</b> A part that does not have a version will not be shown in 
             the standard description. After creating a part, you can add a version of the part later by 
             clicking "Add Version" button in <a href="{app:link(concat("views/view-spec.xq?id=", $id))}">{$spec-name}</a> 
             and follow the instructions written in there.</p></div>
             
             <form method="post" action="" enctype="multipart/form-data" >
                <table style="padding:20px; margin-top:20px;">
                    <tr>
                        <td style="width:100px">Id:*</td>
                        <td><input name="pid" type="text" value="{$part-id}" 
                            class="{rsm:get-id-class($submitted,$part-id,$validate-id)}" style="width:450px;"
                            placeholder="Only alphanumeric . and - characters are allowed."/>
                       </td>
                    </tr>
                    <tr style="display:{rsm:get-display-error($part-id,$validate-id)}">
                        <td></td>
                        <td><span style="color:red;">* Id is not available or contains invalid characters. 
                        Only alphanumeric . and <br/>- characters are allowed.</span></td>
                     </tr>
                    <tr><td style="width:100px">Title:*</td>
                         <td><input name="pname" value="{$part-name}" type="text" 
                            class="{rsm:get-input-class($submitted,$part-name)}" style="width:450px;"/></td>
                    </tr>                    
                    <tr><td>Abbreviation:</td>
                        <td><input name="pabbr" value="{$part-abbr}" type="text" class="inputText" style="width:450px;"/></td>
                    </tr>                            
                    <tr> <td>Scope:</td>
                         <td><input name="pscope" value="{$part-scope}" placeholder="Describe the standard part purpose, e.g. Corpus annotation." 
                            type="text" class="inputText" style="width:450px;"/></td>
                    </tr>
                    <tr><td>Keyword(s):</td>
                        <td>
                            <input name="pkeyword" value="{$part-keyword}" type="text" class="inputText" style="width:450px;"
                            placeholder="Multiple keywords are separated with a comma, e.g. SGML, XCES." />
                        </td>
                    </tr>
                    <tr valign="top"><td>Description:</td>
                        <td><textarea name="pdescription" class="desctext" style="width:450px; height:150px; 
                             resize: none; font-size:11px">{$part-description}</textarea>
                         </td>
                    </tr>
                    <tr valign="top"><td style="padding-top:10px;">Reference(s):</td>
                        <td><input id="pref1" name="pref1" type="file" class="inputFile"/>
                            <button type="button" id="addref" class="button" onclick="addElement('pref','input','file',1)">Add</button>
                        </td>
                    </tr>
                    <tr><td colspan="2" style="height:20px;"/></tr>
                    <tr>
                        <td>
                           <span style="font-size:12px;">* required</span>
                        </td>
                        <td align="centre">
                            <input class="button" name= "submitPart" type="submit" value="Submit"/>                            
                            <span style="display:inline-block; width:2px"/>
                            <input class="button" name= "cancel" type="button" value="Cancel" 
                                onclick="location.href='{app:link(concat("views/view-spec.xq?id=", $id))}'"/>
                        </td>
                    </tr>
                </table>
             </form>
             <br/><br/><br/>
             </div>
                <div class="footer">{app:footer()}</div>
           	</div>
       </body>
</html>