xquery version "3.0";

module namespace xsd = "http://clarin.ids-mannheim.de/standards/schema";

declare variable $xsd:doc := doc('../schemas/spec.xsd');

declare function xsd:get-relations(){
    let $relations := $xsd:doc/xs:schema/xs:element[@name="relation"]/xs:complexType/
        xs:attribute[@name="type"]/xs:simpleType/xs:restriction    
    return
        for $relation in $relations/xs:enumeration 
        return data($relation/@value)
};

declare function xsd:get-relation-enumeration(){
    $xsd:doc/xs:schema/xs:element[@name="relation"]/xs:complexType/xs:attribute[@name="type"]/
    xs:simpleType/xs:restriction
};

declare function xsd:get-statuses(){
    $xsd:doc/xs:schema/xs:element[@name="version"]/xs:complexType/xs:attribute[@name="status"]/
    xs:simpleType/xs:restriction
};

declare function xsd:get-resp(){
    $xsd:doc/xs:schema/xs:element[@name="respStmt"]/xs:complexType/xs:sequence/
    xs:element[@name="resp"]/xs:simpleType/xs:restriction
};

declare function xsd:get-resptype(){
    $xsd:doc/xs:schema/xs:element[@name="respStmt"]/xs:complexType/xs:sequence/
    xs:element[@name="name"]/xs:complexType/xs:simpleContent/xs:extension/
    xs:attribute[@name="type"]/xs:simpleType/xs:restriction

};
