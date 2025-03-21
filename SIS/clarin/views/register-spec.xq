xquery version "3.1";

import module namespace menu = "http://clarin.ids-mannheim.de/standards/menu" at "../modules/menu.xql";
import module namespace app = "http://clarin.ids-mannheim.de/standards/app" at "../modules/app.xql";
import module namespace tm ="http://clarin.ids-mannheim.de/standards/topic-module"  at "../modules/topic.xql";
import module namespace sbm="http://clarin.ids-mannheim.de/standards/sb-module" at "../modules/sb.xql";
import module namespace rsm ="http://clarin.ids-mannheim.de/standards/register-spec-module" at "../modules/register-spec.xql";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "html";
declare option output:media-type "text/html";
declare option output:indent "yes";
declare option output:html-version "5";

(: Define the registering standard page 
   @author margaretha
:)

let $submitted := request:get-parameter('submitSpec',"")
let $id := request:get-parameter('id', '')
let $name := request:get-parameter('name', '')
let $scope := request:get-parameter('scope', '')
let $description := request:get-parameter('description', '')
let $standard-setting-body := request:get-parameter('ssb', '')
let $topicRef :=  request:get-parameter('topic', '')

let $validate-id := rsm:validate-id($id)
let $validation := rsm:validate-spec($submitted,$validate-id,$id,$name,$scope,$topicRef,
    $description,$standard-setting-body)

let $abbr := request:get-parameter('abbr', '')
let $keyword := request:get-parameter('keyword', '')

return
    
    <html lang="en">
    <head>
        <title>Registering Standard</title>      
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
                &gt; <a href="{app:link("views/list-spec.xq?sortBy=name&amp;page=1")}">Standards</a>
                &gt; <a href="{app:link("views/register-spec.xq")}">Register</a>
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
                <p style="font-size:14px;"><span style="text-decoration:underline; font-weight:bold">Adding Standard information</span> 
                 <span style="color:#AAA;" > > Adding Parts > Adding Versions > Confirmation </span></p>

                <p>As the first standard registration step, please fill in the form below and click the submit button. The name, the topic 
                and the description of the standard are obligatory. Please also specify the standard body which has 
                standardized the standard. </p>                
                
            </div>            
            
            <form id="addForm" method="post" action="">                
                <table id="text" style="padding:20px;">
                    <tr><td style="width:180px">Id:*</td>
                         <td><input name="id" value="{$id}" type="text" style="width:400px;" 
                                class="{rsm:get-id-class($submitted,$id,$validate-id)}"
                                placeholder="Only alphanumeric . and - characters are allowed."/>                                
                         </td>
                     </tr>
                     <tr style="display:{rsm:get-display-error($id,$validate-id)}">
                        <td></td>
                        <td><span style="color:red;">* Id is not available or contains invalid characters. 
                        Only alphanumeric . and <br/>- characters are allowed.</span></td>
                     </tr>
                    <tr>
                        <td style="width:180px">Name:*</td>
                        <td><input name="name" type="text" class="{rsm:get-input-class($submitted,$name)}" 
                            style="width:400px;" value="{$name}" /></td>                            
                    </tr>
                    <tr>
                        <td>Abbreviation:</td>
                        <td><input name="abbr" type="text" value="{$abbr}" class="inputText" style="width:{rsm:get-width()}"/>                            
                            <select name="internal" class="inputSelect" style="margin-left:3px; width:100px;
                            display:{app:get-display()}">
                                <option value="yes">internal</option>,
                                <option selected='selected' value="no">official</option>
                            </select>
                        </td>
                    </tr>
                    <tr>
                        <td>Scope:*</td>
                        <td><input name="scope" placeholder="Describe the standard purpose, e.g. Corpus annotation." 
                            type="text" value="{$scope}" class="{rsm:get-input-class($submitted,$scope)}" style="width:400px;"/></td>
                    </tr>
                    <tr>
                       <td>Topic:*</td>
                       <td><select name="topic" class="{rsm:get-select-class($submitted,$topicRef)}">
                           <option value=""/>
                           {tm:list-topic-options($topicRef)}
                           </select>
                       </td>
                   </tr>
                   <tr valign="top">
                       <td>Description:*</td>                             
                       <td><textarea name="description" class="desctext" 
                            style="width:400px; height:200px; resize: none; font-size:11px; border:1px solid red;">{$description}</textarea>
                       </td>
                   </tr>
                   <tr style="display:{rsm:get-display-error($submitted,$description)}">
                        <td></td>
                        <td><span style="color:red;">* Please add some description about the specification.</span></td>
                     </tr>
                   <tr>
                        <td>Keyword(s):</td>
                        <td>
                            <input name="keyword" type="text" value="{$keyword}" class="inputText" style="width:400px;"
                            placeholder="Multiple keywords are separated with a comma, e.g. SGML, XCES." />
                        </td>
                   </tr>
                   <tr>
                        <td>Standard body:*</td>
                        <td><select name="ssb" class="{rsm:get-select-class($submitted,$standard-setting-body)}">
                                <option value=""/>
                                {sbm:list-sbs-options($standard-setting-body)}                                    
                            </select>                           
                        </td>
                   </tr>
                   <tr style="height:20px;"><td colspan="2"/></tr>
                   <tr>
                        <td colspan="2">
                            <span style="font-size:12px;">* required</span>
                        </td>
                    </tr>
                    <tr>
                        <td></td>
                        <td style="text-align:left;">
                            <!--<input class="button" name= "cancel" type="reset" value="Cancel" />-->
                            <input name = "submitSpec" class="button" style="margin-top:20px;" type="submit" value="Submit"/>
                            <span style="display:inline-block; width:2px"/>
                        </td>
                    </tr>
                </table>
            </form>
            <br /><br /><br />                 
            
        </div>
            <div class="footer">{app:footer()}</div>
        </div>
   </body>
</html>                        
   