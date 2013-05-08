<?php

    function guid(){
        if (function_exists('com_create_guid')){
            return com_create_guid();
        }else{
            mt_srand((double)microtime()*10000);//optional for php 4.2.0 and up.
            $charid = strtoupper(md5(uniqid(rand(), true)));
            $hyphen = chr(45);// "-"
            $uuid = substr($charid, 0, 8).$hyphen
                    .substr($charid, 8, 4).$hyphen
                    .substr($charid,12, 4).$hyphen
                    .substr($charid,16, 4).$hyphen
                    .substr($charid,20,12);
                    
            return $uuid;
        }
    }

    function postData($url, $data) {
        
        $ch = curl_init($url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_POSTFIELDS, $data);
        curl_setopt($ch, CURLOPT_HTTPHEADER, array('Content-type: '.'text/xml' ));
        
        $ret = curl_exec($ch);
        curl_close($ch);
        
        return($ret);
    }

    $chestUrl = $_REQUEST['url'];
    $numPosts = $_REQUEST['cnt'];
    $authCode = $_REQUEST['code'];
    
    date_default_timezone_set('UTC');
    
    // creating test data
    $postData = array();
    
    $xml = new DomDocument('1.0');
    $root = $xml -> appendChild($xml -> createElement('post'));
    $d = $root -> appendChild($xml -> createElement('d'));
    $attrName = $xml -> createAttribute('name');
    $attrName -> value = 'chtest';
    $d -> appendChild($attrName);
        
    for ($i = 0; $i < $numPosts; $i++) {
    
        $attrXid = $xml -> createAttribute('xid');
        $attrXid -> value = guid();
        $d -> appendChild($attrXid);
        
        $postData[$i] = $xml -> saveXml();
    }
    
    echo('Testing ASA.chest service at '.$chestUrl);
    
    echo(' Start time = '.date('Y-m-d H:i:s'));  
    
    for ($i = 0; $i < $numPosts; $i++) {
        $result = postData($chestUrl.'?authorization:='.$authCode, $postData[$i]);        
    }
    
    echo(' End time = '.date('Y-m-d H:i:s'));  
?>