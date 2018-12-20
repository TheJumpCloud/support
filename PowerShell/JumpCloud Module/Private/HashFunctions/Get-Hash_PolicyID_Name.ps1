Function Get-Hash_PolicyID_Name ()
{

   $PolicyHash =  New-Object System.Collections.Hashtable

   $Policies = Get-JCPolicy

       foreach ($Policy in $Policies)
       {
           $PolicyHash.Add(($policy.id),($policy.name))
       }
   return $PolicyHash
}
