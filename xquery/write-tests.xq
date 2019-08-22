(: Initial creation of test files. This can be continuously ran as tests are added since the schemalet files are always overwritten, but the test files are not in intsnaces where they already exist. :)

import module namespace schematron = "http://github.com/Schematron/schematron-basex";
import module namespace elife = 'elife' at 'elife.xqm';

declare option db:chop 'false';

let $base := doc('../schematron.sch')
let $base-uri := substring-before(base-uri($base),'/schematron.sch')

for $test in $base//(*:assert|*:report)
let $rule-id := $test/parent::*:rule/@id
let $path := concat($base-uri,'/tests/',$rule-id,'/',$test/@id,'/')
let $pass := concat($path,'pass.xml')
let $fail := concat($path,'fail.xml')
let $schema-let := elife:schema-let($test)

let $pi-content := ('SCHSchema="'||$test/@id||'.sch'||'"') 
let $comment := comment{concat('Context: ',$test/parent::*:rule/@context/string(),'
Test: ',$test/local-name(),'    ',normalize-space($test/@test/string()),'
Message: ',replace($test/data(),'-',''))}

let $node := 
(processing-instruction {'oxygen'}{$pi-content},
$comment,
<root xmlns:ali="http://www.niso.org/schemas/ali/1.0/" xmlns:mml="http://www.w3.org/1998/Math/MathML" xmlns:xlink="http://www.w3.org/1999/xlink"><article/></root>)

return 
(
  if(file:exists($path)) 
  then () 
  else file:create-dir($path)
  ,
  if(file:exists($pass)) then 
    let $new-pass := elife:new-test-case($pass,$comment)
    return file:write($pass,$new-pass,map{'indent':'no'})
  else file:write($pass,$node)
  ,
  if(file:exists($fail)) then 
   let $new-fail := elife:new-test-case($fail,$comment)
    return file:write($fail,$new-fail,map{'indent':'no'})
  else file:write($fail,$node)
  ,
  file:write(concat($path,$test/@id,'.sch'),$schema-let)
)