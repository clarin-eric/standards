xquery version "3.1";

import module namespace menu = "http://clarin.ids-mannheim.de/standards/menu" at "../modules/menu.xql";
import module namespace app = "http://clarin.ids-mannheim.de/standards/app" at "../modules/app.xql";
import module namespace fm = "http://clarin.ids-mannheim.de/standards/format-module" at "../modules/format.xql";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "html";
declare option output:media-type "text/html";
declare option output:indent "yes";
declare option output:html-version "5";

(: 
    @author margaretha
:)

<html lang="en">
    <head>
        <title>Missing Format Descriptions</title>
        <link rel="icon" type="image/x-icon" href="{app:favicon()}"/>
        <link rel="stylesheet" type="text/css" href="{app:resource("style.css", "css")}"/>
        <script type="text/javascript" src="{app:resource("edit.js", "js")}"/>
        <script type="text/javascript" src="{app:resource("utils.js", "js")}"/>
        <script type="text/javascript" src="{app:resource("session.js", "js")}"/>
    </head>
    <body>
        <div id="all">
            <div class="logoheader"/>
            {menu:view()}
            <div class="content">
                <div class="navigation">
                    &gt; <a href="{app:link("views/list-formats.xq")}">Data Deposition Formats</a>
                    &gt; <a href="{app:link("views/list-missing-formats.xq")}">Missing Format Descriptions</a>
                </div>
                <div class="title">Missing Format Descriptions</div>
                  <div>
                    <p>This page lists formats that have not got any description yet, as well as formats where 
                       the name used in recommendations does not match the format description (or the format 
                       description is not present). Do feel welcome to help us extend the list and/or the descriptions, 
                       either by 
                    <a href="{app:getGithubIssueLink()}">submitting an issue at GitHub</a> 
                    containing suggested text or corrections, or by editing or adding the relevant 
                    <a href="https://github.com/clarin-eric/standards/tree/formats/SIS/clarin/data/formats">format file</a> 
                    and submitting a pull request)</p>
                  </div>
                <div>
               <p class="heading">List of missing formats by ID ({fm:count-missing-format-ids()}): </p>
               <div><p>Clicking on an ID below will open a pre-configured GitHub issue where you can suggest the content of the format description.</p></div>
                <ul class="column" style="padding:0px; margin-left:15px;">
                    {fm:list-missing-format-ids()}
                </ul>

               <p class="heading">Existing format descriptions not referenced by any recommendation ({fm:count-orphan-format-ids()}): </p>
                <ul class="column" style="padding:0px; margin-left:15px;">
                    {fm:list-orphan-format-ids()}
                </ul>
                <div>
                <p>Note that membership in this list does not automatically indicate an error. Recommendations may change, and 
                we may sometimes want to describe "unspecified" versions of formats, while their particular variants are 
                used in recommendations (because finer granularity is usually better).</p>
                </div>
              

                   <p class="heading">List of format names used in recommendations that are not present in format descriptions: </p>
                <div>
                <p>This list is of very limited value and will disappear once we switch to only using format IDs in recommendations.</p>
                </div>

                <ul class="column" style="padding:0px; margin-left:15px;">
                    {fm:list-missing-format-abbrs()}
                </ul>
                </div>
            </div>
            <div class="footer">{app:footer()}</div>
        </div>
    </body>
</html>