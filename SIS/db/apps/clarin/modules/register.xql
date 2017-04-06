xquery version "3.0";

module namespace register = "http://clarin.ids-mannheim.de/standards/register-user";

import module namespace user="http://clarin.ids-mannheim.de/standards/user" at "../model/user.xqm";
import module namespace app = "http://clarin.ids-mannheim.de/standards/app" at "../modules/app.xql";
import module namespace login = "http://clarin.ids-mannheim.de/standards/login" at "../modules/login.xql";

(: Define methods for user registration
   @author margaretha
:)

(: Validate email :)
declare function register:validate-email($submitted,$email){
    if ($submitted and $email) then login:validate-email($email) else ''
};

declare function register:validate-user($submitted,$recaptcha-response){
    if ($submitted and $recaptcha-response)
    then register:verify-recatcha($recaptcha-response)
    else false()    
     
};

declare function register:verify-recatcha($recaptcha-response){
    let $secret := "6Le3-A4TAAAAAAP8mzY5XNDFlAWkyt4YS5wUl9Gg"
    let $url := concat("https://www.google.com/recaptcha/api/siteverify?secret=", $secret, "&amp;response=", $recaptcha-response)
    let $uri := xs:anyURI($url)    
    let $doc := "test"
    let $response := httpclient:post($uri, $doc, false(),())
    let $success := util:base64-decode($response/*/text())
    
    return 
        if (contains($success,"true") )
        then true()
        else false()
}; 


(: Validate fields :)
declare function register:validate($submitted,$validEmail,$validUser,$name,$affliation,
    $email,$password){
    
    if ($submitted and $name and $validEmail and $validUser and $password) 
    then register:register-user($name,$affliation,$email,$password)
    else ()
};

(: Get display for an error message :)
declare function register:get-error-display($submitted,$field){
    if ($submitted) then
        if ($field) then "none" else "table-row"
    else "none"
};

(: Register a new user :)
declare function register:register-user($name as xs:string, $affliation as xs:string, 
    $email as xs:string, $password as xs:string) {
    
    let $hashed_password := util:hash($password, "MD5")
       
    let $user-data := 
        <user>
           <id>{concat($name,'-',current-dateTime())}</id>
           <name>{$name}</name>
           <affliation>{$affliation}</affliation>
           <email>{$email}</email>	
           <password>{$hashed_password}</password>
           <role>user</role>
        </user>
        
    let $store := user:store($user-data)
    
    return response:redirect-to(app:secure-link("user/register-confirmation.xq"))       
}; 