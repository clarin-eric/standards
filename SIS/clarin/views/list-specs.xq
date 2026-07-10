xquery version "3.1";

module namespace sis = 'sis';

import module namespace menu = "http://clarin.ids-mannheim.de/standards/menu" at "../modules/menu.xql";
import module namespace app = "http://clarin.ids-mannheim.de/standards/app" at "../modules/app.xql";
import module namespace lsm = "http://clarin.ids-mannheim.de/standards/list-spec" at "../modules/list-spec.xql";
import module namespace spec = "http://clarin.ids-mannheim.de/standards/specification" at "../model/spec.xqm";

import module namespace index="http://clarin.ids-mannheim.de/standards/index" at "../modules/index.xql";

(: Define the list of spec page
   @author margaretha
:)

declare
  %rest:path('/clarin/views/list-specs.xq')
  %output:method('html')
  %output:media-type("text/html")
  %output:indent("yes")
  %output:html-version("5")
function sis:print() as element(html) {

  let $sortBy := request:parameter('sortBy', '')
  let $page := request:parameter('page', '')
  let $letter := request:parameter('letter', '')
  let $spec-group := lsm:group-specs($page, $sortBy, $letter)
  let $spec-relations := $spec-group//relation
  
  return
     (: if ($spec-relations)
      then lsm:get-spec-json($spec-group, $spec-relations)
      else :)
      <html lang="en">
          <head>
              <title>Standards Watchtower</title>
              <link rel="icon" type="image/x-icon" href="{app:favicon()}"/>
              <link rel="stylesheet" type="text/css" href="{app:resource("style.css", "css")}"/>
              
              <script>
                    document.addEventListener('DOMContentLoaded', function() {{
                    window.onload=init();
                  }});
                  
                  function init(){{
                      checkActiveRI();
                      
                      drawGraph('{lsm:get-spec-json($spec-group, $spec-relations)}','650','550','-90');
                  }}
              </script>
              <script type="text/javascript" src="{app:resource("d3.v2.js", "js")}"/>
              <script type="text/javascript" src="{app:resource("forcegraph.js", "js")}"/>
              
              <script type="text/javascript" src="{app:resource("session.js", "js")}"/>
          </head>
          <body>
               <!--body-->
           <div id="all">
               <a class="logoheader" href="https://www.clarin.eu/"/>
                   {menu:view("Standards and Specifications")}
                  <div class="content">
                      <div class="navigation">
                      &gt; <a href="{app:link("views/watchtower.xq")}">Standards Watchtower</a>                      
                      &gt; <a href="{app:link("views/list-specs.xq?sortBy=name&amp;page=1")}">Standards and Specifications</a>
                          {
                              if ($letter) then
                                  (" > ",
                                  <a href="{app:link(concat("views/list-specs.xq?sortBy=name&amp;page=1&amp;letter=", $letter))}">
                                      {$letter}</a>)
                              else
                                  ()
                          }
                      </div>
                      
                      <div class="title">Standards and Specifications</div>                                                               
                      
                      <div id="list">
                      
                      <p><b>Note</b>: information provided in this part of the Standards Information System may be outdated. 
                      This means that the relationships between standards and specifications listed here are still valid, 
                      but some new versions (and consequently new relationships) may still be missing. Since this is an 
                      open system, you are cordially invited to help extend it, either by 
                      <a title="Open a new GitHub issue" href="https://github.com/clarin-eric/standards/issues/new?assignees=&amp;labels=Watchtower%2C+UserInput&amp;title=Watchtower:info correction">posting a ticket</a> 
                      to suggest a correction to missing or incorrect information, or by forking/cloning the source and submitting 
                      your additions via a pull request.</p>
  
                          <p>The table below lists the {$lsm:spec-sum} standards and specifications described in this website. You can get more 
                          information about a standard or a specification by clicking on the abbreviations. When hovering over an abbreviation, 
                          the standard/specification name will be shown on a tooltip. The topic column shows which area(s) a standard belongs 
                          to, and the resonsibility column shows the person, organization or standardization body that has developed or 
                          currently maintains the standard/specification. The CLARIN Centre(s) column shows which clarin centres using a 
                          particular standard/specification. </p>
                          <p>To sort the table below by topic, responsibility or CLARIN centre, please click on the corresponding column header. 
                          You can also filter the standards by the first letter of their abbreviation or name, by clicking on a letter below.</p>
                          <p>Please note that the information concerning centre recommendations for particular standards should be considered 
                          outdated and will change with the upcoming revisions of the Standards Information System. Please refer to the 
                          "<a href="{app:link("views/recommended-formats-with-search.xq")}">Format Recommendations</a>" page for up-to-date 
                          information on centre recommendations concerning standard / specification serializations (file formats) that may be 
                          used to exchange data.</p>
                      </div>
                      
                      <div id="spec-table">{lsm:letter-filter()}</div>
                      
                      {
                          if (count($spec-group) > 0)
                          then
                              (
                              <table cellspacing="4px" style="width:97%">
                                  <tr>
                                      {lsm:header("name", $sortBy, $page, $letter)}
                                      {lsm:header("topic", $sortBy, $page, $letter)}
                                      {lsm:header("org", $sortBy, $page, $letter)}
                                    <!-- {lsm:header("clarin-centres", $sortBy, $page, $letter)} -->
                                      <!--{lsm:header("clarin-approved", $sortBy, $page)}-->
                                  </tr>
                                  {lsm:list-specs($spec-group, $sortBy, $letter)}
                              </table>,
                              <div style="text-align:centre">
                                  {
                                      if ($letter) then
                                          <br/>
                                      else
                                          lsm:page($sortBy, $page)
                                  }
                              </div>,
                              <div id="chart" class="version">
                              </div>,
                              <div class="version" style="width:380px; padding:0px">
                                  <table>
                                      <tr>
                                          <td colspan="2" style="width:170px"><b>Legend:</b></td>
                                          <td colspan="2" style="width:170px"></td>
                                      </tr>
                                      {lsm:get-legend($spec-relations)}
                                  </table>
                              </div>
                              )
                          else
                              <div>No standards are found.</div>
                      }
                  </div>
                  <div class="footer">{app:footer()}</div>
              </div>
          </body>
      </html>
};