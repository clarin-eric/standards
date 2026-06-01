xquery version "3.1";

module namespace web = "https://clarin.ids-mannheim.de/standards/web";

declare variable $web:commitId as xs:string? := 
  try {
    doc('/data/commit-id.xml')/commitId/text()
  } catch * {
    "unavailable"
  };

declare function web:get-short-commitId() as xs:string {
  if ($web:commitId = "unavailable") then
    "unavailable"
  else
    fn:substring($web:commitId, 1, 8)
};