
 <ul>
{
for $x in doc("Example_XML.xml") /info/biblStruct/analytic/title
order by $x
return <li>{$x}</li>
}
</ul> 
