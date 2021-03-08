xquery version "3.0";

declare namespace exist="http://exist.sourceforge.net/NS/exist";
declare option exist:serialize "method=xhtml media-type=text/html indent=yes doctype-system=about:legacy-compat";

import module namespace menu = "http://clarin.ids-mannheim.de/standards/menu" at "../modules/menu.xql";
import module namespace app = "http://clarin.ids-mannheim.de/standards/app" at "../modules/app.xql";
import module namespace rm="http://clarin.ids-mannheim.de/standards/recommendation" at "../modules/recommendation.xql";
import module namespace rf="http://clarin.ids-mannheim.de/standards/recommended-formats" at "../modules/recommended-formats.xql";

let $type := request:get-parameter('type', 'recommended')
return 

<html>
	<head>
        <title>CLARIN Format Recommendations</title>
        <link rel="stylesheet" type="text/css" href="{app:resource("style.css","css")}"/>       
    </head>
  <body>
  	<div id="all">
            <div class="logoheader"/>
			{menu:view()}
            <div class="content">
                <div class="navigation">
                    &gt; <a href="{app:link("views/recommended-formats.xq")}">Recommended Formats</a>
                </div>
                <div class="title">CLARIN Format Recommendations</div>
        		
        		<div>{rm:print-recTypes("recommended-formats")}</div>
        		<div class="heading3">{upper-case(rm:translate-type($type))}</div>
        		<table cellspacing="4px" style="width:97%">
                    <tr>
                        <th class="header" style="width:25%;">Abbreviation</th>
                        <th class="header" style="width:25%;">Clarin Centers</th>
                        <th class="header" style="width:25%;">Domains</th>
                    </tr>                
                 {rf:print-recommendation($type)}
                </table>
            </div>
            <div class="footer">{app:footer()}</div>
		</div>			
	</body>
</html>