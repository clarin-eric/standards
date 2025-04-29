xquery version "3.0";

module namespace spec="http://clarin.ids-mannheim.de/standards/specification";

import module namespace data = "http://clarin.ids-mannheim.de/standards/data" at "data.xqm";
import module namespace functx = "http://www.functx.com" ;

(: Define methods to access the standard data or store new standard data
   @author margaretha
:)

(: Select all standards that are not hidden :)
declare variable $spec:specs := collection("/data/specifications")/spec[not(data(@display)='hide')];
(: Select all standards submitted by the user :)
declare variable $spec:reviews := collection("/data/review")/spec;

(: Create an ordered sequence of standards by standard abbreviation :)
declare function spec:sort-specs-by-abbr($specs,$letter){
    let $specs := if($letter) then $specs else $spec:specs
    return
        for $spec in $specs
        order by $spec/titleStmt/abbr/text()
        return $spec
};

declare function spec:sort-specs-by-abbr(){
    spec:sort-specs-by-abbr("","")
};

declare function spec:sort-specs-by-topic($specs,$letter){
    let $specs := if($letter) then $specs else $spec:specs
    return
        for $spec in $specs               
        order by $spec/functx:sort(tokenize(data($spec/@topic),' '))[1]
        return $spec
};

declare function spec:sort-specs-by-sb($specs,$letter){
    let $specs := if($letter) then $specs else $spec:specs
    return
        for $spec in $specs
        order by $spec/@standardSettingBody
        return $spec
};

declare function spec:sort-specs-by-clarin-centres($specs,$letter){
    let $specs := if($letter) then $specs else $spec:specs
    return
        for $spec in $specs    
        order by $spec/functx:sort(tokenize(data(descendant-or-self::node()/@usedInCLARINCentre),' '))[1]
        return $spec
};

(:declare function spec:sort-specs-by-clarin-approval(){
    for $spec in $spec:specs
    let $p := $spec/descendant-or-self::version[@CLARINapproved='yes']
    order by $p[1]
    return $spec
};
:)

declare function spec:get-specs-by-letter($letter){
    for $spec in $spec:specs[fn:starts-with(upper-case(titleStmt/abbr/text()),$letter)]
    order by $spec/titleStmt/abbr
    return $spec
};


(: Get the spec/part/version node of the given id :)
declare function spec:get-spec($id as xs:string){
    $spec:specs/descendant-or-self::node()[@id=$id]
};

(: Count the number of standards in the collection:)
declare function spec:sum(){
    count($spec:specs)
};

(: Get all the target of standard relations :)
declare function spec:get-targets(){   
    for $spec in $spec:specs         
    return $spec/descendant-or-self::node()/relation/data(@target)
};

(: Get all the standard bodies:)
declare function spec:get-standardBodies(){
    $spec:specs/data(@standardSettingBody)
};

(: Get the topic of a standard :)
declare function spec:get-topics($spec){
    for $t in tokenize(data($spec/@topic),' ')
    order by $t
    return $t
};

declare function spec:get-clarin-centres($spec){    
    for $c in tokenize(data($spec/descendant-or-self::*/@usedInCLARINCentre),' ') 
    order by $c
    return $c   
};

declare function spec:get-clarin-approval($spec){
    $spec/descendant-or-self::version[@CLARINapproved='yes']
};


