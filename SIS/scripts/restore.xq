xquery version "3.0";

(: use in the XQuery window of the Java client in order to repair the apps when needed.
   https://exist-db.org/exist/apps/doc/backup.xml :)

import module namespace repair="http://exist-db.org/xquery/repo/repair" 
at "resource:org/exist/xquery/modules/expathrepo/repair.xql";

repair:clean-all(),
repair:repair()