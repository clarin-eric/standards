xquery version "3.1";

import module namespace xsd = "http://clarin.ids-mannheim.de/standards/schema" at "../model/schema.xqm";

import module namespace menu = "http://clarin.ids-mannheim.de/standards/menu" at "../modules/menu.xql";
import module namespace app = "http://clarin.ids-mannheim.de/standards/app" at "../modules/app.xql";
import module namespace asm ="http://clarin.ids-mannheim.de/standards/add-spec-module" at "../modules/add-spec.xql";
import module namespace rsm ="http://clarin.ids-mannheim.de/standards/register-spec-module" at "../modules/register-spec.xql";
import module namespace sbm="http://clarin.ids-mannheim.de/standards/sb-module" at "../modules/sb.xql";

import module namespace f = "http://clarin.ids-mannheim.de/standards/module/form" at "../edit/edit-form.xq";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "html";
declare option output:media-type "text/html";
declare option output:indent "yes";
declare option output:html-version "5";

(: Define the registering standard version page
   @author margaretha
:)

let $id := request:get-parameter('id', '')

let $submitted := request:get-parameter("submitVersion","")

let $version-id := request:get-parameter("vid","")
let $version-resp := request:get-parameter("vresp","")
let $version-resptype := request:get-parameter("vresptype","")
let $version-respname := request:get-parameter("vrespname","")
let $version-resporg := request:get-parameter("vresporg","")
let $version-date := request:get-parameter("vdate","")

let $param-names := request:get-parameter-names()
let $version-relation := f:get-param-names($param-names,"vrelation")
let $version-target := f:get-param-names($param-names,"vtarget")    
let $version-reldesc := f:get-param-names($param-names,"vreldesc")
let $num := fn:max((1,count($version-relation),count($version-target),count($version-reldesc)))

let $version-relation := f:get-parameters($param-names,"vrelation",$num)
let $version-target := f:get-parameters($param-names,"vtarget",$num)
let $version-reldesc := f:get-parameters($param-names,"vreldesc",$num)

let $valid-vid := rsm:validate-id($version-id)
let $validation := asm:validate-version($submitted,$param-names,$id,$version-id,$valid-vid,
    $version-resp,$version-respname,$version-resptype,$version-resporg,
    $version-date,$version-relation,$version-target,$version-reldesc,$num)

let $version-parent := request:get-parameter("vparent","")
let $version-name := request:get-parameter("vname","")
let $version-abbr := request:get-parameter("vabbr","")
let $version-nomajor := request:get-parameter("vnomajor","")
let $version-nominor := request:get-parameter("vnominor","")
let $version-status := request:get-parameter("vstatus","")
let $version-description := request:get-parameter("vdescription","")
let $version-features := request:get-parameter("vfeatures","")

let $spec := asm:get-spec($id)
let $spec-name := asm:get-spec-name($spec)

let $submitted-version := request:get-parameter("versionid","")

return

