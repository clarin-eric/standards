xquery version "3.0";

module namespace user = "http://clarin.ids-mannheim.de/standards/user";
import module namespace data = "http://clarin.ids-mannheim.de/standards/data" at "data.xqm";

(: DEPRECATED

   Define methods for accessing and storing user data
   @author margaretha
:)

(: Select all users :)
declare variable $user:list := doc("../data/users.xml")/users ;

(: Select a user by email :)
declare function user:get-user($email as xs:string){
    doc('../data/users.xml')/users/user[email/text()=$email]
};

(: Store a new user data :)
declare function user:store($user-data){
    let $login := xmldb:login($data:path, 'admin', $data:admin-pwd)
    let $store := update insert $user-data into $user:list
    let $login := xmldb:login($data:path, 'guest', 'guest')
    return ""
};