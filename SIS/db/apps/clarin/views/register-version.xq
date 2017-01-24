xquery version "3.0";

declare namespace exist="http://exist.sourceforge.net/NS/exist";
declare option exist:serialize "method=xhtml media-type=text/html indent=yes doctype-system=about:legacy-compat";

import module namespace xsd = "http://clarin.ids-mannheim.de/standards/schema" at "../model/schema.xqm";

import module namespace menu = "http://clarin.ids-mannheim.de/standards/menu" at "../modules/menu.xql";
import module namespace app = "http://clarin.ids-mannheim.de/standards/app" at "../modules/app.xql";
import module namespace asm ="http://clarin.ids-mannheim.de/standards/add-spec-module" at "../modules/add-spec.xql";

import module namespace f = "http://clarin.ids-mannheim.de/standards/module/form" at "../edit/edit-form.xq";

let $id := request:get-parameter('id', '')

let $submitted := request:get-parameter("submitVersion","")

let $version-id := request:get-parameter("vid","")
let $version-resp := request:get-parameter("vresp","")
let $version-resptype := request:get-parameter("vresptype","")
let $version-respname := request:get-parameter("vrespname","")
let $version-date := request:get-parameter("vdate","")

let $param-names := request:get-parameter-names()
let $version-relation := f:get-param-names($param-names,"vrelation")
let $version-target := f:get-param-names($param-names,"vtarget")    
let $version-reldesc := f:get-param-names($param-names,"vreldesc")
let $num := fn:max((1,count($version-relation),count($version-target),count($version-reldesc)))

let $version-relation := f:get-parameters($param-names,"vrelation",$num)
let $version-target := f:get-parameters($param-names,"vtarget",$num)
let $version-reldesc := f:get-parameters($param-names,"vreldesc",$num)

let $validation := if ($submitted) then asm:validate($param-names,$id,$version-id,$version-date,$version-resp,$version-respname,$version-resptype,
    $version-relation,$version-target,$version-reldesc,$num) else ()

let $version-parent := request:get-parameter("vparent","")
let $version-name := request:get-parameter("vname","")
let $version-abbr := request:get-parameter("vabbr","")
let $version-nomajor := request:get-parameter("vnomajor","")
let $version-nominor := request:get-parameter("vnominor","")
let $version-status := request:get-parameter("vstatus","")
let $version-description := request:get-parameter("vdescription","")
let $version-features := request:get-parameter("vfeatures","")

let $spec := asm:get-spec($id)
let $spec-name := $spec/titleStmt/title/text()

