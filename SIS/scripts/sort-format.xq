xquery version "3.1";

(:  XQuery program to sort formats in a recommendation file by domains alphabetically. 
    For each domain, the formats are sorted again by their id alphabetically.
    
    If there are no formats within the recommendation, an empty template will be 
    produced.

    Input:
    
        A recommendation file in the following format:
        
        <recommendation xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
            xsi:noNamespaceSchemaLocation="../../schemas/recommendation.xsd">
            <header>
                  <lastUpdateCommitID>147cb5ea659a5752efd819898b43da23e00c6a77</lastUpdateCommitID>
                  <filter>
                   <centre>ACDH-ARCHE</centre>
                </filter>
            </header>
            <formats>
                <format>
                   <name id="fFLAC">FLAC</name>
                   <domain>Audiovisual Source Language Data</domain>
                   <level>recommended</level>
                </format>
            </formats>
        </recommendation>
        
    Requirements:
    
        Java, a Saxon library, a recommendation file
    
    How to run this program:
    
        java -cp [saxon-jar] net.sf.saxon.Query -s:[recommendation-file] sort-format.xq > [output-file] 

        Example:
    
        java -cp saxon-he-10.6.jar net.sf.saxon.Query -s:ACDH-ARCHE-recommendation.xml sort-format.xq > output.xml 
        
     
     This program can also be run from Oxygen by configuring a new scenario for XML transformation using XQuery.

    Author: Eliza Margaretha
    Creation Date: October 14th, 2021
    Last Update: March 2022 
:)

declare namespace sf = "http://clarin.ids-mannheim.de/standards/sort-formats";

declare option saxon:output "indent=yes";

declare function sf:sort-formats-by-domain($formats){
    for $format in $formats
        let $domainName := $format/domain/text()
        order by
                $domainName
        return $format
};

declare function sf:sort-formats-by-id($formats){
   for $format in $formats
        let $format-id := data($format/@id)
        order by fn:lower-case($format-id)
        return $format
};

declare function sf:sort-domains($domains){
    let $domains := fn:distinct-values($domains)
    for $d in $domains
    order by fn:lower-case($d)
    return $d
};

declare function sf:rewrite-recommendations($r) {
    let $sorted-formats := sf:sort-formats-by-id($r/formats/format)
    let $domains := sf:sort-domains($r/formats/format/domain)
    let $new-formats := 
        for $domain in $domains
            let $formats := $r/formats/format[domain eq $domain]
            return sf:sort-formats-by-id($formats)
    let $new-recommendation := 
    <recommendation xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="../../schemas/recommendation.xsd">
        {$r/header}
        <formats>
        {$new-formats}
        </formats>
    </recommendation>
    return
    $new-recommendation
};

declare function sf:write-template($r){
    <recommendation xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="../../schemas/recommendation.xsd">
        {$r/header}
        <formats>
        <!--
            This template will assist in adjusting/creating a recommendations document if you don't
            have access to a schema-aware XML editor. Copy the XML fragment, 
            *  adjust the format ID (see https://clarin.ids-mannheim.de/standards/views/list-formats.xq ),
            *  adjust the domain (https://clarin.ids-mannheim.de/standards/views/list-domains.xq ),
            *  adjust the recommendation level ({ recommended, acceptable, deprecated }),
            *  repeat as necessary;
            *  submit the result as a PR against https://github.com/clarin-eric/standards/tree/formats .
            
            <format id="null">
                <domain>Audiovisual Annotation</domain>
                <level>recommended</level>
            </format> 
        -->&#10;
        </formats>
    </recommendation>
};

declare function sf:check-recommendation($r){
    let $format := $r/formats/format
    return
    if ($format)
    then (sf:rewrite-recommendations($r))
    else (sf:write-template($r))
};

sf:check-recommendation(//recommendation)