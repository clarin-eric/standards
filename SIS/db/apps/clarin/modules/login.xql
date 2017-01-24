xquery version "3.0";

module namespace login = "http://clarin.ids-mannheim.de/standards/login";
import module namespace user="http://clarin.ids-mannheim.de/standards/user" at "../model/user.xqm";
import module namespace app = "http://clarin.ids-mannheim.de/standards/app" at "../modules/app.xql";

declare function login:validate-email($email as xs:string){ 
    matches($email, '[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}')
};

declare function login:authorize($submit, $email, $password){
    if($submit and $email and $password)
    then login:validate-account($email, $password)
    else fn:false()
};

declare function login:validate-account($email, $password){    
    let $hashed-password := util:hash($password, "MD5")
    let $user := user:get-user($email)
    return
        if ($user/password/text() = $hashed-password)
        then login:create-session($user)
        else ()        
};

declare function login:create-session($user){
    let $session := session:create()
    let $session-name := 
        if ($user/role = "webadmin")
        then session:set-attribute("user","webadmin")
        else session:set-attribute("user","user")
    return response:redirect-to(app:secure-link("index.xq"))
};

declare function login:destroy-session(){
    let $null := session:remove-attribute("user")
    let $inval := session:invalidate()
    return ""
};

declare function login:register($name as xs:string, $affliation as xs:string, 
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
} ; 