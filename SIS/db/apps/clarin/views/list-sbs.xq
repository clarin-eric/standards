xquery version "3.0";

declare namespace exist="http://exist.sourceforge.net/NS/exist";
declare option exist:serialize "method=xhtml media-type=text/html indent=yes doctype-system=about:legacy-compat";

import module namespace menu = "http://clarin.ids-mannheim.de/standards/menu" at "../modules/menu.xql";
import module namespace app = "http://clarin.ids-mannheim.de/standards/app" at "../modules/app.xql";
import module namespace sbm = "http://clarin.ids-mannheim.de/standards/sb-module" at "../modules/sb.xql";

<html>
	<head>
        <title>Standard Setting Bodies</title>
        <link rel="stylesheet" type="text/css" href="{app:resource("style.css","css")}"/>        
        <script type="text/javascript" src="{app:resource("edit.js","js")}"/>        
    </head>
  <body>
  	<div id="all">
            <div class="logoheader"/>
			{menu:view()}
            <div class="content">
                <div class="navigation">
                    &gt; <a href="{app:link("views/list-sbs.xq")}">Standard Setting Bodies</a>
                </div>
                <div class="title">Standard Bodies</div>
        		<div><p>Standard bodies are organizations that develop standards. </p></div>
                <ul style="padding:0px; margin-left:15px;">
                    {sbm:list-sbs()}
                </ul>
            </div>
            <div class="footer">{app:footer()}</div>
		</div>			
	</body>
</html>