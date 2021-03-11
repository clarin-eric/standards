xquery version "3.0";

module namespace login = "http://clarin.ids-mannheim.de/standards/login";
import module namespace user="http://clarin.ids-mannheim.de/standards/user" at "../model/user.xqm";
import module namespace app = "http://clarin.ids-mannheim.de/standards/app" at "../modules/app.xql";

(: Define methods for login and logout
   @author margaretha
:)

(: Get display for authorization error message :)
declare function login:get-authorization-error($submitted,$email,$password,$authorized){
    if ($submitted and $email and $password and not($authorized))                       
    then "table-row"
    else "none"
};

(: Validate Email :)
declare function login:validate-email($email as xs:string){ 
    matches($email, '[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}')
};

(: Validate account :)
declare function login:authorize($submit, $email, $password){
    let $isLoginValid := 
        if($submit and $email and $password)
        then login:validate-account($email, $password)
        else fn:false()
        
    let $isSessionValid := 
        if ($isLoginValid)
        then login:create-session(user:get-user($email))
        else fn:false()
    
    return if ($isSessionValid) then response:redirect-to(app:link("index.xq")) else()
};

(: Process login :)
declare function login:validate-account($email, $password){    
    let $hashed-password := util:hash($password, "MD5")
    let $user := user:get-user($email)
    return
        if ($user/password/text() = $hashed-password)
        then fn:true() 
        else fn:false() 
};

(: Create session :)
declare function login:create-session($user){
    let $session := session:create()
    let $session-name := 
        if ($user/role = "webadmin")
        then session:set-attribute("user","webadmin")
        else session:set-attribute("user","user")
    let $setCookie := response:set-cookie("sessionId",session:get-id()) 
    return session:exists()
};

(: Logout process :)
declare function login:logout(){
    if (session:get-attribute("user"))
    then (session:remove-attribute("user"),session:invalidate())
    else app:link("user/login.xq")
};

