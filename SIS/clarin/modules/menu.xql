xquery version "1.0";

module namespace menu = "http://clarin.ids-mannheim.de/standards/menu";
import module namespace app="http://clarin.ids-mannheim.de/standards/app" at "app.xql";

(:  Define the menu
    @author margaretha
:)

declare function menu:view(){
    <div class="menu" xmlns="http://www.w3.org/1999/xhtml">    
        <div style="margin-left:0px;">
           <table style="font-size:13.5px; width:200px">
                <tr>
                    <td colspan="2" class="tdmenu">
                        <a style="display:block" href="{app:link("index.xq")}">Home</a>
                    </td>
                </tr>               
                <tr>
                    <td colspan="2" class="tdmenu">
                        <a style="display:block"  href="{app:link("views/list-specs.xq?sortBy=name&amp;page=1")}">Standards</a>
                    </td>
                </tr>
                {if (session:get-attribute("user") = 'webadmin' or session:get-attribute("user") = 'user')
                 then                   
                    <tr>
                        <td width="15px"></td>
                        <td class="tdmenu">
                        <a style="display:block"  href="{app:link("views/register-spec.xq")}">Register</a>
                        </td>
                    </tr>
                 else()
                }   
                <tr>
                    <td colspan="2" class="tdmenu">
                        <a style="display:block"  href="{app:link("views/recommendation.xq")}">Recommendations</a>
                    </td>
               </tr>
                <tr>
                    <td colspan="2" class="tdmenu">
                        <a style="display:block"  href="{app:link("views/list-sbs.xq")}">Standard bodies</a>
                    </td>
               </tr>               
               <tr>                    
                    <td colspan="2" class="tdmenu">
                        <a style="display:block"  href="{app:link("views/list-topics.xq")}">Topics</a>
                    </td>
                </tr>
                <tr>
                    <td colspan="2" class="tdmenu">
                        <a style="display:block"  href="{app:link("search/search-spec.xq")}">Search</a>
                    </td>
                </tr>
                <tr>
                    <td colspan="2" class="tdmenu">
                        <a style="display:block" href="{app:link("views/contact.xq")}">Contact</a>
                    </td>
               </tr>
               <tr><td colspan="2" height="20px"/></tr>               
               { if (not(session:get-attribute("user")))
                 then (
                    <tr>
                        <td colspan="2" class="tdmenu">
                            <a style="display:block" href="{app:link("user/login.xq")}">Login</a>
                        </td>
                    </tr>,
                    <tr>
                        <td colspan="2" class="tdmenu">
                            <a style="display:block" href="{app:link("user/register.xq")}">Register</a>
                        </td>
                    </tr>                
                 )
                 else
                    <tr>
                        <td colspan="2" class="tdmenu">
                            <a style="display:block" href="{app:link("user/logout.xq")}">Logout</a>
                        </td>
                   </tr>
                }
           </table>
        </div>       
    </div>
};


