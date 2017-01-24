xquery version "1.0";
declare variable $exist:path external;
declare variable $exist:resource external;

if ($exist:path eq '/') then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="index.xq"/>                
    </dispatch>    
    
else if ($exist:resource eq "users.xml") then 
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="../index.xq"/>           
    </dispatch>
            
else if ($exist:resource eq 'edit-process.xq' or $exist:resource eq 'add-spec-part.xq' 
    or $exist:resource eq 'add-spec-version.xq') then  
        if (session:get-attribute("user") eq 'webadmin')
        then
           <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="{$exist:resource}"/>
            </dispatch>
        else () 
            (:<dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <redirect url="../index.xq"/>         
            </dispatch>:)                
    
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
else ()
