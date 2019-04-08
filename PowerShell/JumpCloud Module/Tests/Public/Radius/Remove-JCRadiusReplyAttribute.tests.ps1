Connect-JCTestOrg

Describe "Remove-JCRadiusReplyAttributes 1.9.0" {

    It "Removes a single custom radius attribute from a group" {

        $NewGroup = New-JCUserGroup -GroupName $(New-RandomStringLower)

        $Attr1Name = "Attr1Name"

        $Attr1Value = "Attr1Value"

        $Attr2Name = "Attr2Name"

        $Attr2Value = "Attr2Value"

        $AttributesAdd = Add-JCRadiusReplyAttribute -GroupName $NewGroup.Name -NumberOfAttributes 2 -Attribute1_name $Attr1Name -Attribute1_value $Attr1Value -Attribute2_name $Attr2Name -Attribute2_value $Attr2Value

        $AttributesRemove = Remove-JCRadiusReplyAttribute -GroupName $NewGroup.Name -AttributeName $Attr1Name

        $Attr1Verify = $AttributesRemove | Where-Object Name -EQ "Attr1Name" | Select-Object -ExpandProperty value

        $Attr1Verify | Should -Be $null

        $Attr2Verify = $AttributesRemove | Where-Object Name -EQ "Attr2Name" | Select-Object -ExpandProperty value

        $Attr2Verify | Should -Be $Attr2Value

        Remove-JCUserGroup -GroupName $NewGroup.Name -force

    }

    It "Removes two custom radius attributes from a group" {

        $NewGroup = New-JCUserGroup -GroupName $(New-RandomStringLower)

        $Attr1Name = "Attr1Name"

        $Attr1Value = "Attr1Value"

        $Attr2Name = "Attr2Name"

        $Attr2Value = "Attr2Value"

        $AttributesAdd = Add-JCRadiusReplyAttribute -GroupName $NewGroup.Name -NumberOfAttributes 2 -Attribute1_name $Attr1Name -Attribute1_value $Attr1Value -Attribute2_name $Attr2Name -Attribute2_value $Attr2Value

        $AttributesRemove = Remove-JCRadiusReplyAttribute -GroupName $NewGroup.Name -AttributeName $Attr1Name, $Attr2Name

        $Attr1Verify = $AttributesRemove | Where-Object Name -EQ "Attr1Name" | Select-Object -ExpandProperty value

        $Attr1Verify | Should -Be $null

        $Attr2Verify = $AttributesRemove | Where-Object Name -EQ "Attr2Name" | Select-Object -ExpandProperty value

        $Attr2Verify | Should -Be $null

        Remove-JCUserGroup -GroupName $NewGroup.Name -force

    
    }

    It "Removes all radius attributes from a group" {

        $NewGroup = New-JCUserGroup -GroupName $(New-RandomStringLower)

        $Attr1Name = "Attr1Name"

        $Attr1Value = "Attr1Value"

        $Attr2Name = "Attr2Name"

        $Attr2Value = "Attr2Value"

        $VLAN = Get-Random -Minimum 1 -Maximum 4064

        $AttributesAdd = Add-JCRadiusReplyAttribute -GroupName $NewGroup.Name -NumberOfAttributes 2 -Attribute1_name $Attr1Name -Attribute1_value $Attr1Value -Attribute2_name $Attr2Name -Attribute2_value $Attr2Value -VLAN $VLAN

        $AttributeRemove = Remove-JCRadiusReplyAttribute -GroupName $NewGroup.Name -All

        $GetAttributes = Get-JCRadiusReplyAttribute -GroupName $NewGroup.name

        $GetAttributes | Should -be $null

        Remove-JCUserGroup -GroupName $NewGroup.Name -force

    }
}