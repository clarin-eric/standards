xquery version "3.0";

module namespace data = "http://clarin.ids-mannheim.de/standards/data";

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

declare variable $data:admin-pwd := 'c5gW4p13';

declare function data:open-access-to-database(){
    if (session:get-attribute("user") = 'webadmin' )
    then xmldb:login($data:spec-path, 'admin', $data:admin-pwd)
    else xmldb:login($data:review-path, 'admin', $data:admin-pwd)
};

declare function data:close-access-to-database(){
    if (session:get-attribute("user") = 'webadmin' )
    then xmldb:login($data:spec-path, 'guest', 'guest')
    else xmldb:login($data:review-path, 'guest', 'guest')    
};

declare function data:open-access-to-doc(){
    if (session:get-attribute("user") = 'webadmin' )
    then xmldb:login($data:doc-path, 'admin', $data:admin-pwd)
    else xmldb:login($data:review-path, 'admin', $data:admin-pwd)    
};

declare function data:close-access-to-doc(){
    if (session:get-attribute("user") = 'webadmin' )
    then xmldb:login($data:doc-path, 'guest', 'guest')
    else xmldb:login($data:review-path, 'guest', 'guest')
};