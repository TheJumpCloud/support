Describe -Tag:('JCRadiusReplyAttribute') "Add-JCRadiusReplyAttribute 1.9.0" {
    BeforeAll { Connect-JCOnline -JumpCloudApiKey:($PesterParams_ApiKey) -force | Out-Null }
    It "Adds VLAN attributes to a group" {

        $NewGroup = New-JCUserGroup -GroupName $(New-RandomStringLower)

        $VLAN = Get-Random -Minimum 1 -Maximum 4064

        $AttributesAdd = Add-JCRadiusReplyAttribute -VLAN $VLAN -GroupName $NewGroup.Name

        $TunnelType = $AttributesAdd | Where-Object Name -EQ "Tunnel-Type" | Select-Object -ExpandProperty value

        $TunnelType | Should -Be "VLAN"

        $TunnelMediumType = $AttributesAdd | Where-Object Name -EQ "Tunnel-Medium-Type" | Select-Object -ExpandProperty value

        $TunnelMediumType | Should -Be "IEEE-802"

        $TunnelPrivateGroupID = $AttributesAdd | Where-Object Name -EQ "Tunnel-Private-Group-ID" | Select-Object -ExpandProperty value

        $TunnelPrivateGroupID | Should -Be $VLAN

        Remove-JCUserGroup -GroupName $NewGroup.Name -force

    }

    It "Adds VLAN attributes to a group with -VLANTag" {

        $NewGroup = New-JCUserGroup -GroupName $(New-RandomStringLower)

        $VLAN = Get-Random -Minimum 1 -Maximum 4064

        $VLANTag = Get-Random -Minimum 1 -Maximum 31

        $AttributesAdd = Add-JCRadiusReplyAttribute -VLAN $VLAN -GroupName $NewGroup.Name -VLANTag $VLANTag

        $TunnelType = $AttributesAdd | Where-Object Name -EQ "Tunnel-Type:$VLANTag" | Select-Object -ExpandProperty value

        $TunnelType | Should -Be "VLAN"

        $TunnelMediumType = $AttributesAdd | Where-Object Name -EQ "Tunnel-Medium-Type:$VLANTag" | Select-Object -ExpandProperty value

        $TunnelMediumType | Should -Be "IEEE-802"

        $TunnelPrivateGroupID = $AttributesAdd | Where-Object Name -EQ "Tunnel-Private-Group-ID:$VLANTag" | Select-Object -ExpandProperty value

        $TunnelPrivateGroupID | Should -Be $VLAN

        Remove-JCUserGroup -GroupName $NewGroup.Name -force

    }


    It "Adds a single custom radius attribute to a group" {

        $NewGroup = New-JCUserGroup -GroupName $(New-RandomStringLower)

        $Attr1Name = "Tunnel-Type"

        $Attr1Value = "VLAN"

        $AttributesAdd = Add-JCRadiusReplyAttribute -GroupName $NewGroup.Name -NumberOfAttributes 1 -Attribute1_name $Attr1Name -Attribute1_value $Attr1Value

        $Attr1Verify = $AttributesAdd | Where-Object Name -EQ "Tunnel-Type" | Select-Object -ExpandProperty value

        $Attr1Verify | Should -Be $Attr1Value

        Remove-JCUserGroup -GroupName $NewGroup.Name -force

    }

    It "Adds a single custom radius attribute to a group and VLAN attributes" {

        $NewGroup = New-JCUserGroup -GroupName $(New-RandomStringLower)

        $VLAN = Get-Random -Minimum 1 -Maximum 4064

        $Attr1Name = "Tunnel-Type:1"

        $Attr1Value = "VLAN"

        $AttributesAdd = Add-JCRadiusReplyAttribute -VLAN $VLAN -GroupName $NewGroup.Name -NumberOfAttributes 1 -Attribute1_name $Attr1Name -Attribute1_value $Attr1Value

        $TunnelType = $AttributesAdd | Where-Object Name -EQ "Tunnel-Type" | Select-Object -ExpandProperty value

        $TunnelType | Should -Be "VLAN"

        $TunnelMediumType = $AttributesAdd | Where-Object Name -EQ "Tunnel-Medium-Type" | Select-Object -ExpandProperty value

        $TunnelMediumType | Should -Be "IEEE-802"

        $TunnelPrivateGroupID = $AttributesAdd | Where-Object Name -EQ "Tunnel-Private-Group-ID" | Select-Object -ExpandProperty value

        $TunnelPrivateGroupID | Should -Be $VLAN

        $Attr1Verify = $AttributesAdd | Where-Object Name -EQ "Tunnel-Type:1" | Select-Object -ExpandProperty value

        $Attr1Verify | Should -Be $Attr1Value

        Remove-JCUserGroup -GroupName $NewGroup.Name -force

    }

    It "Adds two custom radius attributes to a group" {

        $NewGroup = New-JCUserGroup -GroupName $(New-RandomStringLower)

        $Attr1Name = "Tunnel-Type:1"

        $Attr1Value = "VLAN"

        $Attr2Name = "Tunnel-Type:2"

        $Attr2Value = "VLAN2"

        $AttributesAdd = Add-JCRadiusReplyAttribute -GroupName $NewGroup.Name -NumberOfAttributes 2 -Attribute1_name $Attr1Name -Attribute1_value $Attr1Value -Attribute2_name $Attr2Name -Attribute2_value $Attr2Value

        $Attr1Verify = $AttributesAdd | Where-Object Name -EQ "Tunnel-Type:1" | Select-Object -ExpandProperty value

        $Attr1Verify | Should -Be $Attr1Value

        $Attr2Verify = $AttributesAdd | Where-Object Name -EQ "Tunnel-Type:2" | Select-Object -ExpandProperty value

        $Attr2Verify | Should -Be $Attr2Value

        Remove-JCUserGroup -GroupName $NewGroup.Name -force

    }

    It "Adds two custom radius attributes to a group and VLAN attributes" {

        $NewGroup = New-JCUserGroup -GroupName $(New-RandomStringLower)

        $VLAN = Get-Random -Minimum 1 -Maximum 4064

        $Attr1Name = "Tunnel-Type:1"

        $Attr1Value = "VLAN"

        $Attr2Name = "Tunnel-Type:2"

        $Attr2Value = "VLAN2"

        $AttributesAdd = Add-JCRadiusReplyAttribute -GroupName $NewGroup.Name -NumberOfAttributes 2 -Attribute1_name $Attr1Name -Attribute1_value $Attr1Value -Attribute2_name $Attr2Name -Attribute2_value $Attr2Value -VLAN $VLAN

        $TunnelType = $AttributesAdd | Where-Object Name -EQ "Tunnel-Type" | Select-Object -ExpandProperty value

        $TunnelType | Should -Be "VLAN"

        $TunnelMediumType = $AttributesAdd | Where-Object Name -EQ "Tunnel-Medium-Type" | Select-Object -ExpandProperty value

        $TunnelMediumType | Should -Be "IEEE-802"

        $TunnelPrivateGroupID = $AttributesAdd | Where-Object Name -EQ "Tunnel-Private-Group-ID" | Select-Object -ExpandProperty value

        $TunnelPrivateGroupID | Should -Be $VLAN

        $Attr1Verify = $AttributesAdd | Where-Object Name -EQ "Tunnel-Type:1" | Select-Object -ExpandProperty value

        $Attr1Verify | Should -Be $Attr1Value

        $Attr2Verify = $AttributesAdd | Where-Object Name -EQ "Tunnel-Type:2" | Select-Object -ExpandProperty value

        $Attr2Verify | Should -Be $Attr2Value

        Remove-JCUserGroup -GroupName $NewGroup.Name -force

    }

    It "Adds three custom radius attributes to a group" {

        $NewGroup = New-JCUserGroup -GroupName $(New-RandomStringLower)

        $Attr1Name = "Tunnel-Type:1"

        $Attr1Value = "VLAN"

        $Attr2Name = "Tunnel-Type:2"

        $Attr2Value = "VLAN2"

        $Attr3Name = "Tunnel-Type:3"

        $Attr3Value = "VLAN3"

        $AttributesAdd = Add-JCRadiusReplyAttribute -GroupName $NewGroup.Name -NumberOfAttributes 3 -Attribute1_name $Attr1Name -Attribute1_value $Attr1Value -Attribute2_name $Attr2Name -Attribute2_value $Attr2Value -Attribute3_name $Attr3Name -Attribute3_value $Attr3Value

        $Attr1Verify = $AttributesAdd | Where-Object Name -EQ "Tunnel-Type:1" | Select-Object -ExpandProperty value

        $Attr1Verify | Should -Be $Attr1Value

        $Attr2Verify = $AttributesAdd | Where-Object Name -EQ "Tunnel-Type:2" | Select-Object -ExpandProperty value

        $Attr2Verify | Should -Be $Attr2Value

        $Attr3Verify = $AttributesAdd | Where-Object Name -EQ "Tunnel-Type:3" | Select-Object -ExpandProperty value

        $Attr3Verify | Should -Be $Attr3Value

        Remove-JCUserGroup -GroupName $NewGroup.Name -force

    }

    It "Adds a custom attribute to a group that already has VLAN attributes" {

        $NewGroup = New-JCUserGroup -GroupName $(New-RandomStringLower)

        $VLAN = Get-Random -Minimum 1 -Maximum 4064

        $InitialAttributesAdd = Add-JCRadiusReplyAttribute -VLAN $VLAN -GroupName $NewGroup.Name

        $Attr1Name = "Tunnel-Type:1"

        $Attr1Value = "VLAN"

        $AttributesAdd = Add-JCRadiusReplyAttribute -GroupName $NewGroup.Name -NumberOfAttributes 1 -Attribute1_name $Attr1Name -Attribute1_value $Attr1Value

        $TunnelType = $AttributesAdd | Where-Object Name -EQ "Tunnel-Type" | Select-Object -ExpandProperty value

        $TunnelType | Should -Be "VLAN"

        $TunnelMediumType = $AttributesAdd | Where-Object Name -EQ "Tunnel-Medium-Type" | Select-Object -ExpandProperty value

        $TunnelMediumType | Should -Be "IEEE-802"

        $TunnelPrivateGroupID = $AttributesAdd | Where-Object Name -EQ "Tunnel-Private-Group-ID" | Select-Object -ExpandProperty value

        $TunnelPrivateGroupID | Should -Be $VLAN

        $Attr1Verify = $AttributesAdd | Where-Object Name -EQ "Tunnel-Type:1" | Select-Object -ExpandProperty value

        $Attr1Verify | Should -Be $Attr1Value

        Remove-JCUserGroup -GroupName $NewGroup.Name -force

    }

    It "Adds a VLAN attributes to a group that already has a custom attribute" {

        $NewGroup = New-JCUserGroup -GroupName $(New-RandomStringLower)

        $Attr1Name = "Location-Information"

        $Attr1Value = "123"

        $InitialAttributesAdd = Add-JCRadiusReplyAttribute -GroupName $NewGroup.Name -NumberOfAttributes 1 -Attribute1_name $Attr1Name -Attribute1_value $Attr1Value

        $VLAN = Get-Random -Minimum 1 -Maximum 4064

        $AttributesAdd = Add-JCRadiusReplyAttribute -VLAN $VLAN -GroupName $NewGroup.Name

        $TunnelType = $AttributesAdd | Where-Object Name -EQ "Tunnel-Type" | Select-Object -ExpandProperty value

        $TunnelType | Should -Be "VLAN"

        $TunnelMediumType = $AttributesAdd | Where-Object Name -EQ "Tunnel-Medium-Type" | Select-Object -ExpandProperty value

        $TunnelMediumType | Should -Be "IEEE-802"

        $TunnelPrivateGroupID = $AttributesAdd | Where-Object Name -EQ "Tunnel-Private-Group-ID" | Select-Object -ExpandProperty value

        $TunnelPrivateGroupID | Should -Be $VLAN

        $Attr1Verify = $AttributesAdd | Where-Object Name -EQ "Location-Information" | Select-Object -ExpandProperty value

        $Attr1Verify | Should -Be $Attr1Value

        Remove-JCUserGroup -GroupName $NewGroup.Name -force

    }
}
