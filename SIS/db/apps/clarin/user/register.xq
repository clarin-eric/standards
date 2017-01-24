xquery version "3.0";

declare namespace request="http://exist-db.org/xquery/request";
declare namespace exist="http://exist.sourceforge.net/NS/exist";
declare option exist:serialize "method=xhtml media-type=text/html indent=yes doctype-system=about:legacy-compat";

import module namespace menu = "http://clarin.ids-mannheim.de/standards/menu" at "../modules/menu.xql";
import module namespace app = "http://clarin.ids-mannheim.de/standards/app" at "../modules/app.xql";
import module namespace login = "http://clarin.ids-mannheim.de/standards/login" at "../modules/login.xql";

let $submitted :=  request:get-parameter('submit', '')
let $name :=  request:get-parameter('name', '')
let $affliation := request:get-parameter('affliation', '')
let $email := request:get-parameter('email', '')
let $password := request:get-parameter('password', '')

let $validEmail := if ($submitted) then login:validate-email($email) else ''

return

if ($submitted and $name and $validEmail and $password) 
then login:register($name,$affliation,$email,$password)
else
    <html>
        <head>
    		<title>User Registration</title>
    		<link rel="stylesheet" type="text/css" href="{app:resource("style.css","css")}"/>    			
    	</head>
    	<body>
    		<div id="all">
    			<div class="logoheader"/>	
    			{menu:view()}
    			<div class="content">
    			   <div class="navigation">&gt; <a href="registration.xq">Registration</a></div>
             		<div><span class="heading">User Registration</span></div>
             		<div style="margin-bottom:20px;">
             		    <p> By registering to our website, you will have the privilege to download standard resources. 
              		        You can also participate in extending our <a href="{app:link("views/list-specs.xq?sortBy=name&amp;page=1")}">list of standards</a> 
              		        by submitting your own standard descriptions.</p> 
              		    <p> Please fill in and submit the registration form below. As we respect your 
             		        privacy, we do not share your personal data to other parties.</p>
             		</div>
    			    
    			    <form id="registration" method="post" action="">
                        <table style="border:1px solid #AAAAAA; padding:25px;"> 
                            {if ($submitted and not($name))
                                then (
                                <tr>
                                    <td style="width:100px"><b>Name:</b>*</td>
                                    <td><input name="name" type="text" value="{$name}" class="inputTextError" /></td>
                                </tr>,
                                <tr>
                                    <td></td>
                                    <td><span class="error">Please provide a name!</span></td>
                                </tr>)
                                    else(
                                    <tr>
                                    <td style="width:100px"><b>Name:</b>*</td>
                                        <td><input name="name" type="text" value="{$name}" class="inputText" /></td>
                                    </tr>
                                )
                             }                           
                            
                            <tr>
                                <td>
                                    <b>Affiliation:</b>
                                </td>
                                <td>
                                    <input name="affliation" type="text" value="{$affliation}" class="inputText" />
                                </td>
                            </tr>                   
                                
                            {if ($submitted and not($email))
                                then (
                                <tr>
                                    <td><b>E-Mail:</b>*</td>
                                    <td><input name="email" type="text" value="{$email}" class="inputTextError" /></td>
                                </tr>,
                                <tr>
                                    <td></td>
                                    <td><span class="error">Please provide an email!</span></td>
                                </tr>
                                )
                             else if ($submitted and not($validEmail))
                                then (
                                <tr>
                                   <td><b>E-Mail:</b>*</td>
                                   <td><input name="email" type="text" value="{$email}" class="inputTextError" /></td>
                               </tr>,                               
                               <tr>
                                    <td></td>
                                    <td><span class="error">Please enter a valid E-Mail address!</span></td>
                                </tr>
                               )
                            else
                            <tr>
                                <td><b>E-Mail:</b>*</td>
                                <td><input name="email" type="text" value="{$email}" class="inputText" /></td>
                            </tr>
                             }                          
                            {if ($submitted and (not($password) or fn:string-length($password) < 6))
                               then (
                               <tr>
                                <td><b>Password:</b>*</td>         
                                    <td><input name="password" type="password" value="" class="inputTextError" /></td>
                                </tr>,
                                <tr>
                                    <td></td>
                                    <td><span class="error">Please enter a password with minimum 6 characters!</span></td>
                                </tr>
                                )                                
                             else 
                             <tr>
                                <td><b>Password:</b>*</td>         
                                <td><input name="password" type="password" value="" class="inputText" 
                                placeholder="Minimum 6 characters."
                                /></td>
                            </tr>
                            }
                            <tr style="height:40px;">
                                <td>
                                    <span style="font-size:12px;">* required</span>
                                </td>
                                <td align="center">
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