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
  %rest:path('/clarin/views/watchtower.xq')
  %output:method('html')
  %output:media-type("text/html")
  %output:indent("yes")
  %output:html-version("5")
function sis:print() as element(html) {

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
                  }}
              </script>
              
              
              <script type="text/javascript" src="{app:resource("session.js", "js")}"/>
          </head>
          <body>
               <!--body-->
               <div id="all">
                   <div class="logoheader"/>
                   {menu:view("Standards Watchtower")}
                  <div class="content">
                      <div class="navigation">&gt; <a href="{app:link("views/watchtower.xq")}">Standards Watchtower</a></div>
                      
                      <div class="title">Standards Watchtower</div>
                      
                      <div>
                      
                      <p>Standards Watchtower is the name of the running project of the CLARIN Standards and Interoperability 
                      Committee, where it is possible to trace the relationships among existing standards of various kinds and status,
                      as well as the appearance (and demise...) of practices and trends that may lead to the establishment of new 
                      standards. We stress that this is an effort open to anyone interested and dependent on the needs and sensitivity 
                      of its users: we welcome submissions from anyone willing to share standards-related information with others, via 
                      <a title="Open a new GitHub issue" href="https://github.com/clarin-eric/standards/issues/new?assignees=&amp;labels=SIS%3AWatchtower%2C+UserInput&amp;title=Watchtower%3A new information">GitHub issues</a> 
                      or GitHub pull requests.</p>
                     
                      <h2 id="waiting_room">Waiting room</h2>
                      <p>This section lists "points of interest" that may be standards or best practices not yet woven into the SIS-internal 
                      network of relationships. For the time being, access to it is via GitHub, and, in time, we shall see if it needs
                      some more intricate ways of sharing information about standards-related issues that pop up in the field. (Please
                      feel very welcome to share your feedback and to share information that you consider worth mentioning here and eventually 
                      in the SIS internals.)</p>
                      <table cols="3">
                      <thead>
                      <tr>
                      <th>Date</th>
                      <th>Link (inactive)</th>
                      <th>Short description</th>
                      <th>Remarks</th>
                      </tr>
                      </thead>
                      <tbody>
                      <tr>
                      <td>2024-12-01</td>
                       <td>https://www.iso.org/standard/79083.html</td>
  <td>New ISO standard, ISO/DIS 24635-1, Language ​ resource ​
  management ​ — ​ Corpus ​ Annotation ​ Project ​ Management ​ — ​ Part ​ 1: ​ Core ​ model</td>
                       <td>About to be published, not sure if shareable in the SIC, ask Piotr if interested</td>
                      </tr>
                      <tr>
                      <td>2024-12-01</td>
                       <td>https://techpolicylab.uw.edu/data-statements/</td>
  <td>Data Statements for language datasets for NLP</td>
                       <td>potential good practice, maybe a <i>de facto</i></td>
                      </tr>
                      </tbody>
                      </table>
                      
                      <p><a title="Open a new GitHub issue" href="https://github.com/clarin-eric/standards/issues/new?assignees=&amp;labels=SIS%3AWatchtower%2C+UserInput%2C+templatic&amp;projects=&amp;template=watchtower_submission.md&amp;title=Watchtower%3A+new+submission">Add an entry suggestion</a>
                      (opens a new GitHub issue with a template for structured input).</p>
                      <p>Entries from the above table will be deleted once the item in question is integrated with the SIS or discarded.</p>                      
                      
                      </div>                      
                  </div>
                  <div class="footer">{app:footer()}</div>
              </div>
          </body>
      </html>
};