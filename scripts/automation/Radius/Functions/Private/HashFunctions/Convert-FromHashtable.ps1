function ConvertFrom-HashTable {
    # attribute function from https://stackoverflow.com/questions/73894087/how-do-i-convert-a-powershell-hashtable-to-an-object
    # inspired from mklement0's answer
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Collections.IDictionary] $HashTable
    )
    process {
        $dict = New-Object System.Collections.Specialized.OrderedDictionary
        foreach ($item in $HashTable.GetEnumerator()) {
            if ($item.Value -is [System.Collections.IDictionary]) {
                # Nested dictionary? Recurse.
                $dict[[object] $item.Key] = ConvertFrom-HashTable -HashTable $item.Value # NOTE: Casting to [object] prevents problems with *numeric* hashtable keys.
            } else {
                # Copy value as-is.
                $dict[[object] $item.Key] = $item.Value
            }
        }
        [pscustomobject] $dict # Convert to [pscustomobject] and output.
    }
}