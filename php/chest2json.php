<?php
    //error_reporting(E_ALL);
    error_reporting(E_ERROR);

    define ('XMLNS', 'https://github.com/sys-team/ASA.chest');
    define('CHEST_SERVER', 'https://oldcat.unact.ru/rc_unact_old/chest');
    
    $json = file_get_contents ('php://input');
    
    if (isset($_REQUEST['authorization:']))
        $authorization = $_REQUEST['authorization:'];
    elseif (isset($_SERVER['Authorization'])) 
        $authorization = str_replace('Bearer ', '', $_SERVER['Authorization']);
    
    if (isset($json) && $json != ''){

        chestJSON2XML($json);
        
    } else {        
        $ret = postData (CHEST_SERVER, null, $authorization);        
    }
    
    if (isset($ret)) {
        $xml = new XMLReader();
        $xml -> XML($ret);
        $xml -> setParserProperty(XMLReader::VALIDATE, true);
        

        if ($xml->isValid()) {
            $jsonRes = chestXML2JSON ($xml);
            echo($jsonRes);
        }
        $xml -> close();
    }
    
    ////////////////////////
    function postData ($url, $data, $authorization) {
    
        $ch = curl_init($url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_POSTFIELDS, $data);
        curl_setopt($ch, CURLOPT_HTTPHEADER, array('Content-type: '.'text/xml',
                                                   'Authorization: Bearer '.$authorization));
        
        $ret = curl_exec($ch);
        curl_close($ch);
        
        return($ret); 
        
    }
    ////////////////////////
    function chestXML2JSON($xml){ 
   
        $tree = array();
        
        while ($xml->read()) {     
            if ($xml -> nodeType == XMLReader::ELEMENT && $xml -> name == 'd' && $xml -> depth == 1){
                
                $node = array();
                $property = array();
                
                $dXml = new XMLReader();
                $dXml = $xml;
    
                if($xml->hasAttributes){
                    while($xml->moveToNextAttribute()) {
                        $node[$xml -> name] = $xml -> value;
                    }
                }
                
                while ($dXml->read()) {
                    if ($dXml -> nodeType == XMLReader::ELEMENT && $dXml -> name != 'd' && $dXml -> depth == 2){   
                        $property[$dXml -> getAttribute('name')] =  $dXml -> readString();
                    }
                }
                
                if ($property) 
                        $node['property'] = $property;
                        
                $dXml -> close();
                $tree[] = $node;
            }
        }
        
        $res = json_encode ($tree, JSON_NUMERIC_CHECK);
        return $res;
    }
    ////////////////////////
    function chestJSON2XML($json){
        
        $data = array();
        $data = json_decode($json);
        
        var_dump($data);
        
    
        
    }

?>