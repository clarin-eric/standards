xquery version "3.0";
module namespace bib="http://clarin.ids-mannheim.de/standards/bibliography";

(: IEEE style :)

declare function bib:get-references($bibpath){
    for $bib in $bibpath
      let $title := $bib/analytic/title/text()
      let $num-authors := count($bib/analytic/author)
      let $authors := $bib/analytic/author                  
      let $authors :=
        if (not(empty($authors/orgName/text()))) then
            $authors/orgName/text()
        else if ($num-authors > 2) then
            concat(fn:substring($authors[1]/forename/text(),1,1), ". " , $authors[1]/surname/text()," et al.")                            
        else if ($num-authors = 2) then 
            concat(fn:substring($authors[1]/forename/text(),1,1), ". " , $authors[1]/surname/text()," and ",
            fn:substring($authors[2]/forename/text(),1,1), ". " , $authors[2]/surname/text())
        else if ($num-authors=1) 
            then concat(fn:substring($authors[1]/forename/text(),1,1), ". " , $authors[1]/surname/text())
        else ()
        
      let $num-editors := count($bib/monogr/imprint/editor)
      let $editors := $bib/monogr/imprint/editor
      let $editors := 
        if ($num-editors > 2) then
            concat(fn:substring($editors[1]/forename/text(),1,1), ". " , $editors[1]/surname/text()," et al., Eds. ")                            
        else if ($num-editors = 2) then 
            concat(fn:substring($editors[1]/forename/text(),1,1), ". " , $editors[1]/surname/text()," and ",
            fn:substring($editors[2]/forename/text(),1,1), ". " , $editors[2]/surname/text(),", Eds. ")
        else if ($num-editors=1) 
        then concat(fn:substring($editors[1]/forename/text(),1,1), ". " , $editors[1]/surname/text(),", Ed. ")
        else ()
      
      let $publisher := $bib/monogr/imprint/publisher/text()
      let $year := $bib/monogr/imprint/date/text()
      let $edition := ''
      let $place := $bib/monogr/imprint/pubPlace/text()
      let $pages := $bib/monogr/imprint/biblScope[@type='pp']/text()
      let $url :=  $bib/monogr/imprint/note[@type='url']/text()
      let $conf := $bib/monogr/title/text()
      let $vol :=''
      let $issue := $bib/monogr/imprint/biblScope[@type='issue']/text()                      
       
      return
        if ($bib[@type='book'])
        then <li>{$authors}, <i>{$title}</i>, 
                  {if ($edition) then concat ("(",$edition,").") else()}
                  {if ($editors) then $editors else()}
                  {if ($place) then concat($place,": ") else ()}
                  {if ($publisher) then concat($publisher,", ") else ()}
                  {if ($year) then concat($year, ". ") else ()}
              </li>
        else if ($bib[@type='bookSection'])
        then <li>{$authors}, "{$title}," in <i>{$conf}</i>. 
                  {if ($edition) then concat ("(",$edition,").") else()}
                  {if ($editors) then $editors else()}
                  {if ($place) then concat($place,": ") else ()}
                  {if ($publisher) then concat($publisher,", ") else ()}
                  {if ($year and $pages) then concat($year, ", pp. ", $pages, ". ") 
                   else if ($year and not($pages)) then concat($year, ". ")
                   else if ($pages) then concat("pp. ", $pages, ". ") 
                   else ()}
              </li>
        else if ($bib[@type='conferencePaper'])
        then <li>{$authors}, "{$title}," in <i>{$conf}</i>,
                  {if ($place) then $place else ()}
                  {if ($year) then concat(", ", $year) else ()}
                  {if ($pages) then concat(", pp. ", $pages) else ()}
                  {if ($publisher) then concat(", ", $publisher) else ()}
                  {if ($url) then concat(". Available: ",$url) else ()}.
              </li>
        else if ($bib[@type='journalArticle'])
        then <li>{$authors}, "{$title}," <i>{$conf}</i>,
                  {if ($vol) then concat("vol. ", $vol,", ") else ()}
                  {if ($issue) then concat("no. ", $issue,", ") else ()}
                  {if ($pages) then concat("pp. ", $pages, ", ") else ()}
                  {if ($year) then concat($year, ". ") else ()}
                  {if ($url) then concat("Available: ",$url) else ()}
             </li>
        else if ($bib[@type='onlineSource'])
        then <li>
                 {if ($authors) then concat($authors, ". ") else()}                 
                 {if ($year) then concat("(",$year,")", ". ") else ()}
                 <i>{$title}</i>
                 {if ($edition) then concat ("(",$edition,")") else()}
                 [Online].
                 <!--{if ($publisher) then concat(", ", $publisher) else ()} --> 
                 {if ($url) then concat("Available: ",$url) else ()}
             </li>
        else ()    
};