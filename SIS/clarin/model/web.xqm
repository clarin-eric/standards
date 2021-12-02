xquery version "3.0";


module namespace web = "https://clarin.ids-mannheim.de/standards/web";

declare variable $web:commitId := doc('/db/apps/clarin/commit-id.xml')/commitId;
