xquery version "3.0";

declare namespace exist = "http://exist.sourceforge.net/NS/exist";
declare option exist:serialize "method=xhtml media-type=text/html indent=yes doctype-system=about:legacy-compat";

import module namespace menu = "http://clarin.ids-mannheim.de/standards/menu" at "../modules/menu.xql";
import module namespace app = "http://clarin.ids-mannheim.de/standards/app" at "../modules/app.xql";
import module namespace fm = "http://clarin.ids-mannheim.de/standards/format-module" at "../modules/format.xql";
import module namespace rf = "http://clarin.ids-mannheim.de/standards/recommended-formats" at "../modules/recommended-formats.xql";

let $reset := request:get-parameter('resetButton', '')
let $keyword := if ($reset) then () else request:get-parameter('keyword', '')

return
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
                    &gt; <a href="{app:link("views/recommended-formats-with-search.xq")}">Format Recommendations</a>
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
                <div id="defined">
                    <h2>Formats described in the SIS ({fm:count-defined-formats()}): </h2>
                    <p>The name of the format links to its description, sometimes rather stubby (you are welcome to help us extend the list
                        and/or the descriptions, either by
                        <a href="{app:getGithubIssueLink()}">submitting an issue at GitHub</a>
                        containing suggested text or corrections, or by editing or adding the relevant
                        <a href="https://github.com/clarin-eric/standards/tree/formats/SIS/clarin/data/formats">format file</a> and submitting a pull request).</p>
                    
                    <p>By clicking on the icon next to the format name, you can copy the format ID, which may be useful for editing or adding 
                       centre recommendations.</p>
                    
                       <form method="get" action="{app:link("views/list-formats.xq#defined")}">
                            <table style="margin:0;">
                                <tr>
                                    <td><span class="heading3">Keyword</span>:
                                        <select name="keyword" class="inputSelect" style="width:185px;">
                                            {rf:print-option($keyword, "", "Select keyword ...")}
                                            {rf:print-keywords($keyword)}
                                        </select>
                                    </td>
                                    <td>
                                        <input name="searchButton" class="button"
                                        style="margin:0;height:25px;" type="submit" value="Search"/>
                                    </td>
                                    <td>
                                        <input name="resetButton" class="button"
                                        style="margin-bottom:5px;height:25px;" type="submit" value="Reset"/>
                                    </td>
                                </tr>
                            </table>
                       </form>
                </div>
                <table>
                    <tr>
                        <th style="width:60%">Format</th>
                        <th style="width:20%">MIME types</th>
                        <th style="width:20%">File Extensions</th>
                    </tr>
                    {fm:list-formats($keyword)}
                </table>
            </div>
            <div
                class="footer">{app:footer()}</div>
        </div>
    </body>
</html>