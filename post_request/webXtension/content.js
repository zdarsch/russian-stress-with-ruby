

 let text=document.body.innerHTML;	
const options = {
    method: 'POST',
    body: text
};
let  url='http://127.0.0.1:8080/stress';
fetch(url, options)
  .then(response => response.text())
  .then(data => {document.body.innerHTML = data})

