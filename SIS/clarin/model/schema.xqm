xquery version "3.0";

module namespace xsd = "http://clarin.ids-mannheim.de/standards/schema";

(: Define methods to access data in the schema
   @author margaretha
   @date Dec 2013
:)

declare namespace map = "http://www.w3.org/2005/xpath-functions/map";

declare variable $xsd:doc := doc('../schemas/spec.xsd');
declare variable $xsd:format := doc('../schemas/format.xsd');
declare variable $xsd:recommendation := doc('../schemas/recommendation.xsd');

(:get research infrastructures:)
declare function xsd:get-ris() as xs:string* {
    $xsd:recommendation/xs:schema/xs:simpleType[@name eq 'ResearchInfrastructures']/xs:restriction/xs:enumeration/data(@value)
};

declare function xsd:get-statuses-in-ri($ri as xs:string) as xs:string* {
    let $stats as xs:string* :=  $xsd:recommendation/xs:schema/xs:simpleType[@name eq concat('CentreStatus-',$ri)]/xs:list/xs:simpleType/xs:restriction/xs:enumeration/@value ! string(.)
    return if (count($stats))
           then $stats
           else concat($ri,'-inapplicable')
};

(:not yet used anywhere:)
declare function xsd:list-ri-node-statuses() as map(xs:string, xs:string*) {
    let $ris as xs:string+ := xsd:get-ris()
    let $ri-map as map(xs:string, xs:string+) := map:merge( for $ri in $ris return map:entry( $ri , xsd:get-statuses-in-ri($ri) ) )
    
    return $ri-map
};

(: Select relation types :)
declare function xsd:get-relations(){
    let $spec-relations := $xsd:doc/xs:schema/xs:element[@name="relation"]/xs:complexType/xs:attribute[@name="type"]/
    xs:simpleType/xs:restriction/xs:enumeration/data(@value)
    
    let $format-relations := $xsd:format/xs:schema/xs:element[@name="relation"]/xs:complexType/xs:attribute[@name="type"]/
    xs:simpleType/xs:restriction/xs:enumeration/data(@value)
    
    return fn:distinct-values(($spec-relations, $format-relations))
};

(: Select status types :)
(:this is for statuses of a standards document:)
declare function xsd:get-statuses(){
    $xsd:doc/xs:schema/xs:element[@name="version"]/xs:complexType/xs:attribute[@name="status"]/
    xs:simpleType/xs:restriction/xs:enumeration/data(@value)
};

(: Select responsible types (e.g. author, editor, etc) :)
declare function xsd:get-resp(){
    $xsd:doc/xs:schema/xs:element[@name="respStmt"]/xs:complexType/xs:sequence/
    xs:element[@name="resp"]/xs:simpleType/xs:restriction/xs:enumeration/data(@value)
};

(: Select responsible entity types (e.g. person, org) :)
declare function xsd:get-resptype(){
    $xsd:doc/xs:schema/xs:element[@name="respStmt"]/xs:complexType/xs:sequence/
    xs:element[@name="name"]/xs:complexType/xs:simpleContent/xs:extension/
    xs:attribute[@name="type"]/xs:simpleType/xs:restriction/xs:enumeration/data(@value)

};

declare function xsd:get-clarinRecTypes(){
    $xsd:doc/xs:schema//xs:element[@name="recommendation"]/xs:complexType/xs:attribute[@name="type"]/
    xs:simpleType/xs:restriction/xs:enumeration/data(@value)
};
