xquery version "3.0";

declare namespace exist="http://exist.sourceforge.net/NS/exist";
declare option exist:serialize "method=xhtml media-type=text/html indent=yes doctype-system=about:legacy-compat";

import module namespace app = "http://clarin.ids-mannheim.de/standards/app" at "../modules/app.xql";
import module namespace menu = "http://clarin.ids-mannheim.de/standards/menu" at "../modules/menu.xql";
import module namespace vsm ="http://clarin.ids-mannheim.de/standards/view-spec" at "../modules/view-spec.xql";
import module namespace asm ="http://clarin.ids-mannheim.de/standards/add-spec-module" at "../modules/add-spec.xql";

let $id := request:get-parameter('id', '')
let $spec := asm:get-spec($id)
let $spec-name := $spec/titleStmt/title/text()

let $submitted := request:get-parameter("submitPart","")
let $part-id := request:get-parameter("pid","")
let $part-name := request:get-parameter("pname","")
let $part-abbr := request:get-parameter("pabbr","")
let $part-scope := request:get-parameter("pscope","")
let $part-keyword := request:get-parameter("pkeyword","")
let $part-description := request:get-parameter("pdescription","")

let $validation := 
    if ($submitted and $part-id) 
    then asm:store-part($spec,$part-id,$part-name,$part-abbr,$part-scope,$part-keyword,$part-description)
    else () 

let $submitted-part := request:get-parameter("partid","")

return

<html>
    <head>
       <title>Registering Standard Parts</title>       
        <link rel="stylesheet" type="text/css" href="{app:resource("style.css","css")}"/>
        <script type="text/javascript" src="{app:resource("edit.js","js")}"/>
    </head>   
    <body>
        <div id="all">
        <div class="logoheader"/>		
             {menu:view()}
        <div class="content">
             <div class="navigation">
                &gt; <a href="{app:link("views/list-specs.xq?sortBy=name&amp;page=1")}">Standards</a>               
                &gt; <a href="{app:link("views/register-spec.xq")}">Register</a>
                &gt; Adding Parts
             </div>                    
             
             <div class="title">Registering Standard</div>
             <div>
                <p>You can register a standard to our collection by following the registration steps below. Your given 
                information will be stored after submission on each step. Please keep in mind that you cannot go back 
                to a previous step. After submission, your standard will be reviewed by an administrator. Once it has 
                been approved, it will be listed in the 
                <a href="{app:link("views/list-spec.xq?sortBy=name&amp;page=1")}">Standards</a> page. Your registered 
                standard may be further elaborated by the administrator.</p> 
                
                <br />
                {if ($submitted-part) 
                 then <p style="font-size: 14px; font-weight:bold; color:orange;">Part {$submitted-part} has been 
                 sucessfully submitted. </p> 
                 else ()}
                
                <p style="font-size:14px;"><span style="font-weight:bold">Adding Standard information</span> 
                > <span style="text-decoration:underline; font-weight:bold"> Adding Parts </span>
                <span style="color:#AAA;"> > Adding Versions > Confirmation </span></p>               
                

                <p>To add a part to {$spec-name}, please fill in and <b>submit</b> the form below. A new part will be added to 
                the {$spec-name} following any other existing parts. A part that does not have a version will not be shown 
                in the standard description. You can add a version for a part or the standard itself in the next step.</p>                          
                
                <p> You can add multiple parts, if you like. When you are done, please click the "Next" button. </p>
                   
             </div>      
             
             <form method="post" action="" enctype="multipart/form-data" >
                <table style="padding:20px; margin-top:20px;">
                    <tr>
                        <td style="width:100px">Id:*</td>
                        <td><input name="pid" type="text" value="{$part-id}" class="{asm:get-id-class($submitted,$part-id)}" style="width:450px;"/></td>
                    </tr>
                    <tr><td style="width:100px">Title:</td>
                         <td><input name="pname" value="{$part-name}" type="text" class="inputText" style="width:450px;"/></td>
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
                        <td><textarea name="pdescription" class="inputText" style="width:450px; height:150px; 
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
                        <td align="center">
                            <input class="button" name= "submitPart" type="submit" value="Submit"/>                            
                            <span style="display:inline-block; width:2px"/>
                            <input name = "next" class="button" type="button" value="Next" 
                                onclick="location.href='{app:link(concat("views/register-version.xq?id=", $id))}'"/>                            
                            <span style="display:inline-block; width:2px"/>                            
                            <input class="button" name= "cancel" type="button" value="Cancel" onclick=""/>
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