xquery version "1.0";
declare variable $exist:path external;
declare variable $exist:resource external;

import module namespace app = "http://clarin.ids-mannheim.de/standards/app" at "modules/app.xql";

(: The controller XQuery
    @author margaretha
    @date Dec 2013
    @updated Apr 2017
:)

(: URL rewriting to index.xq :)
if ($exist:path eq '/') then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="index.xq"/>                
    </dispatch>    

else if (request:get-parameter('_query', '')) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="{$app:base}"/>                
    </dispatch> 

(: Prohibit access to users.xml:)
else if ($exist:resource eq "users.xml") then 
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="{$app:base}/index.xq"/>           
    </dispatch>
    
else if ($exist:resource eq "secrets.xml") then 
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="{$app:base}/index.xq"/>           
    </dispatch>    

(: Authorization check on editing process:)
else if ($exist:resource eq 'edit-process.xq' or $exist:resource eq 'add-spec-part.xq' 
    or $exist:resource eq 'add-spec-version.xq') then
    
    if (session:get-attribute("user") eq "webadmin")
    then
       <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
            <forward url="{$exist:resource}"/>
        </dispatch>
    else  ()

(: Filtering access to add a new spec only to user  :)
else if ($exist:resource eq 'register-spec.xq' or $exist:resource eq 'register-part.xq' 
    or $exist:resource eq 'register-version.xq' or $exist:path eq "/data/review") then
    
    if (session:get-attribute("user"))
    then
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
            <forward url="{$exist:resource}"/>
        </dispatch>
    else 
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
            <redirect url="../user/login.xq"/>           
            
        </dispatch>
        
(: Filtering access to the registration page :)        
else if ($exist:resource eq "register.xq") then
    
    if (session:get-attribute("user"))
    then
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
            <redirect url="../index.xq"/>         
        </dispatch>
    else 
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
            <forward url="{$exist:resource}"/>
        </dispatch>   
        

else ()
