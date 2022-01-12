xquery version "3.0";

module namespace recommendation="http://clarin.ids-mannheim.de/standards/recommendation-model";

(: Define the methods for accessing recommendations
   @author margaretha
:)

declare variable $recommendation:centres := collection('/db/apps/clarin/data/recommendations')/recommendation;

declare function recommendation:get-recommendations-for-centre($id){
    let $path := concat('/db/apps/clarin/data/recommendations/',$id,"-recommendation.xml")
    return doc($path)/recommendation
};

declare function recommendation:get-recommendations-for-format($format-id){
    $recommendation:centres[formats/format/@id=$format-id]
};

declare function recommendation:get-formats-by-domain($domain){
    $recommendation:centres/formats/format[domain=$domain]
};


declare function recommendation:get-formats-by-recommendation-level($level){
    $recommendation:centres/formats/format[level=$level]
};

