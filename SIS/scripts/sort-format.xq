xquery version "3.1";

(:  XQuery program to sort formats in a recommendation file by domains alphabetically. 
    For each domain, the formats are sorted again by their id alphabetically.

    Input:
    
        A recommendation file in the following format:
        
        <result>
            <header>
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
        </result>
        
    Requirements:
    
        Java, a Saxon library, a recommendation file
    
    How to run this program:
    
        java -cp [saxon-jar] net.sf.saxon.Query -s:[recommendation-file] sort-format.xq > [output-file] 

        Example:
    
        java -cp saxon-he-10.6.jar net.sf.saxon.Query -s:ACDH-ARCHE-recommendation.xml sort-format.xq > output.xml 

    Author: Eliza Margaretha
    Date: October 14th, 2021

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
        <result>
            {$r/header}
            <formats>
            {$new-formats}
            </formats>
        </result>
    return
    $new-recommendation
};

sf:rewrite-recommendations(//result)