let $submitted-version := request:get-parameter("versionid","")

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
                &gt; Adding Versions
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
                {if ($submitted-version) 
                 then <p style="font-size: 14px; font-weight:bold; color:orange;">Version {$submitted-version} has been
                 sucessfully submitted. </p> 
                 else ()}
                
                <p style="font-size:14px;"><span style="font-weight:bold">Adding Standard information > Adding Parts > 
                </span> <span style="text-decoration:underline; font-weight:bold"> Adding Versions</span> 
                <span style="color:#AAA;"> > Confirmation </span></p>               
                
                <p>Please fill in and submit the form below. A version belongs to a standard or a standard part. 
                By default, {$spec-name} is set as the parent. You can change the default parent by selecting a standard 
                part. The new version will be added to the selected parent following any other existing versions in it.</p>
                </div>
             
             <form method="post" enctype="multipart/form-data" action="">               
                <table style="padding:20px; margin-top:20px;">
                     <tr><td>Parent:* </td>
                         <td><select name="vparent" class="inputSelect" style="width:455px; margin-right:3px;">                                
                                <option value="{$id}">{$spec-name}</option>
                                {asm:get-part-options($spec,$version-parent)}
                             </select>
                         </td>
                     </tr>
                     <tr><td style="width:100px">Id:*</td>
                         <td><input name="vid" value="{$version-id}" type="text" style="width:450px;" 
                                class="{asm:get-id-class($submitted,$version-id)}" placeholder="Id starts with 'Spec' "/>
                         </td>
                     </tr>                            
                     <tr><td>Title:</td>
                          <td><input name="vname" value="{$version-name}" type="text" class="inputText" style="width:450px;"/></td>
                     </tr>
                     <tr><td>Abbreviation:</td>
                         <td><input name="vabbr" value="{$version-abbr}" type="text" class="inputText" style="width:450px;"/></td>
                     </tr>
                     <tr><td>Version number:</td>
                         <td><input name="vnomajor" value="{$version-nomajor}" type="text" class="inputText" style="width:220px;" placeholder="Major"/>
                         <input name="vnominor" value="{$version-nominor}" type="text" class="inputText" style="margin-left:3px; width:220px;" placeholder="Minor"/></td>
                     </tr>
                     <tr><td>Status:</td>
                          <td><select name="vstatus" class="inputSelect" style="width:455px; margin-right:3px;">
                                <option value=""/>
                                {f:list-options(xsd:get-statuses(),$version-status)}
                             </select>
                         </td>
                     </tr>
                     <tr><td>Resp. Stmt:</td>
                         <td><select name="vresp" class="{asm:get-select-class($version-resp, $version-respname, $version-resptype)}" 
                                style="width:81px; margin-right:3px;">
                                 <option value=""/>
                                 {f:list-options(xsd:get-resp(),$version-resp)}                
                             </select>
                             <select name="vresptype" class="{asm:get-select-class($version-resptype,$version-resp,$version-respname)}" 
                                style="width:81px; margin-right:3px;">
                                 <option value=""/>
                                 {f:list-options(xsd:get-resptype(),$version-resptype)}                
                             </select>
                             <input name="vrespname" class="{asm:get-input-class($version-respname,$version-resp,$version-resptype)}" 
                                 value="{$version-respname}" type="text" style="width:280px;" placeholder="For multiple names, use a comma."/>
                         </td>
                     </tr>
                     <tr><td>Date:</td>
                         <td>
                            <input name="vdate" value="{$version-date}" placeholder="YYYY-MM-DD" type="text" class="{asm:get-date-class($version-status)}" style="width:450px;"/>
                         </td>
                     </tr>
                     <tr valign="top"><td>Description:</td>
                         <td><textarea name="vdescription" class="inputText" style="width:450px; height:150px; 
                              resize: none; font-size:11px">{$version-description}</textarea>
                          </td>
                     </tr>
                     <tr valign="top"><td style="padding-top:10px;" >Reference(s):</td>
                         <td><input id="vref1" name="vref1" type="file" class="inputFile"/>
                             <button type="button" id="addref" class="button" onclick="addElement('vref','input','file',1)">Add</button>
                         </td>
                     </tr>
                     <tr><td valign="top">Features:</td>
                         <td><textarea name="vfeatures" class="inputText" style="width:450px; height:150px; resize: none; font-size:11px;"
                             placeholder="Describe features using tags as defined in the spec.xsd.">{$version-features}</textarea></td>
                     </tr>                                      
                     {asm:get-urls($param-names)}      
                     {asm:get-relations($param-names)}
                     <tr>
                         <td>* required</td>
                         <td></td>
                      </tr>
                </table>
                <div align="middle">
                   <input type="submit" name="submitVersion" class="button" style="margin-bottom:3px;" value="Submit"/>
                   <span style="display:inline-block; width:2px"/>
                   <input name = "next" class="button" type="button" value="Next" 
                        onclick="location.href='{app:link(concat("views/register-confirmation.xq?id=",$id))}'"/>                            
                   <span style="display:inline-block; width:2px"/>
                   <button type="reset" name="cancelButton" class="button" style="margin-bottom:3px;" 
                    onclick="'">Cancel</button>
               </div>
             </form>
                  <br/><br/><br/>
        </div>
            <div class="footer">{app:footer()}</div>
        </div>
    </body>
</html>                        
   