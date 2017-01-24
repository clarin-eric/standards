xquery version "3.0";

declare namespace request="http://exist-db.org/xquery/request";
declare namespace exist="http://exist.sourceforge.net/NS/exist";
declare option exist:serialize "method=xhtml media-type=text/html indent=yes doctype-system=about:legacy-compat";

import module namespace menu = "http://clarin.ids-mannheim.de/standards/menu" at "../modules/menu.xql";
import module namespace app = "http://clarin.ids-mannheim.de/standards/app" at "../modules/app.xql";
import module namespace login = "http://clarin.ids-mannheim.de/standards/login" at "../modules/login.xql";


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
                <form action="{app:secure-link("user/login.xq")}" method="post">
                    <table style="font-size:14px; font-family:arial,verdana,sans-serif; border:1px solid #AAAAAA; padding:20px;">              
                        {if ($submitted and not($email))
                        then (
                        <tr>
                            <td><b>E-Mail:</b></td>
                            <td><input name="email" type="text" value="{$email}" class="inputTextError" style="width:250px;" /></td>
                        </tr>,
                        <tr>
                            <td></td>
                            <td><span class="error" >Please insert an E-Mail!</span></td>
                        </tr>
                        )                      
                        else
                        <tr>
                            <td><b>E-Mail:</b></td>
                            <td><input name="email" type="text" value="{$email}" class="inputText" style="width:250px;" /></td>
                        </tr>
                        }                       
                        
                        {if ($submitted and not($password))
                        then (
                            <tr>
                                <td><b>Password:</b></td>
                                <td><input name="pass" type="password" size="22" class="inputTextError" style="width:250px;"/></td>
                            </tr>,
                            <tr>
                                <td style="color:white; cursor:default;" ></td>
                                <td ><span style="color:red; font-size:13px;">Please insert a password.</span></td>
                            </tr>                        
                        )
                        else
                            <tr>
                                <td><b>Password:</b></td>
                                <td><input name="pass" type="password" class="inputText" style="width:250px;"/></td>
                            </tr>
                        }                        
                        {if ($submitted and $email and $password and not($authorized))                       
                        then
                            <tr>
                                <td style="color:white; cursor:default;" ></td>
                                <td><span style="color:red; font-size:13px;">E-Mail or password is incorrect.</span>
                                </td>
                            </tr>
                        else()
                        }                        
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