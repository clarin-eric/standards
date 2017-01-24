xquery version "3.0";

declare namespace request="http://exist-db.org/xquery/request";
declare namespace exist="http://exist.sourceforge.net/NS/exist"; 
declare option exist:serialize "method=xhtml media-type=application/xhtml+xml indent=yes doctype-system=about:legacy-compat";

import module namespace menu = "http://clarin.ids-mannheim.de/standards/menu" at "../modules/menu.xql";
import module namespace app = "http://clarin.ids-mannheim.de/standards/app" at "../modules/app.xql";
import module namespace login = "http://clarin.ids-mannheim.de/standards/login" at "../modules/login.xql";

let $submitted := request:get-data()
let $email := $submitted/login/email/text()
let $password := $submitted/login/password/text()
let $authorized := login:authorize($submitted, $email, $password)

return

if (session:get-attribute("user")) 
    then response:redirect-to(app:link("index.xq"))
else if ($submitted and $authorized)
    then $password
else

<html xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xf="http://www.w3.org/2002/xforms" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:ev="http://www.w3.org/2001/xml-events" >
   <head>
        <title>Login</title>
        <link rel="stylesheet" type="text/css" href="{app:resource("style.css","css")}"/>
        <xf:model>           
           <xf:instance xmlns="">
                <login>
                   <email/>
                   <password/>
                </login>
            </xf:instance>
           
           <xf:bind nodeset="email" type="xf:email" required="true()"/>
           <xf:bind nodeset="password" required="true()"/>
           <xf:submission id="submit" method="post" action="login.xq" replace="all">
            
           </xf:submission>
       </xf:model>
    </head>
    <body>
        <div id="all">
            <div class="logoheader"/>
            {menu:view()}
            <div class="content">            
                <div class="navigation">&gt; <a href="{app:link("user/login.xq")}">Login</a></div>
                <xf:fieldset style="border:1px;">
                    <xf:group>
                        
                        <xf:input ref="email">
                            <xf:label>E-Mail: </xf:label>
                            <xf:alert>Please insert an E-Mail!</xf:alert>
                        </xf:input>
                        <br />
                        <xf:secret ref="password">
                            <xf:label>Password: </xf:label>
                            <xf:alert>Please insert a Password!</xf:alert>
                        </xf:secret>
                
                    </xf:group>
                    <br />
                    <xf:submit submission="submit">
                       <xf:label>Login</xf:label>
                   </xf:submit>
               </xf:fieldset>
            </div>
            <div class="footer">{app:footer()}</div>
        </div>
    </body>
</html>