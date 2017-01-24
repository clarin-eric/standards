  fields = 0;

  function addVersion(num,relations,targets){   
    
    var index = fields+1
    
    if (fields+num != 5) {
        document.getElementById('text').appendChild(writeElement("version",index,"Version Number:",""))
        document.getElementById('text').appendChild(writeElement("date",index,"Release Date:","YYYY-MM-DD"))
        document.getElementById('text').appendChild(writeElement("reference",index,"Reference:",""))
        document.getElementById('text').appendChild(writeRelation(index,relations,targets))
        document.getElementById('text').appendChild(writeLine())  
        fields += 1;
    } 
    else {
        t = document.createTextNode("Max 5 versions.");
        b = document.createElement("span")
        s1.style.display = "block"
        b.appendChild(t)
        document.getElementById('text').appendChild(b)
        document.forms["addForm"]["addButton"].disabled=true;
    }
  }
 
 
 function writeLine(){
    td1 = document.createElement("td")
    td1.height = "15"
    td1.colSpan ="2"
    
    line = document.createElement("hr")
    line.style.border = "0"
    line.style.color = "#DDDDDD"
    line.style.backgroundColor = "#DDDDDD"
    line.style.height = "1px"
    td1.appendChild(line)
    
    tr = document.createElement("tr")
    tr.appendChild(td1)
    return tr
 } 
 
 function writeRelation(index,relations,targets){
    
    td1 = document.createElement("td")
    b = document.createElement("b")
    text = document.createTextNode("Relation:");
    b.appendChild(text)
    td1.appendChild(b)
    
    td2 = document.createElement("td")
    s1 = document.createElement('select');
    s1.name="relation"+index
    s1.className = "inputSelect"
    s1.style.width = "150px"    
    s1.style.marginRight = "3px"
    s1.appendChild(document.createElement('option'))
    
    for (x in relations){
        opText = document.createTextNode(relations[x]);
        op = document.createElement('option');
        op.value = relations[x]
        op.appendChild(opText)
        s1.appendChild(op)
    }
    
    s2 = document.createElement('select');
    s2.name="relation-target"+index
    s2.className = "inputSelect"
    s2.style.width = "250px"    
    s2.appendChild(document.createElement('option'))
    
    for (x in targets){
        opText = document.createTextNode(targets[x][1]);
        op = document.createElement('option');
        op.value = targets[x][0]
        op.appendChild(opText)
        s2.appendChild(op)
    }
    td2.appendChild(s1)
    td2.appendChild(s2)
    
    tr = document.createElement("tr")
    tr.appendChild(td1)
    tr.appendChild(td2)
    return tr
 }
 
  function writeElement(element,index,textnode,placetext){
    td1 = document.createElement("td")
    b = document.createElement("b")
    text = document.createTextNode(textnode);
    b.appendChild(text)
    td1.appendChild(b)
    
    td2 = document.createElement("td")
    i = document.createElement('input');
    i.type='text';
    i.name=element+index
    i.style.width = "400px"    
    i.className = "inputText"
    i.placeholder= placetext
    td2.appendChild(i)
    
    tr = document.createElement("tr")
    tr.appendChild(td1)
    tr.appendChild(td2)
    return tr
  }
  