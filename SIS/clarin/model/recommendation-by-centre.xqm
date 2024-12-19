xquery version "3.0";

module namespace recommendation="http://clarin.ids-mannheim.de/standards/recommendation-model";

(: Define the methods for accessing recommendations
   @author margaretha
:)

declare variable $recommendation:centres := collection('/db/apps/clarin/data/recommendations')/recommendation;

declare variable $recommendation:format-ids := data($recommendation:centres/formats/format/@id);
declare variable $recommendation:format-abbrs := for $id in $recommendation:format-ids return fn:substring($id,2);


(:
It should be mentioned at this point that a recommendation is encoded in an element that it called <format>;
this is why functions that are actually counting recommendations below have "format" in the name.
:)

declare function recommendation:get-recommendations-for-centre($id){
    let $convertedId := translate($id,':','-')
    let $path := concat('/db/apps/clarin/data/recommendations/',$convertedId,"-recommendation.xml")
    return doc($path)/recommendation
};

declare function recommendation:get-recommendations-for-format($format-id){
    $recommendation:centres[formats/format/@id=$format-id]
};

declare function recommendation:get-formats-by-domain($domain){
    $recommendation:centres/formats/format[domain=$domain]
};

(: this could be generalized; for Sep 2022, it's a quick way to only get positive recommendations, for KPI-related statistics :)
declare function recommendation:get-positive-formats-by-domain($domain){
    $recommendation:centres/formats/format[domain=$domain][level != 'discouraged']
};

declare function recommendation:get-formats-by-recommendation-level($level){
    $recommendation:centres/formats/format[level=$level]
};

declare function recommendation:get-all-recommendations(){
    $recommendation:centres/formats/format
};