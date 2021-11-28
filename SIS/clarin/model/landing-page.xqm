xquery version "3.0";

module namespace landing-page="http://clarin.ids-mannheim.de/standards/landing-page";

declare variable $landing-page:locations := doc("../data/landing-pages.xml")/landingPages/landingPage;