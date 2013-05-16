<?php
    error_reporting(E_ALL);

    define ('XMLNS', 'https://github.com/sys-team/ASA.chest');
    define('CHEST_SERVER', 'https://oldcat.unact.ru/rc_unact_old/chest');
    
    $json = file_get_contents ('php://input');
    
    if (isset($_REQUEST['authorization:']))
        $authorization = $_REQUEST['authorization:'];
    elseif (isset($_SERVER['Authorization'])) 
        $authorization = str_replace('Bearer ', '', $_SERVER['Authorization']);
    
    if (isset($json) && $json != ''){
        
        echo($json);
        
    } else {
        
        $ret = postData (CHEST_SERVER, null, $authorization);
        $xml = new XMLReader();
        $xml -> XML($ret);
        
        $arr = array();
        $arr = xml2array ($xml, 'response');
        
    }
    
    //echo($ret);
    
    $jsonRes = json_encode ($arr, JSON_NUMERIC_CHECK);
    echo($jsonRes);
    
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
    
    function xml2array($xml){ 
   
        $tree = array();
        
        while($xml->read()){
            
            if($xml -> nodeType == XMLReader::END_ELEMENT)
                return $tree;
            else if($xml -> nodeType == XMLReader::ELEMENT){
                $node = array();
                
                $node['name'] = $xml -> name;
                $value = $xml -> readString();
    
                if($xml->hasAttributes){
                    while($xml->moveToNextAttribute()) {
                        $node[$xml->name] = $xml->value;
                    }

                }
                
                if(!$xml -> isEmptyElement)  {
                    $properties = xml2array($xml);
                    if ($properties) 
                        $node['properties'] = $properties;
                    else
                        $node['value'] = $value;
                }                
                $tree[] = $node;
            }
            
            else if($xml -> nodeType == XMLReader::TEXT){
                continue;

            }
        }
        return $tree; 
   }
    

?>