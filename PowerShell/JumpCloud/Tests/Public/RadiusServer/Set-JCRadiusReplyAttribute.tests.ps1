Describe -Tag:('JCRadiusReplyAttribute') "Set-JCRadiusReplyAttribute 1.9.0" {
    BeforeAll { Connect-JCOnline -JumpCloudApiKey:($PesterParams_ApiKey) -force | Out-Null }
    It "Updates VLAN attributes on a group" {

        $NewGroup = New-JCUserGroup -GroupName $(New-RandomStringLower)

        $VLAN = Get-Random -Minimum 1 -Maximum 4064

        $AttributesAdd = Add-JCRadiusReplyAttribute -VLAN $VLAN -GroupName $NewGroup.Name

        $UpdateVLAN = Get-Random -Minimum 1 -Maximum 4064

        $AttributeUpdate = Set-JCRadiusReplyAttribute -VLAN $UpdateVLAN -GroupName $NewGroup.name

        $TunnelType = $AttributeUpdate | Where-Object Name -EQ "Tunnel-Type" | Select-Object -ExpandProperty value

        $TunnelType | Should -Be "VLAN"

        $TunnelMediumType = $AttributeUpdate | Where-Object Name -EQ "Tunnel-Medium-Type" | Select-Object -ExpandProperty value

        $TunnelMediumType | Should -Be "IEEE-802"

        $TunnelPrivateGroupID = $AttributeUpdate | Where-Object Name -EQ "Tunnel-Private-Group-ID" | Select-Object -ExpandProperty value

        $TunnelPrivateGroupID | Should -Be $UpdateVLAN

        Remove-JCUserGroup -GroupName $NewGroup.name -force

    }

    It "Updates VLAN attributes with tags on a group" {

        $NewGroup = New-JCUserGroup -GroupName $(New-RandomStringLower)

        $VLAN = Get-Random -Minimum 1 -Maximum 4064

        $VLANTag = Get-Random -Minimum 0 -Maximum 31

        $AttributesAdd = Add-JCRadiusReplyAttribute -VLAN $VLAN -GroupName $NewGroup.Name -VLANTag $VLANTag

        $UpdateVLAN = Get-Random -Minimum 1 -Maximum 4064

        $UpdateVLANTag = Get-Random -Minimum 0 -Maximum 31

        $AttributeUpdate = Set-JCRadiusReplyAttribute -VLAN $UpdateVLAN -GroupName $NewGroup.name -VLANTag $UpdateVLANTag

        $TunnelType = $AttributeUpdate | Where-Object Name -EQ "Tunnel-Type:$UpdateVLANTag" | Select-Object -ExpandProperty value

        $TunnelType | Should -Be "VLAN"

        $TunnelMediumType = $AttributeUpdate | Where-Object Name -EQ "Tunnel-Medium-Type:$UpdateVLANTag" | Select-Object -ExpandProperty value

        $TunnelMediumType | Should -Be "IEEE-802"

        $TunnelPrivateGroupID = $AttributeUpdate | Where-Object Name -EQ "Tunnel-Private-Group-ID:$UpdateVLANTag" | Select-Object -ExpandProperty value

        $TunnelPrivateGroupID | Should -Be $UpdateVLAN

        Remove-JCUserGroup -GroupName $NewGroup.name -force

    }

    It "Updates two custom radius attributes on a group" {

        $NewGroup = New-JCUserGroup -GroupName $(New-RandomStringLower)

        $Attr1Name = "Tunnel-Type:1"

        $Attr1Value = "VLAN"

        $Attr2Name = "Tunnel-Type:2"

        $Attr2Value = "VLAN2"

        $AttributesAdd = Add-JCRadiusReplyAttribute -GroupName $NewGroup.Name -NumberOfAttributes 2 -Attribute1_name $Attr1Name -Attribute1_value $Attr1Value -Attribute2_name $Attr2Name -Attribute2_value $Attr2Value

        $Attr1UpdatedVal = "VLAN3"

        $Attr2UpdatedValue = "VLAN4"

        $AttributesUpdate = Set-JCRadiusReplyAttribute -GroupName $NewGroup.Name -NumberOfAttributes 2 -Attribute1_name $Attr1Name -Attribute1_value $Attr1UpdatedVal -Attribute2_name $Attr2Name -Attribute2_value $Attr2UpdatedValue

        $Attr1Verify = $AttributesUpdate | Where-Object Name -EQ "Tunnel-Type:1" | Select-Object -ExpandProperty value

        $Attr1Verify | Should -Be $Attr1UpdatedVal

        $Attr2Verify = $AttributesUpdate | Where-Object Name -EQ "Tunnel-Type:2" | Select-Object -ExpandProperty value

        $Attr2Verify | Should -Be $Attr2UpdatedValue

        Remove-JCUserGroup -GroupName $NewGroup.name -force

    }

    It "Updates two custom radius attributes on a group and updates VLAN attributes" {

        $NewGroup = New-JCUserGroup -GroupName $(New-RandomStringLower)

        $Attr1Name = "Tunnel-Type:1"

        $Attr1Value = "VLAN"

        $Attr2Name = "Tunnel-Type:2"

        $Attr2Value = "VLAN2"

        $VLAN = Get-Random -Minimum 1 -Maximum 4064

        $AttributesAdd = Add-JCRadiusReplyAttribute -GroupName $NewGroup.Name -NumberOfAttributes 2 -Attribute1_name $Attr1Name -Attribute1_value $Attr1Value -Attribute2_name $Attr2Name -Attribute2_value $Attr2Value -VLAN $VLAN

        $Attr1UpdatedVal = "VLAN5"

        $Attr2UpdatedValue = "VLAN6"

        $UpdateVLAN = Get-Random -Minimum 1 -Maximum 4064

        $AttributesUpdate = Set-JCRadiusReplyAttribute -GroupName $NewGroup.Name -NumberOfAttributes 2 -Attribute1_name $Attr1Name -Attribute1_value $Attr1UpdatedVal -Attribute2_name $Attr2Name -Attribute2_value $Attr2UpdatedValue -VLAN $UpdateVLAN

        $Attr1Verify = $AttributesUpdate | Where-Object Name -EQ "Tunnel-Type:1" | Select-Object -ExpandProperty value

        $Attr1Verify | Should -Be $Attr1UpdatedVal

        $Attr2Verify = $AttributesUpdate | Where-Object Name -EQ "Tunnel-Type:2" | Select-Object -ExpandProperty value

        $Attr2Verify | Should -Be $Attr2UpdatedValue

        $TunnelType = $AttributesUpdate | Where-Object Name -EQ "Tunnel-Type" | Select-Object -ExpandProperty value

        $TunnelType | Should -Be "VLAN"

        $TunnelMediumType = $AttributesUpdate | Where-Object Name -EQ "Tunnel-Medium-Type" | Select-Object -ExpandProperty value

        $TunnelMediumType | Should -Be "IEEE-802"

        $TunnelPrivateGroupID = $AttributesUpdate | Where-Object Name -EQ "Tunnel-Private-Group-ID" | Select-Object -ExpandProperty value

        $TunnelPrivateGroupID | Should -Be $UpdateVLAN

        Remove-JCUserGroup -GroupName $NewGroup.name -force

    }
}
