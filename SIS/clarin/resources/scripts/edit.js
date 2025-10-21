fields=1; nkeys=0; nrefs=0; nprefs=0; npvrefs=0; nvrefs=0; ntopics=0; nrels=0; ndesc=1; 
nurls={}; nvrels={}; nrefv={}
npids=new Array(); relation=[]; reltarget=[]; 
if (typeof String.prototype.startsWith != 'function') {
    String.prototype.startsWith = function (str){
      return this.slice(0, str.length) == str;
    };
}

function escapeHtml(unsafe) {
    return unsafe
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#039;");
}

function showResp(resptype,resporg,respname){
	e = document.getElementById(resptype);
	if (e.options[e.selectedIndex].value == 'person'){
        document.getElementById(respname).style.display = 'inline';
        document.getElementById(resporg).style.display = 'none';
    }
	else if (e.options[e.selectedIndex].value == 'org'){		
		document.getElementById(respname).style.display = 'none';
		document.getElementById(resporg).style.display = 'inline';
	}
	else {
		document.getElementById(respname).style.display = 'none';
	    document.getElementById(resporg).style.display = 'none';
	}
}

function openEditor(frame){   
    if (frame){ 
        if (document.getElementById(frame).style.display == "none")
            document.getElementById(frame).style.display = 'block';
        else 
            document.getElementById(frame).style.display = 'none';    
    }
}

function generatePid(){
    var chars = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXTZabcdefghiklmnopqrstuvwxyz";
    var string_length = 6;
	var randomstring = chars.charAt(Math.floor(Math.random() * (chars.length-10)) +10);
	for (var i=1; i<string_length; i++) {
	   randomstring += chars.charAt(Math.floor(Math.random() * chars.length));
	}
    
    return randomstring
}

function getPid(path,field){
    field = field.toString()
    l = field.length
    
    if(path == "vno" ||path.startsWith('resp') || path.startsWith('newresp')){
        pid=field;
    }    
    else if (path.startsWith('vurl')){        
        pid=path.substring(4,path.length)
    }
    else if (path.startsWith('vrel')){
        pid = document.getElementById(path+'pid').innerHTML                
    } 
    else if (field.startsWith('newtext')){
        pid=field.substring(l-6,l)
    }
    else if (field.startsWith('vname') || field.startsWith('vabbr') || field.startsWith('vdate')){        
        pid=field.substring(5,l)        
    }
    else if (field.startsWith('features')){
        pid=field.substring(8,l)
    }
    else if (field.startsWith('vstatus')){
        pid=field.substring(7,l)
    }
    else (pid='')    
    return pid
};

function getValue(path,field){
    var val = "";
    if(path=='topic'){        
        for (i=0; i<field+ntopics; i++){
            e = document.getElementById(path+(i+1))
            if (e){
                r = e.options[e.selectedIndex].value
                if (r !="") {val = val+r+" "}
            }
        }
        val = val.substring(0, val.length - 1);
    }
    else if (path=="abbr"){
        e = document.getElementById(field+"internal")
        s = e.options[e.selectedIndex].value        
        val = document.getElementById(path).value+"#"+s
    }
    else if (path =='key'){        
        for (i=0; i<(field+nkeys); i++){            
            e = document.getElementById(path+(i+1)).value            
            if (e !="") {val = val+e+","}
        }
       val = val.substring(0, val.length - 1);
    }
    else if (path =='vstatus'){        
        e = document.getElementById(field)            
        if (e) 
            val = e.options[e.selectedIndex].value       
    } 
    else if (path =='vno'){
        vnomajor = document.getElementById(path+"major"+field).value
        vnominor = document.getElementById(path+"minor"+field).value
        val = vnomajor + "###" + vnominor
    }
    else if (path.startsWith('resp') || path.startsWith('newresp')){
        respid = path.substring(4,path.length)        
        resp = document.getElementById("resp"+respid).value        
        resptype = document.getElementById("resptype"+respid).value
        respnames = document.getElementById("respname"+respid).value
        resporg = document.getElementById("resporg"+respid).value
        //alert(resporg)
        if (resp && resptype == 'person' && respnames != null && respnames!=''){
            val = resp+"###"+resptype+"###"+ respnames
        }
        else if (resp && resptype == 'org' && resporg!=null && resporg !=''){            
            val = resp+"###"+resptype+"###"+ resporg
        }
        else val=''
        
    }    
    else if (path.startsWith('vurl')){       
       if (nurls.hasOwnProperty(path)== '') nurls[path] = 0       
       for (i=0; i<(field+nurls[path]); i++){       
            e = document.getElementById(path+(i+1)).value            
            if (e !="") {val = val+e+"--"}
        }
       val = val.substring(0, val.length - 2);
    }
    else if (path.startsWith('vrel') || path.startsWith('newvrel')){
        e = document.getElementById(path)
        if (e) type = e.options[e.selectedIndex].value
        
        f = document.getElementById(path+'target')
        if (f) target = f.options[f.selectedIndex].value
        
        d = document.getElementById(path+'desc').value
        val = type+"--"+target+"--"+d        
    }
    else {val= document.getElementById(field).value}    
    return val
}

