<?php

$curl = curl_init();

$usuario   = $_POST['coduser'];
$senha     = $_POST['senha'];
$link      = $_POST['cLink'];
$link      = $_POST['cLink'];

//echo $usuario;
//echo $senha;
//echo $link;

curl_setopt_array($curl, [
    CURLOPT_PORT => "50050",
    CURLOPT_URL => "https://l91fwf-hom-protheus.totvscloud.com.br:50050/rest/authuser?USR=" . $usuario . "&PWD=" . $senha,
    CURLOPT_RETURNTRANSFER => true,
    CURLOPT_ENCODING => "",
    CURLOPT_MAXREDIRS => 10,
    CURLOPT_TIMEOUT => 30,
    CURLOPT_HTTP_VERSION => CURL_HTTP_VERSION_1_1,
    CURLOPT_CUSTOMREQUEST => "POST",
    CURLOPT_POSTFIELDS => "",
    CURLOPT_HTTPHEADER => [
      "Authorization: Basic Y2Fpby5oZW5yaXF1ZTpUeUBjRmUxOCE=",
      "Content-Type: application/json"
    ],
  ]);
  
  $response = curl_exec($curl);
  $err = curl_error($curl);
  
  curl_close($curl);
  
  if ($err) {
    exit(header('Location: http://l91fwf-hom-protheus.totvscloud.com.br:14159/workflow/emp01/process/config/wserror.html', true, 301));
  } else {
    $json = json_decode($response);
    $retorno =  $json->{"RETORNO"};
    if ($retorno == "OK"){
        exit(header('Location: http://l91fwf-hom-protheus.totvscloud.com.br:14159/workflow/emp01/process/' . $link, true, 301));
      } else{
        exit(header('Location: http://l91fwf-hom-protheus.totvscloud.com.br:14159/workflow/emp01/process/config/senha.html', true, 301));
      } 
  }
 
?>