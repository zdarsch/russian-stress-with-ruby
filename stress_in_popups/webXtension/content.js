let div = document.createElement("div");
div.id = "popup";
div.style.position = "absolute";
div.style.width = "250px";
div.style.height = "250px";
div.style.padding = "25px";
div.style.background = "red";
div.style.color = "white";
div.style.fontSize = "25px";
div.style.display = "none";

let offX = 0;
let offY = 25;
g=function (e){
let x = e.pageX;
let y = e.pageY;
div.style.left = x+offX+'px';
div.style.top  = y+offY+'px';
}

f=function(){
let s=document.getSelection().toString();
if(s){
let  url='http://127.0.0.1:8080/stress?word='+s;
fetch(url)
  .then(response => response.text())
  .then(data => {
   div.innerHTML = decodeURIComponent(data);
   div.style.display = "block"; 
   })

   }
else{
 div.style.display = "none";
 div.innerHTML = "";
     }
}

document.body.appendChild(div);
document.addEventListener('mouseup', f);
document.addEventListener('mousemove', g);
