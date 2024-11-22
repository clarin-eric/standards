xquery version "3.1";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "html";
declare option output:media-type "text/html";
declare option output:indent "yes";
declare option output:html-version "5";

import module namespace menu = "http://clarin.ids-mannheim.de/standards/menu" at "../modules/menu.xql";
import module namespace app = "http://clarin.ids-mannheim.de/standards/app" at "../modules/app.xql";
import module namespace register = "http://clarin.ids-mannheim.de/standards/register-user" at "../modules/register.xql";

(: Define the registration form
   @author margaretha
:)

let $submitted :=  request:get-parameter('submit', '')
let $name :=  request:get-parameter('name', '')
let $affliation := request:get-parameter('affliation', '')
let $email := request:get-parameter('email', '')
let $password := request:get-parameter('password', '')
let $recaptcha-response := request:get-parameter('g-recaptcha-response', '')

let $validEmail := register:validate-email($submitted,$email)
let $validUser := register:validate-user($submitted,$recaptcha-response)
let $register := register:validate($submitted,$validEmail,$validUser,$name,$affliation,$email,$password)
     
return

    <html>
        <head>
    		<title>User Registration</title>
    		<link rel="stylesheet" type="text/css" href="{app:resource("style.css","css")}"/>
    		<script type="text/javascript" src="https://www.google.com/recaptcha/api.js"/>
    	</head>
    	<body>    	
    		<div id="all">
    			<div class="logoheader"/>	
    			{menu:view()}
    			<div class="content">
    			   <div class="navigation">&gt; <a href="register.xq">Registration</a></div>
             		<div><span class="title">User Registration</span></div>
             		<div style="margin-bottom:20px;">
             		    <p> By registering to our website, you will have the privilege to download standard resources. 
              		        You can also participate in extending our <a href="{app:link("views/list-specs.xq?sortBy=name&amp;page=1")}">list of standards</a> 
              		        by submitting your own standard descriptions.</p> 
              		    <p> Please fill in and submit the registration form below. As we respect your 
             		        privacy, we do not share your personal data to other parties.</p>
             		</div>
    			    
    			    <form id="registration" method="post" action="">
                        <table style="border:1px solid #AAAAAA; padding:25px;">                            
                            <tr>
                                <td style="width:100px"><b>Name:</b>*</td>
                                <td><input name="name" type="text" value="{$name}" class="{app:get-input-class($submitted,$name)}" /></td>
                            </tr>
                            <tr style="display:{register:get-error-display($submitted,$name)}">
                                <td></td>
                                <td><span class="error">Please provide a name!</span></td>
                            </tr>
                            <tr>
                                <td>
                                    <b>Affiliation:</b>
                                </td>
                                <td>
                                    <input name="affliation" type="text" value="{$affliation}" class="inputText" />
                                </td>
                            </tr>
                            <tr>
                                <td><b>E-Mail:</b>*</td>
                                <td><input name="email" type="text" value="{$email}" class="{app:get-input-class($submitted,$validEmail)}" /></td>
                            </tr>
                            <!--tr style="display:{register:get-error-display($submitted,$email)}">
                                <td></td>
                                <td><span class="error">Please provide an E-Mail!</span></td>
                            </tr-->                                                    
                            <tr style="display:{register:get-error-display($submitted,$validEmail)}">
                                <td></td>
                                <td><span class="error">Please enter a valid E-Mail address!</span></td>
                            </tr>
                            <tr>
                            <td><b>Password:</b>*</td>         
                                <td><input name="password" type="password" value="" class="{app:get-input-class($submitted,$password)}" /></td>
                            </tr>
                            <tr style="display:{register:get-error-display($submitted,$password)}">
                                <td></td>
                                <td><span class="error">Please enter a password!</span></td>
                            </tr>
                            <tr>   
                                <td></td>
                                <td><span class="g-recaptcha" data-sitekey="{register:get-recaptcha-site-key()}"/></td>
                            </tr>
                            <tr style="height:40px;">
                                <td>
                                    <span style="font-size:12px;">* required</span>
                                </td>
                                <td align="centre">
                                    <input class="button" name= "submit" type="submit" value="Submit"/>                                    
                                </td>
                            </tr>
                        </table>
                    </form>
                     
          	    </div>                 
                <div class="footer">{app:footer()}</div>               
    		</div>
    	</body>
    </html>