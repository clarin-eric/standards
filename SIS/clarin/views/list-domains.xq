xquery version "3.1";

import module namespace menu = "http://clarin.ids-mannheim.de/standards/menu" at "../modules/menu.xql";
import module namespace app = "http://clarin.ids-mannheim.de/standards/app" at "../modules/app.xql";
import module namespace dm = "http://clarin.ids-mannheim.de/standards/domain-module" at "../modules/domain.xql";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "html";
declare option output:media-type "text/html";
declare option output:indent "yes";
declare option output:html-version "5";

(:  
    @author banski, margaretha
:)

<html lang="en">
    <head>
        <title>Functional domains</title>
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
                    &gt; <a href="{app:link("views/recommended-formats-with-search.xq")}">Format Recommendations</a>
                    &gt; <a href="{app:link("views/list-domains.xq")}">Functional Domains</a>
                </div>
                <div class="title">Functional domains</div>
                
                <div>
                    <p>In order to arrive at adequate recommendations concerning individual file formats and standards, or to decide on their suitability in 
                    particular kinds of research, the purpose for which they are intended has to be taken into account. For example, while PDF/A has been 
                    developed for unproblematic long-term archiving and is an excellent format choice for (unstructured) documentation, i.e. documents 
                    containing a corpus manual, corpus guidelines or the annotation guidelines applied for the project, it is undoubtedly <i>not</i> suitable 
                    as a format for annotated corpus data. That demonstrates that recommending PDF/A or any other format to researchers and data 
                    depositors without information on the intended purpose of that format is bound to create issues rather than solve them. Therefore, the 
                    CLARIN <a href="https://www.clarin.eu/content/standards">Standards and Interoperability Committee</a> has, by reviewing the policies and 
                    deposited data of CLARIN centres, suggested a set of functional domains representing purposes specifically relevant to the field of digital 
                    language resources.</p>
                    <p>It has to be borne in mind that the set of functional domains described below has been mainly designed to be useful in the practical 
                    work of the Standards and Interoperability Committee in gathering information on standards and data formats currently in use within CLARIN. 
                    It does not claim or aim to be a complete and detailed taxonomy and does not reflect all possible distinctions between different resource (sub)types. 
                    The Standards and Interoperability Committee acknowledges that in order to make an individual recommendation on suitable formats to be used within a specific 
                    research project, more subtle differences usually become relevant. As an example, the most suitable data format for a corpus will not only 
                    depend on whether it is based on audiovisual or textual source data, but also on the complexity of the source data and the annotation 
                    schemes and possibly interoperability with relevant existing resources within the same research area.</p>
                    <p>For pragmatic reasons, some domains are very broad, e.g. the Tool Support domain comprises highly different information types, which however 
                    share the purpose of enabling the use of tools or services. Conversely, a single format might serve several purposes, e.g. when CMDI is 
                    being used for all types of metadata and contextual information, or when TEI is used to model both text annotations and contextual information 
                    (please note, however, that we want to avoid using plain "TEI" or plain "XML", without specifying the concrete schema, because such broad, 
                    unqualified format names are rather meaningless in the intended context). The focus on formats that are likely to be a part of digital 
                    language resources created and deposited by researchers in the humanities and social sciences further implies a conscious reduction of the 
                    scope of the taxonomy.</p>
                    <p>Below, we list the functional domains currently defined in the SIS, with a brief characterization of each. They have been gathered into several 
                    groups ("metadomains"), in order to make it easier to perceive their commonalities. Metadomains are pure convenience groupings and when a functional domain 
                    does not appear to usefully aggregate with some other(s), it is simply left uncategorised -- perhaps until more similar domains get recognised.</p>
                    <p>The pseudodomain "Other" is another convenience grouping -- it's an "elsewhere" domain, which, by design, should be used when a centre makes a 
                    recommendation concerning a data format but the function of that format is either not fully clear or, perhaps, not yet recognised by the SIS (such 
                    was the case of formats used in machine learning). Please do not hesitate to suggest additions of modifications to the classification presented 
                    below -- it is not meant to be set in stone, especially in view of the fact that the SIS is able to serve research infrastructures focussing 
                    on data that are not solely of linguistic nature.</p>
                </div>
                <div>
                    <ul style="padding:0px; margin-left:15px;">
                        {dm:list-domains-grouped()}
                    </ul>
                </div>
            </div>
            <div class="footer">{app:footer()}</div>
        </div>
    </body>
</html>