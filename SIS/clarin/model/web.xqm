xquery version "3.0";


module namespace web = "https://clarin.ids-mannheim.de/standards/web";

declare variable $web:commitId := doc('/data/commit-id.xml')/commitId/text();

declare function web:get-short-commitId(){
    fn:substring($web:commitId,1,8)
};
