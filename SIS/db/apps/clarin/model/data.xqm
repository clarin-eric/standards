xquery version "3.0";

module namespace data = "http://clarin.ids-mannheim.de/standards/data";

(: Define methods for accessing the database and the XML data
   @author margaretha
:)

(: Data Collection Path:)
declare variable $data:path := "/db/apps/clarin/data";

(: Specification Collection Path:)
declare variable $data:spec-path := "/db/apps/clarin/data/specifications";

(: User registered Standard Collection Path:)
declare variable $data:review-path := "/db/apps/clarin/data/review";

(: Standard Resource Collection Path:)
declare variable $data:doc-path := "/db/apps/clarin/data/doc";

(: Data Collection :)
declare variable $data:data := collection($data:path);

declare variable $data:admin-pwd := doc("../data/users.xml")/users/user[role/text()="dba"]/password;

(: Select all ids in the data:)
declare function data:get-all-ids(){
    $data:data/descendant-or-self::node()/@id
};

(: Open connection to specification or review data :)
declare function data:open-access-to-database(){
    if (session:get-attribute("user") = 'webadmin' )
    then xmldb:login($data:spec-path, 'admin', $data:admin-pwd)
    else xmldb:login($data:review-path, 'admin', $data:admin-pwd)
};

(: Close connection :)
declare function data:close-access-to-database(){
    if (session:get-attribute("user") = 'webadmin' )
    then xmldb:login($data:spec-path, 'guest', 'guest')
    else xmldb:login($data:review-path, 'guest', 'guest')    
};

(: Open connection to documents or review data :)
declare function data:open-access-to-doc(){
    if (session:get-attribute("user") = 'webadmin' )
    then xmldb:login($data:doc-path, 'admin', $data:admin-pwd)
    else xmldb:login($data:review-path, 'admin', $data:admin-pwd)    
};

(: Close connection :)
declare function data:close-access-to-doc(){
    if (session:get-attribute("user") = 'webadmin' )
    then xmldb:login($data:doc-path, 'guest', 'guest')
    else xmldb:login($data:review-path, 'guest', 'guest')
};