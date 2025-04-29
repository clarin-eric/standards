xquery version "3.0";

module namespace data = "http://clarin.ids-mannheim.de/standards/data";

(: Define methods for accessing the database and the XML data
   @author margaretha
:)

(: Data Collection Path:)
declare variable $data:path := "/data";

(: Specification Collection Path:)
declare variable $data:spec-path := "/data/specifications";

(: User registered Standard Collection Path:)
declare variable $data:review-path := "/data/review";

(: Standard Resource Collection Path:)
declare variable $data:doc-path := "/data/doc";

(: Data Collection :)
declare variable $data:data := collection($data:path);

(: Select all ids in the data:)
declare function data:get-all-ids(){
    $data:data/descendant-or-self::node()/@id
};

