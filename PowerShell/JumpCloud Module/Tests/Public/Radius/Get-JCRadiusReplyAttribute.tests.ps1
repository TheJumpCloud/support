Connect-JCTestOrg

Describe "Get-JCRadiusReplyAttribute 1.9.0" {

    It "Adds VLAN attributes to a group and uses Get-JCRadiusReplyAttributes to verify" {

        $NewGroup = New-JCUserGroup -GroupName $(New-RandomStringLower)

        $VLAN = Get-Random -Minimum 1 -Maximum 4064

        $AttributesAddition = Add-JCRadiusReplyAttribute -VLAN $VLAN -GroupName $NewGroup.Name

        $AttributesAdd = Get-JCRadiusReplyAttribute -GroupName $NewGroup.Name

        $TunnelType = $AttributesAdd | Where-Object Name -EQ "Tunnel-Type" | Select-Object -ExpandProperty value

        $TunnelType | Should -Be "VLAN"

        $TunnelMediumType = $AttributesAdd | Where-Object Name -EQ "Tunnel-Medium-Type" | Select-Object -ExpandProperty value

        $TunnelMediumType | Should -Be "IEEE-802"

        $TunnelPrivateGroupID = $AttributesAdd | Where-Object Name -EQ "Tunnel-Private-Group-ID" | Select-Object -ExpandProperty value

        $TunnelPrivateGroupID | Should -Be $VLAN

        Remove-JCUserGroup -GroupName $NewGroup.Name -force

    }

    It "Adds a single custom radius attribute to a group and uses Get-JCAttributes to verify" {

        $NewGroup = New-JCUserGroup -GroupName $(New-RandomStringLower)

        $Attr1Name = "Attr1Name"

        $Attr1Value = "Attr1Value"

        $AttributesAddition = Add-JCRadiusReplyAttribute -GroupName $NewGroup.Name -NumberOfAttributes 1 -Attribute1_name $Attr1Name -Attribute1_value $Attr1Value

        $AttributesAdd = Get-JCRadiusReplyAttribute -GroupName $NewGroup.Name

        $Attr1Verify = $AttributesAdd | Where-Object Name -EQ "Attr1Name" | Select-Object -ExpandProperty value

        $Attr1Verify | Should -Be $Attr1Value

        Remove-JCUserGroup -GroupName $NewGroup.Name -force

    }

    It "Adds a single custom radius attribute to a group and VLAN attributes and uses Get-JCRadiusReplyAttributes to verify" {

        $NewGroup = New-JCUserGroup -GroupName $(New-RandomStringLower)

        $VLAN = Get-Random -Minimum 1 -Maximum 4064

        $Attr1Name = "Attr1Name"

        $Attr1Value = "Attr1Value"

        $AttributesAddition = Add-JCRadiusReplyAttribute -VLAN $VLAN -GroupName $NewGroup.Name -NumberOfAttributes 1 -Attribute1_name $Attr1Name -Attribute1_value $Attr1Value

        $AttributesAdd = Get-JCRadiusReplyAttribute -GroupName $NewGroup.name

        $TunnelType = $AttributesAdd | Where-Object Name -EQ "Tunnel-Type" | Select-Object -ExpandProperty value

        $TunnelType | Should -Be "VLAN"

        $TunnelMediumType = $AttributesAdd | Where-Object Name -EQ "Tunnel-Medium-Type" | Select-Object -ExpandProperty value

        $TunnelMediumType | Should -Be "IEEE-802"

        $TunnelPrivateGroupID = $AttributesAdd | Where-Object Name -EQ "Tunnel-Private-Group-ID" | Select-Object -ExpandProperty value

        $TunnelPrivateGroupID | Should -Be $VLAN

        $Attr1Verify = $AttributesAdd | Where-Object Name -EQ "Attr1Name" | Select-Object -ExpandProperty value

        $Attr1Verify | Should -Be $Attr1Value

        Remove-JCUserGroup -GroupName $NewGroup.Name -force

    }

    It "Adds two custom radius attributes to a group and uses Get-JCRadiusReplyAttributes to verify" {

        $NewGroup = New-JCUserGroup -GroupName $(New-RandomStringLower)

        $Attr1Name = "Attr1Name"

        $Attr1Value = "Attr1Value"

        $Attr2Name = "Attr2Name"

        $Attr2Value = "Attr2Value"

        $AttributesAddition = Add-JCRadiusReplyAttribute -GroupName $NewGroup.Name -NumberOfAttributes 2 -Attribute1_name $Attr1Name -Attribute1_value $Attr1Value -Attribute2_name $Attr2Name -Attribute2_value $Attr2Value

        $AttributesAdd = Get-JCRadiusReplyAttribute -GroupName $NewGroup.name

        $Attr1Verify = $AttributesAdd | Where-Object Name -EQ "Attr1Name" | Select-Object -ExpandProperty value

        $Attr1Verify | Should -Be $Attr1Value

        $Attr2Verify = $AttributesAdd | Where-Object Name -EQ "Attr2Name" | Select-Object -ExpandProperty value

        $Attr2Verify | Should -Be $Attr2Value

        Remove-JCUserGroup -GroupName $NewGroup.Name -force

    }

    It "Adds two custom radius attributes to a group and VLAN attributes and uses Get-JCRadiusReplyAttributes to verify" {

        $NewGroup = New-JCUserGroup -GroupName $(New-RandomStringLower)

        $VLAN = Get-Random -Minimum 1 -Maximum 4064

        $Attr1Name = "Attr1Name"

        $Attr1Value = "Attr1Value"

        $Attr2Name = "Attr2Name"

        $Attr2Value = "Attr2Value"

        $AttributesAddition = Add-JCRadiusReplyAttribute -GroupName $NewGroup.Name -NumberOfAttributes 2 -Attribute1_name $Attr1Name -Attribute1_value $Attr1Value -Attribute2_name $Attr2Name -Attribute2_value $Attr2Value -VLAN $VLAN

        $AttributesAdd = Get-JCRadiusReplyAttribute -GroupName $NewGroup.Name

        $TunnelType = $AttributesAdd | Where-Object Name -EQ "Tunnel-Type" | Select-Object -ExpandProperty value

        $TunnelType | Should -Be "VLAN"

        $TunnelMediumType = $AttributesAdd | Where-Object Name -EQ "Tunnel-Medium-Type" | Select-Object -ExpandProperty value

        $TunnelMediumType | Should -Be "IEEE-802"

        $TunnelPrivateGroupID = $AttributesAdd | Where-Object Name -EQ "Tunnel-Private-Group-ID" | Select-Object -ExpandProperty value

        $TunnelPrivateGroupID | Should -Be $VLAN

        $Attr1Verify = $AttributesAdd | Where-Object Name -EQ "Attr1Name" | Select-Object -ExpandProperty value

        $Attr1Verify | Should -Be $Attr1Value

        $Attr2Verify = $AttributesAdd | Where-Object Name -EQ "Attr2Name" | Select-Object -ExpandProperty value

        $Attr2Verify | Should -Be $Attr2Value

        Remove-JCUserGroup -GroupName $NewGroup.Name -force

    }

    It "Adds three custom radius attributes to a group and uses Get-JCRadiusReplyAttributes to verify" {

        $NewGroup = New-JCUserGroup -GroupName $(New-RandomStringLower)

        $Attr1Name = "Attr1Name"

        $Attr1Value = "Attr1Value"

        $Attr2Name = "Attr2Name"

        $Attr2Value = "Attr2Value"

        $Attr3Name = "Attr3Name"

        $Attr3Value = "Attr3Value"

        $AttributesAddition = Add-JCRadiusReplyAttribute -GroupName $NewGroup.Name -NumberOfAttributes 3 -Attribute1_name $Attr1Name -Attribute1_value $Attr1Value -Attribute2_name $Attr2Name -Attribute2_value $Attr2Value -Attribute3_name $Attr3Name -Attribute3_value $Attr3Value

        $AttributesAdd = Get-JCRadiusReplyAttribute -GroupName $NewGroup.Name

        $Attr1Verify = $AttributesAdd | Where-Object Name -EQ "Attr1Name" | Select-Object -ExpandProperty value

        $Attr1Verify | Should -Be $Attr1Value

        $Attr2Verify = $AttributesAdd | Where-Object Name -EQ "Attr2Name" | Select-Object -ExpandProperty value

        $Attr2Verify | Should -Be $Attr2Value

        $Attr3Verify = $AttributesAdd | Where-Object Name -EQ "Attr3Name" | Select-Object -ExpandProperty value

        $Attr3Verify | Should -Be $Attr3Value

        Remove-JCUserGroup -GroupName $NewGroup.Name -force

    }
 
    It "Adds a custom attribute to a group that already has VLAN attributes and uses Get-JCRadiusReplyAttributes to verify" {

        $NewGroup = New-JCUserGroup -GroupName $(New-RandomStringLower)

        $VLAN = Get-Random -Minimum 1 -Maximum 4064

        $InitialAttributesAdd = Add-JCRadiusReplyAttribute -VLAN $VLAN -GroupName $NewGroup.Name

        $Attr1Name = "Attr1Name"

        $Attr1Value = "Attr1Value"

        $AttributesAddition = Add-JCRadiusReplyAttribute -GroupName $NewGroup.Name -NumberOfAttributes 1 -Attribute1_name $Attr1Name -Attribute1_value $Attr1Value

        $AttributesAdd = Get-JCRadiusReplyAttribute -GroupName $NewGroup.name

        $TunnelType = $AttributesAdd | Where-Object Name -EQ "Tunnel-Type" | Select-Object -ExpandProperty value

        $TunnelType | Should -Be "VLAN"

        $TunnelMediumType = $AttributesAdd | Where-Object Name -EQ "Tunnel-Medium-Type" | Select-Object -ExpandProperty value

        $TunnelMediumType | Should -Be "IEEE-802"

        $TunnelPrivateGroupID = $AttributesAdd | Where-Object Name -EQ "Tunnel-Private-Group-ID" | Select-Object -ExpandProperty value

        $TunnelPrivateGroupID | Should -Be $VLAN

        $Attr1Verify = $AttributesAdd | Where-Object Name -EQ "Attr1Name" | Select-Object -ExpandProperty value

        $Attr1Verify | Should -Be $Attr1Value

        Remove-JCUserGroup -GroupName $NewGroup.Name -force

    }

    It "Adds a VLAN attributes to a group that already has a custom attribute and uses Get-JCRadiusReplyAttributes to verify" {

        $NewGroup = New-JCUserGroup -GroupName $(New-RandomStringLower)

        $Attr1Name = "Attr1Name"

        $Attr1Value = "Attr1Value"

        $InitialAttributesAdd = Add-JCRadiusReplyAttribute -GroupName $NewGroup.Name -NumberOfAttributes 1 -Attribute1_name $Attr1Name -Attribute1_value $Attr1Value

        $VLAN = Get-Random -Minimum 1 -Maximum 4064

        $AttributesAddition = Add-JCRadiusReplyAttribute -VLAN $VLAN -GroupName $NewGroup.Name

        $AttributesAdd = Get-JCRadiusReplyAttribute -GroupName $NewGroup.Name

        $TunnelType = $AttributesAdd | Where-Object Name -EQ "Tunnel-Type" | Select-Object -ExpandProperty value

        $TunnelType | Should -Be "VLAN"

        $TunnelMediumType = $AttributesAdd | Where-Object Name -EQ "Tunnel-Medium-Type" | Select-Object -ExpandProperty value

        $TunnelMediumType | Should -Be "IEEE-802"

        $TunnelPrivateGroupID = $AttributesAdd | Where-Object Name -EQ "Tunnel-Private-Group-ID" | Select-Object -ExpandProperty value

        $TunnelPrivateGroupID | Should -Be $VLAN

        $Attr1Verify = $AttributesAdd | Where-Object Name -EQ "Attr1Name" | Select-Object -ExpandProperty value

        $Attr1Verify | Should -Be $Attr1Value

        Remove-JCUserGroup -GroupName $NewGroup.Name -force

    }

}
