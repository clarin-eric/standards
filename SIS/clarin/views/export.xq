xquery version "3.1";

declare namespace exist = "http://exist.sourceforge.net/NS/exist";

import module namespace app = "http://clarin.ids-mannheim.de/standards/app" at "../modules/app.xql";
import module namespace cm = "http://clarin.ids-mannheim.de/standards/centre-module" at "../modules/centre.xql";

import module namespace rf = "http://clarin.ids-mannheim.de/standards/recommended-formats" at "../modules/recommended-formats.xql";
import module namespace em = "http://clarin.ids-mannheim.de/standards/export" at "../modules/export.xql";

let $source := request:get-parameter('source', '')
let $id := request:get-parameter('id', '')
let $sortBy := request:get-parameter('sortBy', '')
let $export := request:get-parameter('export', '')
let $template := request:get-parameter('template', '')

let $exportFilename := 
    if ($id) then concat($id,"-recommendation.xml") 
    else "format-recommendation.xml"

let $searchItem := request:get-parameter('searchFormat', '')
let $centre :=  request:get-parameter('centre', '')
let $id := if ($centre) then $centre else $id

let $domainId := request:get-parameter('domain',())
let $recommendationLevel := request:get-parameter('level', '')

let $languageHeader := fn:substring(request:get-header("Accept-Language"),0,3)

let $request-ri := request:get-parameter('ri', '')
let $ri :=  if ($request-ri) then $request-ri else request:get-cookie-value("ri")
let $ri := if (empty($ri)) then "CLARIN" else $ri
let $languageHeader := 
    if (not($ri eq "CLARIN") and not($ri eq "all")) then "de" else $languageHeader
let $ri-filter := if ($source eq "views/view-centre.xq") then "" else $ri

let $centreInfo := cm:get-centre-info($id,$languageHeader)

let $rows :=
     rf:print-centre-recommendation($centre,$domainId, $recommendationLevel, 
     $sortBy, $languageHeader, $ri)

let $rows := 
    if ($searchItem)
    then rf:searchFormat($searchItem,$rows)
    else $rows


return

if ($export)
then (em:export-table($ri-filter,$id, $domainId, $recommendationLevel, $rows,
    $exportFilename,$source,$centreInfo))
else if ($template)
then (em:download-template($id,$exportFilename))
else()


(:
then (em:export-table("", $id, (), "", 
            rf:print-centre-recommendation($id,(), "", $sortBy,$languageHeader,$ri),
            $exportFilename, "views/view-centre.xq", cm:get-centre-info($id,$languageHeader)))

then (em:export-table($ri,$centre, $domainId, $recommendationLevel, $rows,
    "format-recommendation.xml","views/recommended-formats-with-search.xq",$centreInfo)):)