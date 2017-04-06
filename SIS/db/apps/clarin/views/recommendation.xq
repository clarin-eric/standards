xquery version "3.0";

declare namespace exist="http://exist.sourceforge.net/NS/exist";
declare option exist:serialize "method=xhtml media-type=text/html indent=yes doctype-system=about:legacy-compat";

import module namespace menu = "http://clarin.ids-mannheim.de/standards/menu" at "../modules/menu.xql";
import module namespace app = "http://clarin.ids-mannheim.de/standards/app" at "../modules/app.xql";
import module namespace rm="http://clarin.ids-mannheim.de/standards/recommendation" at "../modules/recommendation.xql";

(:  Define the standard page
    @author margaretha
    @date Dec 2013
:)

let $type := request:get-parameter('type', 'fr')
return 
<html>
	<head>
        <title>CLARIN Standard Recommendations</title>
        <link rel="stylesheet" type="text/css" href="{app:resource("style.css","css")}"/>       
    </head>
  <body>
  	<div id="all">
            <div class="logoheader"/>
			{menu:view()}
            <div class="content">
                <div class="navigation">
                    &gt; <a href="{app:link("views/recommendation.xq")}">Recommendations</a>
                </div>
                <div class="title">CLARIN Standard Recommendations</div>
        		<div><p></p></div>
        		<div>{rm:print-recTypes()}</div>
        		<div class="heading3">{upper-case(rm:translate-type($type))}</div>
        		<table cellspacing="4px" style="width:97%">
                    <tr>
                        <th class="header" style="width:25%;">Abbreviation</th>
                        <th class="header" style="width:10%;">Resp.</th>
                        <th class="header" style="width:20%;">Clarin Center(s)</th>
                        <th class="header" style="width:25%;">Alternative(s)</th>
                        <th class="header" style="width:17%;">Note</th>
                    </tr>                
                    {rm:print-recTable($type)}
                </table>
            </div>
            <div class="footer">{app:footer()}</div>
		</div>			
	</body>
</html>