function setrel(r,rt){
    relation = r; reltarget=rt; 
}

function removeElement(specid,path,val){
    if(path.startsWith('vrel')){
        element = document.getElementById(path+'link').innerHTML
        val = document.getElementById(path+'pid').innerHTML
    }else {
        element = val
    }
    
    if (confirm('Are you sure you want to remove "'+element+'"?')) {
        var xmlhttp;    
        if (window.XMLHttpRequest) {// code for IE7+, Firefox, Chrome, Opera, Safari
          xmlhttp=new XMLHttpRequest();}
        else {// code for IE6, IE5
          xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");}
            
        xmlhttp.onreadystatechange=function(){
          if (xmlhttp.readyState==4 && xmlhttp.status==200){          
             if(path.startsWith('vrel')){
                document.getElementById(path+'li').style.display="none"
                document.getElementById('edit'+path).style.display="none"
             }
             else { 
                document.getElementById(path).style.display="none"
                document.getElementById(path+"button").style.display="none"
            }            
          }
        }
        
        xmlhttp.open("POST","../edit/edit-process.xq",true);
        xmlhttp.setRequestHeader("Content-type","application/x-www-form-urlencoded");
        xmlhttp.send("id="+specid+"&path="+path+"&value="+val+"&task=remove");
    }    
}

function removeErr(field,cname,err){
    document.getElementById(field).className = cname;
    if (err)
        document.getElementById(err).style.display = 'none';
}

function markErr(element){
    className = document.getElementById(element).className
    if (className.contains("Error")) {}
    else document.getElementById(element).className = className+"Error";
}

function update(specid,path,field,frame){
    var xmlhttp;    
    if (window.XMLHttpRequest) // code for IE7+, Firefox, Chrome, Opera, Safari
      xmlhttp=new XMLHttpRequest();
    else // code for IE6, IE5
      xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");

    xmlhttp.onreadystatechange=function(){
      if (xmlhttp.readyState==4 && xmlhttp.status==200)
      {  // alert("response "+xmlhttp.responseText)
            if (path == 'vno'){
                if (xmlhttp.responseText == "empty") 
                    document.getElementById("error"+path+field).style.display="block"
                else {              
                    vno = xmlhttp.responseText.split("###")                    
                    if (vno[0]!="") { document.getElementById(path+"major"+field+"text").innerHTML=vno[0] }
                    else { document.getElementById(path+"major"+field+"text").innerHTML="" }
                    
                    if (vno[1]!="") { document.getElementById(path+"minor"+field+"text").innerHTML=vno[1] }
                    else { document.getElementById(path+"minor"+field+"text").innerHTML="" }                    
                    document.getElementById(frame).style.display = 'none';
                }
            }
            else if (path.startsWith('vurl')){
                if (xmlhttp.responseText == "empty") markErr(path+"1")
                else writeURLResponse(xmlhttp.responseText,pid,path,frame)
            }
            else if (path.startsWith('vrel')){
               response = xmlhttp.responseText
               if (response == "empty"){
                    markErr(path)
                    markErr(path+"target")
                }
                else {
                    if (response.indexOf("--")>-1){ result = response.split("--")}
                    else result = [response]
                    writeRelResponse(result,path,frame,path)        
                }
            }
            else if (path.startsWith('newvrel')){                
                response = xmlhttp.responseText
                if (response == "empty"){
                    markErr(path)
                    markErr(path+"target")
                }
                else {
                    if (response.indexOf("--")>-1){ result = response.split("--")}
                    else result = [response]
                    
                    if (result[0]){
                        if (response.indexOf('errortype') >-1 || response.indexOf('errortarget') >-1) {
                            writeRelResponse(result,path,frame,path) }
                        else {
                            vid = path.substring(7,path.length)    
                            if (nvrels.hasOwnProperty(path)== '') nvrels[path] = field
                            nvrels[path] +=1
                            newpath = "vrel"+vid+"--"+nvrels[path]                            
                            createRelation(result,newpath,specid,path)
                            writeRelResponse(result,newpath,frame,path)
                        }
                    }
                }
            }            
            else if (xmlhttp.responseText == 'empty'){
                if (path == "topic")
                    document.getElementById(path+"1").className = 'inputSelectError';
                else if (path == "key") 
                    document.getElementById(path+"1").className = 'inputTextError';
                else if (path.contains("resp")){
                    document.getElementById(path).className = "inputTextError"; 
                }                    
                else markErr(field)
            }
            else if (path == 'abbr' || path == "vabbr"){                
              document.getElementById(path+"text").innerHTML=xmlhttp.responseText;
              att = document.getElementById(field+"internal")              
              if (att.options[att.selectedIndex].value == "internal"){
                  document.getElementById(field+"internalText").style.display = "inline"
              }else document.getElementById(field+"internalText").style.display = "none"                
              document.getElementById(frame).style.display = 'none';
                  
              if (document.getElementById(path).className.contains("Error")) 
                  document.getElementById(path).className = "inputText"
            }            
            else if (xmlhttp.responseText == 'invalid'){
                alert("The XML input is invalid.")
            }
            else if (path.startsWith('resp')){
                writeRespStmtResponse("edit",xmlhttp.responseText,path,specid,pid,frame)                
            }
            else if (path.startsWith('newresp')){       
                writeRespStmtResponse("add",xmlhttp.responseText,path,specid,pid,frame)
            }
            else if (path.startsWith('features')){
               if (xmlhttp.responseText) {
                    ul = xmlhttp.responseText.split("--")
                    li=''
                    for (i=0; i<ul.length; i++){
                         items = ul[i].split("++") 
                         li += "<li>"+items[0]+": "+items[1]+"</li>"
                    }               
                    document.getElementById(field+'text').innerHTML="<ul>"+li+"</ul>"               
                    
                }else {
                    document.getElementById(field+'text').innerHTML=""
                }
                document.getElementById(frame).style.display = 'none';
            }
            else if (path.startsWith('desc') && !xmlhttp.responseText.startsWith("<info")){
                alert (xmlhttp.responseText)
            }
            else {
                document.getElementById(frame).style.display = 'none';
                document.getElementById(path+"text").innerHTML=xmlhttp.responseText;
                
                if(path=="topic" && document.getElementById(path+"1").className.contains("Error")){
                    document.getElementById(path+"1").className = "inputSelect" }                
                else if (document.getElementById(field).className.contains("Error")) {
                    className = document.getElementById(field).className;
                    document.getElementById(field).className = className.substring(0,className.length-5)
                }
            }            
        }
    }
    
    pid = getPid(path,field)
    val = getValue(path,field)
    
   // alert("id="+specid+"&path="+path+"&value="+val+"&pid="+pid);
    
    xmlhttp.open("POST","../edit/edit-process.xq",true);
    xmlhttp.setRequestHeader("Content-type","application/x-www-form-urlencoded");
    xmlhttp.send("id="+specid+"&path="+path+"&value="+val+"&pid="+pid);
}

function addTopic(parent,id,options){
    index = id+ntopics; ntopics++
    var i = document.createElement("select")
    i.id=parent+(index+1)
    i.name="topic"+(index+1)
    i.className="inputSelect"
    i.style.marginBottom="3px"
    i.style.display="inline"
    
    i.appendChild(document.createElement('option'))
    for (x in options){
        opText = document.createTextNode(options[x][1]);
        op = document.createElement('option');
        op.value = options[x][0]
        op.appendChild(opText)
        i.appendChild(op)
    }
    b= document.getElementById(parent+index)
    b.parentNode.appendChild(i)
  
};

function addRelation(parent,relation,target,description,id,relops,targetops){
    index = id+nrels; nrels++
    
    var s1 = document.createElement("select")
    s1.id=relation+(index+1)
    s1.name=relation+(index+1)
    s1.className="inputSelect"
    s1.style.marginRight="3px"
    s1.style.width="173px"    
    s1.appendChild(document.createElement('option'))
    for (x in relops){
        opText = document.createTextNode(relops[x]);
        op = document.createElement('option');
        op.value = relops[x]
        op.appendChild(opText)
        s1.appendChild(op)
    }
    
    var s2 = document.createElement("select")
    s2.id=target+(index+1)
    s2.name=target+(index+1)
    s2.className="inputSelect"    
    s2.style.width="280px"    
    s2.appendChild(document.createElement('option'))
    for (x in targetops){
        opText = document.createTextNode(targetops[x][1]);
        op = document.createElement('option');
        op.value = targetops[x][0]
        op.appendChild(opText)
        s2.appendChild(op)
    }
    
    var ta = document.createElement("textarea")
    ta.id=description+(index+1)
    ta.name=description+(index+1)
    ta.className="inputText"
    ta.placeholder="Describe some relation info here. Use html format such as <p> to make a paragraph."
    ta.style.width="450px";ta.style.height="50px"; ta.style.resize="none"; ta.style.fontSize="11px"
    
    tr = document.createElement("tr")
    tr.id = parent+(index+1)
    td1 = document.createElement("td")
    td2 = document.createElement("td")
    td2.appendChild(s1);td2.appendChild(s2);td2.appendChild(ta);
    td3 = document.createElement("td")
    tr.appendChild(td1);tr.appendChild(td2);tr.appendChild(td3);
    
    b= document.getElementById(parent+index)
    b.parentNode.insertBefore(tr,b.nextSibling)
}

function addElement(parent,element,type,id){
    if (parent=="key") {index = id+nkeys; nkeys++; cname="inputText"; d="inline"}
    else if (parent.startsWith("ref")) {index = id+nrefs; nrefs++; cname="inputFile"; d="block"}
    else if (parent=="pref") {index = id+nprefs; nprefs++; cname="inputFile"; d="block"}
    else if (parent=="pvref") {index = id+npvrefs; npvrefs++; cname="inputFile"; d="block"}
    else if (parent=="vref") {index = id+nvrefs; nvrefs++; cname="inputFile"; d="block"}
    else if (parent.startsWith("vurl") || parent.startsWith("pvurl")) {        
        if (nurls.hasOwnProperty(parent)== '') nurls[parent] = 0
        index = id+nurls[parent]; nurls[parent] += 1; cname="inputText"; d="block"
    }
    else if (parent.startsWith("refv")) {
        if (nrefv.hasOwnProperty(parent)== '') nrefv[parent] = 0
        index = id+nrefv[parent]; nrefv[parent] += 1; cname="inputFile"; d="block"
    }
    
    
    var i = document.createElement(element)
    i.id=parent+(index+1)
    i.type=type
    i.name=parent+(index+1)
    i.className=cname
    i.style.width="450px"
    i.style.marginBottom="3px"
    i.display=d
    b= document.getElementById(parent+index)
    b.parentNode.appendChild(i)    
}

function addDesc(specid,parentid,pids){    
    allpids = pids.concat(npids)
    newpid = generatePid()        
    while (allpids.indexOf(newpid) > -1){
        newpid = generatePid()        
    }    
    text = document.getElementById("newtext"+parentid).value
    
    if (text){        
        npids.push(newpid)
        
        s = document.createElement("span")
        s.id="desc"+newpid+"text"
        s.appendChild(document.createTextNode(escapeHtml(text))) // New description text        
        // Dummy strings to allocate different element variables
        b1 = createButton("b1","edit","Edit","edit",newpid,specid,pids) // New edit button    
        b2 = createButton("b2","edit","Add","add",newpid,specid,pids) // New add button
        
        p = document.createElement("p"); p.id="desc"+newpid
        p.appendChild(s); p.appendChild(b1); p.appendChild(b2); // New paragraph
        t1 = createBox("t1","b3","ta1",text,"editedtext","editdesc","edit",newpid,specid,pids,'') // New edit box
        t2 = createBox("t2","b4","ta2",'',"newtext","adddesc","add",newpid,specid,pids,"Describe a new paragraph here.") // New add box    
        
        myparent = document.getElementById("adddesc"+parentid)
        myparent.parentNode.insertBefore(t2,myparent.nextSibling) ;
        myparent.parentNode.insertBefore(t1,myparent.nextSibling)
        myparent.parentNode.insertBefore(p,myparent.nextSibling)
        
        document.getElementById("adddesc"+parentid).style.display = 'none';
    }    
    update(specid,"adddesc"+newpid,"newtext"+parentid,"adddesc"+parentid)
}

function createButton(b1,cname,text,purpose,newpid,specid,pids){
    b1 = document.createElement("button")
    
    if (navigator.appName == 'Microsoft Internet Explorer') {        
        if (purpose=="edit")
            b1.onclick=function() {openEditor('editdesc'+newpid);};
        else if (purpose=="add")
            b1.onclick = function() {openEditor('adddesc'+newpid);} 
        else if(purpose=="submitedit")
            b1.onclick = function() {update(specid,'desc'+newpid,'editedtext'+newpid,'editdesc'+newpid)}
        else if(purpose=="submitadd")
            b1.onclick = function() {addDesc(specid,newpid,pids)}
        else if(purpose=="editresp")
            b1.onclick=function() {openEditor('editv'+newpid);};
        else if(purpose=="submiteditresp")
            b1.onclick=function() {update(specid,newpid,pids,'editv'+newpid);};
        else if(purpose=="editURL")
            b1.onclick=function() {openEditor('editvurl'+newpid);};
        else if(purpose=="submiteditURL")
            b1.onclick=function() {update(specid,newpid,pids,'edit'+newpid);};
        else if(purpose=="editRel")
            b1.onclick=function() {openEditor('edit'+newpid);};
        else if(purpose=="removeRel")
            b1.onclick=function() {removeElement(specid,newpid,'');};
        else if(purpose=="submitEditRel")
            b1.onclick=function() {update(specid,newpid,'','edit'+newpid);};
    }
    else {
        if (purpose=="edit")
            b1.setAttribute('onclick',"openEditor('editdesc"+newpid+");");
        else if (purpose=="add")
            b1.setAttribute('onclick',"openEditor('adddesc"+newpid+");");
        else if(purpose=="submitedit")
            b1.setAttribute('onclick',"update('"+specid+"','desc"+newpid+"','editedtext"+newpid+"','editdesc"+newpid+"')");
        else if(purpose=="submitadd"){
            b1.setAttribute('onclick',"addDesc('"+specid+"',"+newpid+","+pids+")");}
        else if (purpose=="editresp")
            b1.setAttribute('onclick',"openEditor('editv"+newpid+"');");
        else if(purpose=="submiteditresp")
            b1.setAttribute('onclick',"update('"+specid+"','"+newpid+"','"+pids+"','editv"+newpid+"');");
        else if(purpose=="editURL")
            b1.setAttribute('onclick',"openEditor('editvurl"+newpid+"');");
        else if(purpose=="submiteditURL")
            b1.setAttribute('onclick',"update('"+specid+"','"+newpid+"','"+pids+"','edit"+newpid+"');");
        else if(purpose=="editRel")
            b1.setAttribute('onclick',"openEditor('edit"+newpid+"');");
        else if(purpose=="removeRel")
            b1.setAttribute('onclick',"removeElement('"+specid+"','"+newpid+"','');");
        else if(purpose=="submitEditRel")
            b1.setAttribute('onclick',"update('"+specid+"','"+newpid+"','','edit"+newpid+"');");
            
    }    
    b1.className=cname; b1.type="button"
    b1.appendChild(document.createTextNode(text))
    
    return b1
}

function createBox(t1,b,ta,text,taid,tableid,box,newpid,specid,pids,ph){
    ta = document.createElement("textarea")
    ta.id=taid+newpid; ta.className="inputText"; 
    ta.placeholder=ph
    ta.style.width="550px"; ta.style.height="150px"; ta.style.resize="none"; ta.style.fontSize="11px"
    ta.value=text    
    
    b = createButton(b,"button","Submit","submit"+box,newpid,specid,pids)
    
    t1 =  document.createElement("table")
    t1.id=tableid+newpid; 
    t1.style.display="none"
    tr1 = t1.insertRow(0); td1 = tr1.insertCell(0);
    td2 = tr1.insertCell(1); td2.vAlign="top"; 
    td1.appendChild(ta)
    td2.appendChild(b)
    
    return t1
}

function createRelation(result,newpath,specid,addpath){    
    sp1 = document.createElement("span")
    sp1.id = newpath+"pid"
    sp1.style.display='none'
    
    a = document.createElement("a")
    a.id = newpath+"link"
    
    b1 = createButton('','edit','Edit','editRel',newpath,'','') 
    b2 = createButton('','edit','Remove','removeRel',newpath,specid,'')
    
    sp2 = document.createElement("span")
    sp2.id = newpath+"text"     
    
    li = document.createElement("li")
    li.id = newpath+"li"
    li.appendChild(sp1); li.appendChild(a); li.appendChild(b1);
    li.appendChild(b2); li.appendChild(sp2);
        
    ul = document.getElementById('vrel'+vid+'ul')    
    ul.appendChild(li)
    e = createEditRel(result,newpath,specid,addpath)
    e.innerHTML = escapeHtml(e.innerHTML);
    ul.appendChild(e)
}

function createEditRel(result,newid,specid,addpath){
    ss1 = document.getElementById(addpath)        
    ss1.options[ss1.selectedIndex].selected=''
    
    var s1 = document.createElement("select")
    s1.id=newid; s1.className="inputSelect"
    s1.style.marginRight="3px"; s1.style.width="173px"    
    s1.appendChild(document.createElement('option'))    
    for (x in relation){
        opText = document.createTextNode(relation[x]);
        op = document.createElement('option');
        if (relation[x] == result[0]) {op.selected='true'; }
        op.value = relation[x]
        op.appendChild(opText)
        s1.appendChild(op)
    }
    
    ss2 = document.getElementById(addpath+'target')        
    ss2.options[ss2.selectedIndex].selected=''
    
    var s2 = document.createElement("select")
    s2.id=newid+'target' ; s2.className="inputSelect"
    s2.style.marginRight="3px"; s2.style.width="280px"    
    s2.appendChild(document.createElement('option'))
    for (x in reltarget){
        opText = document.createTextNode(reltarget[x][1]);
        op = document.createElement('option');
        if (reltarget[x][0] == result[1]) {op.selected='true'}
        op.value = reltarget[x][0]
        op.appendChild(opText)
        s2.appendChild(op)
    }
    
    b = createButton('','button','Submit','submitEditRel',newid,specid,'')
    
    document.getElementById(addpath+'desc').value=''
    
    ta = document.createElement("textarea")
    ta.id = newid+'desc'
    ta.className = "inputText"
    ta.placeholder = "Describe the relation in one paragraph." 
    ta.style.width="450px"; ta.style.marginTop='2px'; ta.style.height="50px";
    ta.style.resize='none'; ta.style.fontSize='11px'
    ta.innerHTML=result[2]
                         
    sp1 = document.createElement("span")
    sp1.id = 'edit'+newid
    sp1.style.display='none'
    sp1.style.marginBottom='15px'    
    sp1.appendChild(s1); sp1.appendChild(s2); sp1.appendChild(b); sp1.appendChild(ta)
    return sp1
}

function writeRespStmtResponse(task,response,path,specid,pid,frame){
    parser=new DOMParser();
    xmlDoc=parser.parseFromString(response,"text/xml");
    
    respStmt = xmlDoc.getElementsByTagName("respStmt")[0]
    path = "resp"+ respStmt.attributes[0].nodeValue
        
    document.getElementById(path+"text").innerHTML = 
        respStmt.getElementsByTagName("resp")[0].childNodes[0].nodeValue + ":"
        
    names = xmlDoc.getElementsByTagName("name")    
    namelist=[]
    for (n=0; n<names.length;n++){
        // the org is not linked because it needs a session-encoded URL from exist 
        namelist += '<li>'+names[n].childNodes[0].nodeValue+'</li>'
    }
    document.getElementById(path+"nametext").innerHTML = namelist;    
    document.getElementById(frame).style.display = 'none';
    
    if (document.getElementById(path).className.contains("Error"))
        document.getElementById(path).className = "inputText"
}

function writeRelResponse(result,path,frame,errorpath){
   for (r=0; r<result.length; r++) {
        if(result[r] == 'errortype'){
            document.getElementById(path).className = 'inputSelectError';}
        else if (result[r] == 'errortarget') {
            document.getElementById(path+'target').className = 'inputSelectError';}        
        else if (r==2) {
            document.getElementById(path+'text').innerHTML = "<p>"+result[2]+"</p>"}
        else if (r==3) {
            r = result[3].split("++")
            a = document.getElementById(path+'link')
            a.href = escapeHtml(r[0])
            a.innerHTML=escapeHtml(r[1])
            
            document.getElementById(path+'pid').innerHTML = result[1]
            document.getElementById(frame).style.display = 'none';
            removeErr(errorpath,"inputSelect",'')
            removeErr(errorpath+'target',"inputSelect",'')
        }
   }  
}

function writeURLResponse(response,pid,path,frame){
    if (response==''){
        document.getElementById('vurltext'+pid).style.display = 'none'
    }
    else {                
        if (response.indexOf('--') > -1)
            result = response.split("--")
        else result = [response]                        
            
        if (response.indexOf('false') == -1){                    
            urls=''
            for (i=0; i< result.length;i++){
                 urls += '<a href="'+result[i]+'">'+result[i]+'</a>';
                 if (i<result.length-1) urls += ", " 
                 document.getElementById(path+(i+1)).className = 'inputText';
            }                         
            document.getElementById('vurltext'+pid).innerHTML = urls
            document.getElementById('vurltext'+pid).style.display = 'inline';                        
            document.getElementById(frame).style.display = 'none';                        
            document.getElementById('error'+path).style.display = 'none';
        }                
        else{
            for (i=0; i< result.length;i++){
                if (result[i] == 'false'){
                    document.getElementById(path+(i+1)).className = 'inputTextError';
                    document.getElementById('error'+path).style.display = 'block';}                    
            }
        }
        
        if (document.getElementById(path+"1").className.contains("Error"))
            document.getElementById(path+"1").className = "inputText"
    }
}