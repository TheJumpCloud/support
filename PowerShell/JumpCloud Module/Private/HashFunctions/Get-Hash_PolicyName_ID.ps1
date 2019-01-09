Function Get-Hash_PolicyName_ID ()
{

   $PolicyHash =  New-Object System.Collections.Hashtable

   $Policies = Get-JCPolicy

       foreach ($Policy in $Policies)
       {
           $PolicyHash.Add(($policy.name),($policy.id))
       }
   return $PolicyHash
}
