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

        $requestXML = new DOMDocument('1.0', 'utf-8');
        
        $jd = json_decode($json, true);
        
        if ($jd != null) {
            $requestXML -> appendChild( $requestXML -> createElementNS( XMLNS, 'post') );
            chestArray2xml ( $jd['data'], $requestXML -> documentElement);
        }
        
        $request = $requestXML -> saveXML();
        //var_dump($request);
        
        $ret = postData (CHEST_SERVER, $request, $authorization);
        //var_dump($ret);
        
    } else {        
        $ret = postData (CHEST_SERVER, null, $authorization);
        //var_dump($ret);
    }
    
    if (isset($ret)) {
        $xml = new XMLReader();
        $xml -> XML($ret);
        $xml -> setParserProperty(XMLReader::VALIDATE, true);
        

        if ($xml->isValid()) {
            $arrayRes = chestXml2array ($xml, 1);
            $jsonRes = json_encode ($arrayRes, JSON_NUMERIC_CHECK);
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
    function chestXml2array($xml, $dLevel){ 
   
        $tree = array();

        while ($xml->read()) {
            
            if ($xml -> nodeType == XMLReader::ELEMENT && $xml -> name == 'd' && $xml -> depth == 1 && $dLevel == 1){

                $node = array();
                $property = array();

    
                if($xml->hasAttributes){
                    while($xml->moveToNextAttribute()) {
                        $node[$xml -> name] = $xml -> value;
                    }
                }
                
                $property = chestXml2array($xml, 2);
                
                if ($property) 
                    $node['property'] = $property;
                        
                $tree[] = $node;
            } elseif ($xml -> nodeType == XMLReader::ELEMENT && $xml -> name != 'd' && $xml -> depth == 2 && $dLevel == 2) {
                $tree[$xml -> getAttribute('name')] =  $xml -> readString();
                $next = chestXml2array($xml, 2);
                
                if ($next)
                    $tree[] = $next;
                    
            } elseif ($xml -> nodeType == XMLReader::END_ELEMENT) {
                return $tree;
            }
        
        }

        return $tree;
    }
    ////////////////////////
    function chestArray2xml ( $array, $xmlnode ) {
        
        $doc = $xmlnode -> ownerDocument;
        
        foreach ( $array as $key => $value){
            $dNode = $xmlnode -> appendChild ( $doc -> createElement ('d'));
            if (is_array ($value)){
                foreach($value as $key => $value) {
                    if (is_array ($value)) {
                        if ($key == 'property') {
                            foreach($value as $key => $value) {
                                $aNode = $dNode -> appendChild
                                         ( $doc -> createElement (( is_numeric($value) ? 'double' : 'string' ), $value));
                                $attr = $doc -> createAttribute('name');
                                $attr -> value = $key;
                                $aNode -> appendChild($attr);
                                
                            }
                        } elseif ($key == 'role') {
                            $rNode = $dNode -> appendChild( $doc -> createElement ('d'));
                            foreach($value as $key => $value) {
                                $attr = $doc -> createAttribute('name');
                                $attr -> value = $key;
                                $rNode -> appendChild($attr);
                                
                                $attr = $doc -> createAttribute('xid');
                                $attr -> value = $value;
                                $rNode -> appendChild($attr);
                            }
                        }
                        
                    } else {
                        if ($key == 'name' || $key == 'xid') {
                            $attr = $doc -> createAttribute($key);
                            $attr -> value = $value;
                            $dNode -> appendChild($attr);    
                        }
                    }
                }
            }
        }
    }

?>