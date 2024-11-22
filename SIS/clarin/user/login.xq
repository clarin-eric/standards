xquery version "3.1";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "html";
declare option output:media-type "text/html";
declare option output:indent "yes";
declare option output:html-version "5";

import module namespace menu = "http://clarin.ids-mannheim.de/standards/menu" at "../modules/menu.xql";
import module namespace app = "http://clarin.ids-mannheim.de/standards/app" at "../modules/app.xql";
import module namespace login = "http://clarin.ids-mannheim.de/standards/login" at "../modules/login.xql";
import module namespace register = "http://clarin.ids-mannheim.de/standards/register-user" at "../modules/register.xql";

(: Define the login page
   @author margaretha
:)

let $submitted := request:get-parameter('submit', '')
let $email := request:get-parameter('email', '')
let $password := request:get-parameter('pass', '')
let $authorized := login:authorize($submitted, $email, $password)

return

<html>    
   <head>
        <title>Login</title>
        <link rel="stylesheet" type="text/css" href="{app:resource("style.css","css")}"/>
    </head>
    <body>
        <div id="all">
            <div class="logoheader"/>
            {menu:view()}
            <div class="content">            
                <div class="navigation">&gt; <a href="{app:link("user/login.xq")}">Login</a></div>
                <form action="{app:link("user/login.xq")}" method="post">
                    <table style="font-size:14px; font-family:arial,verdana,sans-serif; border:1px solid #AAAAAA; padding:20px;">
                        <tr>
                            <td><b>E-Mail:</b></td>
                            <td><input name="email" type="text" value="{$email}" class="{app:get-input-class($submitted,$email)}" style="width:250px;" /></td>
                        </tr>
                        <tr style="display:{register:get-error-display($submitted,$email)}">
                            <td></td>
                            <td><span class="error" >Please insert an E-Mail!</span></td>
                        </tr>
                        <tr>
                            <td><b>Password:</b></td>
                            <td><input name="pass" type="password" size="22" class="{app:get-input-class($submitted,$password)}" style="width:250px;"/></td>
                        </tr>
                        <tr style="display:{register:get-error-display($submitted,$password)}">
                            <td style="color:white; cursor:default;" ></td>
                            <td ><span style="color:red; font-size:13px;">Please insert a password.</span></td>
                        </tr>
                        <tr style="display:{login:get-authorization-error($submitted,$email,$password,$authorized)}">
                            <td style="color:white; cursor:default;" ></td>
                            <td><span style="color:red; font-size:13px;">E-Mail or password is incorrect.</span>
                            </td>
                        </tr>                                              
                        <tr style="color:white; cursor:default; height:40px;">
                            <td></td>
                            <td align="middle"><input name="submit" class="button" type="submit" value="Login"/></td>
                        </tr>                        
                    </table>                      
                </form>
            </div>
            <div class="footer">{app:footer()}</div>
        </div>
    </body>
</html>