<html lang="en">
    <head>
        <title>Registering Standard Parts</title>       
        <link rel="icon" type="image/x-icon" href="{app:favicon()}"/>
        <link rel="stylesheet" type="text/css" href="{app:resource("style.css","css")}"/>
        <link rel="stylesheet" href="//ajax.googleapis.com/ajax/libs/dojo/1.9.1/dijit/themes/claro/claro.css" media="screen"/>        
        <script type="text/javascript" src="{app:resource("edit.js","js")}"/>        
        <script type="text/javascript" src="//ajax.googleapis.com/ajax/libs/dojo/1.9.1/dojo/dojo.js"
        data-dojo-config="async: true, parseOnLoad: true"/>
        <script>require(["dojo/parser", "dijit/form/ComboBox"]);</script>
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
                &gt; <a href="{app:link("views/register-spec.xq")}">Register</a>
                &gt; Adding Parts
                &gt; Adding Versions
             </div>                    
             
             <div class="title">Registering Standard</div>
             <div>
                {if (session:get-attribute("user") = 'webadmin')
                 then <p>You can register a standard to our collection by following the registration steps below. Your given 
                information will be stored after submission in each step. Please keep in mind that you cannot go back 
                to a previous step. After submission, your standard will be place in <b>/data/specifications</b> folder.</p>
                 else 
                <p>You can register a standard to our collection by following the registration steps below. Your given 
                information will be stored after submission in each step. Please keep in mind that you cannot go back 
                to a previous step. After submission, your standard will be reviewed by an administrator. Once it has 
                been approved, it will be listed in the 
                <a href="{app:link("views/list-spec.xq?sortBy=name&amp;page=1")}">Standards</a> page. Your registered 
                standard may be further elaborated by the administrator.</p>
                }
                <br />
                {if ($submitted-version) 
                 then <p style="font-size: 14px; font-weight:bold; color:orange;">Version {$submitted-version} has been
                 sucessfully submitted. </p> 
                 else ()}
                
                <p style="font-size:14px;"><span style="font-weight:bold">Adding Standard information > Adding Parts > 
                </span> <span style="text-decoration:underline; font-weight:bold"> Adding Versions</span> 
                <span style="color:#AAA;"> > Confirmation </span></p>               
                
                <p>If {$spec-name} doesn't have any version, you may skip this step and click the "Done" button. </p>
                
                <p>To add a version, please fill in the form below. A version may belong to a standard or 
                a standard part. By default, {$spec-name} is set as the parent. You can change the default parent 
                by selecting a standard part. The new version will be added to the selected parent following any 
                other existing versions in it. </p>
                
                <p> You may add more than one version into the same parent. When you are done, 
                please click the "Done" button.</p>
                
                </div>
             
             <form method="post" enctype="multipart/form-data" action="">               
                <table style="padding:20px; margin-top:20px; border:1px solid #DDDDDD;">
                     <tr><td>Parent:* </td>
                         <td><select name="vparent" class="inputSelect" style="width:455px; margin-right:3px;">                                
                                <option value="{$id}">{$spec-name}</option>
                                {asm:get-part-options($spec,$version-parent)}
                             </select>
                         </td>
                     </tr>
                     <tr><td style="width:100px">Id:*</td>
                         <td><input name="vid" value="{$version-id}" type="text" style="width:450px;" 
                                class="{rsm:get-id-class($submitted,$version-id,$valid-vid)}"/>
                         </td>
                     </tr>   
                     <tr style="display:{rsm:get-display-error($version-id,$valid-vid)}">
                        <td></td>
                        <td><span style="color:red;">* Id is not available.</span></td>
                     </tr>
                     <tr><td>Title:</td>
                          <td><input name="vname" value="{$version-name}" type="text" class="inputText" style="width:450px;"/></td>
                     </tr>
                     <tr><td>Abbreviation:</td>
                         <td><input name="vabbr" value="{$version-abbr}" type="text" class="inputText" 
                            style="width:{asm:get-width()};"/>
                            <select name="internal" class="inputSelect" style="margin-left:3px; width:100px;
                                display:{app:get-display()}">
                                <option value="yes">internal</option>,
                                <option selected='selected' value="no">official</option>
                            </select>
                        </td>
                     </tr>
                     <tr><td>Version number:</td>
                         <td><input name="vnomajor" value="{$version-nomajor}" type="text" 
                            class="inputText" style="width:220px;" placeholder="Major"/>
                         <input name="vnominor" value="{$version-nominor}" type="text" 
                            class="inputText" style="margin-left:3px; width:220px;" placeholder="Minor"/></td>
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
                             <select id="resptype" name="vresptype" class="{asm:get-select-class($version-resptype,$version-resp,$version-respname)}" 
                                style="width:81px; margin-right:3px;" onchange="showResp('resptype','resporg','respname')">
                                <option value=""/>
                                 {f:list-options(xsd:get-resptype(),$version-resptype)}                
                             </select>
                             <span id="resporg" style="display:{asm:get-display('org',$version-resptype,'inline')};
                                padding:2px 2px 2px 2px;"
                                class="{asm:get-input-class($version-respname,$version-resp,$version-resptype)}" >
                                
                                <select data-dojo-type="dijit/form/ComboBox"  name="vresporg" class="inputSelect" 
                                   style="background: url(../resources/images/arrow.png) no-repeat right;
                                   width:280px;font-size:13px;border:none;padding:2px 2px 3px 0px;" 
                                   placeholder="Select a standard body or type a new one ">
                                   <option value=""/>
                                   {sbm:list-sbs-options($version-resporg)}
                                </select>
                             </span>
                             <input id="respname" name="vrespname" class="{asm:get-input-class($version-respname,$version-resp,$version-resptype)}"                             
                                 value="{$version-respname}" type="text" style="width:280px;display:{asm:get-display('person',$version-resptype,'inline')}" 
                                 placeholder="For multiple names, use a comma."/>
                         </td>
                     </tr>
                     <tr><td>Date:*</td>
                         <td>
                            <input name="vdate" value="{$version-date}" placeholder="YYYY-MM-DD" type="text" 
                            class="{asm:get-date-class($submitted,$version-date)}" style="width:450px;"/>
                         </td>
                     </tr>
                     <tr valign="top"><td>Description:</td>
                         <td><textarea name="vdescription" class="desctext" style="width:450px; height:150px; 
                              resize: none; font-size:11px">{$version-description}</textarea>
                          </td>
                     </tr>
                     <tr valign="top"><td style="padding-top:10px;" >Reference(s):</td>
                         <td><input id="vref1" name="vref1" type="file" class="inputFile"/>
                             <button type="button" id="addref" class="button" onclick="addElement('vref','input','file',1)">Add</button>
                         </td>
                     </tr>
                     <!--tr><td valign="top">Features:</td>
                         <td><textarea name="vfeatures" class="inputText" style="width:450px; height:150px; resize: none; font-size:11px;"
                             placeholder="Describe features using tags as defined in the spec.xsd.">{$version-features}</textarea></td>
                     </tr-->                                      
                     {asm:get-urls($param-names)}      
                     {asm:get-relations($param-names)}
                     <tr>
                         <td>* required</td>
                         <td></td>
                     </tr>
                     <tr>
                         <td></td>
                         <td>
                            <button type="reset" name="cancelButton" class="button" style="margin-top:30px;margin-bottom:3px;" 
                             onclick="'">Reset</button>
                            <input type="submit" name="submitVersion" class="button" style="margin-bottom:3px;" value="Add Version"/>
                            <span style="display:inline-block; width:2px"/>
                         </td>
                      </tr>
                </table>
                <div align="middle">
                    
               </div>
               <div align="right">
               <input name = "next" class="button" type="button" value="Done" 
                        onclick="location.href='{app:link(concat("views/register-confirmation.xq?id=",$id))}'"/>                            
                   <span style="display:inline-block; width:2px"/>
               </div>
             </form>
                  <br/><br/><br/>
        </div>
            <div class="footer">{app:footer()}</div>
        </div>
        
    </body>
</html>                        
   