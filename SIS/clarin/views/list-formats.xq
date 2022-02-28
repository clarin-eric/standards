xquery version "3.0";

declare namespace exist = "http://exist.sourceforge.net/NS/exist";
declare option exist:serialize "method=xhtml media-type=text/html indent=yes doctype-system=about:legacy-compat";

import module namespace menu = "http://clarin.ids-mannheim.de/standards/menu" at "../modules/menu.xql";
import module namespace app = "http://clarin.ids-mannheim.de/standards/app" at "../modules/app.xql";
import module namespace fm = "http://clarin.ids-mannheim.de/standards/format-module" at "../modules/format.xql";

(: 
    @author margaretha
:)

<html>
    <head>
        <title>Data Deposition Formats</title>
        <link rel="stylesheet" type="text/css" href="{app:resource("style.css", "css")}"/>
        <script type="text/javascript" src="{app:resource("edit.js", "js")}"/>
        <script type="text/javascript" src="{app:resource("utils.js", "js")}"/>
    </head>
    <body>
        <div id="all">
            <div class="logoheader"/>
            {menu:view()}
            <div class="content">
                <div class="navigation">
                    &gt; <a href="{app:link("views/list-formats.xq")}">Data Deposition Formats</a>
                </div>
                <div class="title">Data Deposition Formats</div>
                <div>
                    <p>This page lists both the formats that are referenced in centre recommendations, and those that are defined in the SIS. Ideally,
                        the latter set should properly contain the former, but the aim of the SIS is to reflect the <i>current</i> recommendations, and
                        these are meant to be created in a dynamic fashion, as needed and as dictated by the evolving technological context. Therefore, this page
                        is divided into three sections: (a) formats that are referenced in recommendations but are not yet defined in the SIS, (b) formats
                        defined in the SIS but not referenced in recommendations, and (c) (properly containing (b)) formats defined in the SIS. The last list 
                        provides some additional basic details.</p>
                </div>
                <div id="missing">
                    <h2>List of missing formats by ID ({fm:count-missing-format-ids()}): </h2>
                    <p>These formats are referenced by centre recommendations, but not yet described in the SIS. Clicking on an ID 
                    below will open a pre-configured GitHub issue where you can suggest the content of the format description.</p>
                    <p>The list is also part of the sanity checking functionality: it may happen that some recommendation has a 
                    typo in the format ID, and then it will show up here.</p>
                    <div>
                        <ul class="column" style="padding:0px; margin-left:15px;">
                            {fm:list-missing-format-ids()}
                        </ul>
                    </div>
                </div>
                <div id="unreferenced">
                    <h2>Existing format descriptions not referenced by any recommendation ({fm:count-orphan-format-ids()}): </h2>
                    <p>Note that membership in this list does not automatically indicate an error. Recommendations may change and leave "stray" 
                       formats unused, and we may sometimes want to merely describe "unspecified" versions of formats, while their 
                       particular variants are used in recommendations (because finer granularity is nearly always better).</p>
                    <div>
                        <ul class="column" style="padding:0px; margin-left:15px;">
                            {fm:list-orphan-format-ids()}
                        </ul>
                    </div>
                </div>
                <div id="defined">
                    <h2>Formats described in the SIS ({fm:count-defined-formats()}): </h2>
                    <p>The name of the format links to its description, sometimes rather stubby (you are welcome to help us extend the list
                        and/or the descriptions, either by
                        <a href="{app:getGithubIssueLink()}">submitting an issue at GitHub</a>
                        containing suggested text or corrections, or by editing or adding the relevant
                        <a href="https://github.com/clarin-eric/standards/tree/formats/SIS/clarin/data/formats">format file</a> and submitting a pull request).</p>
                    
                    <p>By clicking on the icon next to the format name, you can copy the format ID, which may be useful for editing or adding 
                       centre recommendations.</p>
                    
                    <ul style="padding:0px; margin-left:15px;">
                        {fm:list-formats()}
                    </ul>
                </div>
            
            </div>
            <div
                class="footer">{app:footer()}</div>
        </div>
    </body>
</html>