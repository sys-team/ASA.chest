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
    
    if ($_REQUEST['url'] == '' || $_REQUEST['code'] == '') {
        echo('URL and auth code requred');
        return;
    }

    $chestUrl = $_REQUEST['url'].'?authorization:='.$_REQUEST['code'];
    $numPosts = $_REQUEST['cnt'];
    $postSize = $_REQUEST['size'];
    
    if ($numPosts == '') {
        $numPosts = 10;
    }
    if ($postSize == '') {
        $postSize = 1;
    }

    // creating test data
    $postData = array();
    
    $xml = new DomDocument('1.0');
    $root = $xml -> appendChild($xml -> createElement('post'));

        
    for ($i = 0; $i < $numPosts; $i++) {
    
        for ($j = 0; $j < $postSize; $j ++) {

            $d = $root -> appendChild($xml -> createElement('d'));
            $attrName = $xml -> createAttribute('name');
            $attrName -> value = 'chTest';
            $d -> appendChild($attrName);
        
            $attrXid = $xml -> createAttribute('xid');
            $attrXid -> value = guid();
            $d -> appendChild($attrXid);
        }
        
        $postData[$i] = $xml -> saveXml();
    }
    
    $startTime = microtime(true);
    
    for ($i = 0; $i < $numPosts; $i++) {
        $result = postData($chestUrl, $postData[$i]);        
    }
    
    $endTime = microtime(true);
    
    $speed = round($numPosts/($endTime - $startTime), 3);
    
    echo('ASA.chest posts = '.$numPosts.' post size = '.$postSize.' speed = '.$speed.' posts/sec');
    
?>