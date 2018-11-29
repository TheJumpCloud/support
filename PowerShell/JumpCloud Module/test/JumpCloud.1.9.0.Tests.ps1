$SingleAdminAPIKey = ''
Describe "Connect-JCOnline" {

    It "Connects to JumpCloud with a single admin API Key using force" {
        
        $Connect = Connect-JCOnline -JumpCloudAPIKey $SingleAdminAPIKey -force
        $Connect | Should -be $null

    }
}


Describe "Add-JCRadiusReplyAttribute" {

    IT "Adds VLAN attributes to a group" {

        $NewGroup = New-JCUserGroup -GroupName $(New-RandomStringLower)

        $VLAN = Get-Random -Minimum 1 -Maximum 4064

        $AttributesAdd = Add-JCRadiusReplyAttribute -VLAN $VLAN -GroupName $NewGroup.Name

        $TunnelType = $AttributesAdd | ? Name -EQ "Tunnel-Type" | Select-Object -ExpandProperty value

        $TunnelType| Should -Be "VLAN"

        $TunnelMediumType = $AttributesAdd | ? Name -EQ "Tunnel-Medium-Type" | Select-Object -ExpandProperty value

        $TunnelMediumType| Should -Be "IEEE-802"

        $TunnelPrivateGroupID = $AttributesAdd | ? Name -EQ "Tunnel-Private-Group-ID" | Select-Object -ExpandProperty value

        $TunnelPrivateGroupID| Should -Be $VLAN

        Remove-JCUserGroup -GroupName $NewGroup.Name -force

    }

    IT "Adds VLAN attributes to a group with -VLANTag" {

        $NewGroup = New-JCUserGroup -GroupName $(New-RandomStringLower)

        $VLAN = Get-Random -Minimum 1 -Maximum 4064

        $VLANTag = Get-Random -Minimum 0 -Maximum 31

        $AttributesAdd = Add-JCRadiusReplyAttribute -VLAN $VLAN -GroupName $NewGroup.Name -VLANTag $VLANTag

        $TunnelType = $AttributesAdd | ? Name -EQ "Tunnel-Type:$VLANTag" | Select-Object -ExpandProperty value

        $TunnelType| Should -Be "VLAN"

        $TunnelMediumType = $AttributesAdd | ? Name -EQ "Tunnel-Medium-Type:$VLANTag" | Select-Object -ExpandProperty value

        $TunnelMediumType| Should -Be "IEEE-802"

        $TunnelPrivateGroupID = $AttributesAdd | ? Name -EQ "Tunnel-Private-Group-ID:$VLANTag" | Select-Object -ExpandProperty value

        $TunnelPrivateGroupID| Should -Be $VLAN

        Remove-JCUserGroup -GroupName $NewGroup.Name -force

    }


    IT "Adds a single custom radius attribute to a group" {

        $NewGroup = New-JCUserGroup -GroupName $(New-RandomStringLower)

        $Attr1Name = "Attr1Name"

        $Attr1Value = "Attr1Value"

        $AttributesAdd = Add-JCRadiusReplyAttribute -GroupName $NewGroup.Name -NumberOfAttributes 1 -Attribute1_name $Attr1Name -Attribute1_value $Attr1Value

        $Attr1Verify = $AttributesAdd | ? Name -EQ "Attr1Name" | Select-Object -ExpandProperty value

        $Attr1Verify| Should -Be $Attr1Value

        Remove-JCUserGroup -GroupName $NewGroup.Name -force

    }

    IT "Adds a single custom radius attribute to a group and VLAN attributes" {

        $NewGroup = New-JCUserGroup -GroupName $(New-RandomStringLower)

        $VLAN = Get-Random -Minimum 1 -Maximum 4064

        $Attr1Name = "Attr1Name"

        $Attr1Value = "Attr1Value"

        $AttributesAdd = Add-JCRadiusReplyAttribute -VLAN $VLAN -GroupName $NewGroup.Name -NumberOfAttributes 1 -Attribute1_name $Attr1Name -Attribute1_value $Attr1Value

        $TunnelType = $AttributesAdd | ? Name -EQ "Tunnel-Type" | Select-Object -ExpandProperty value

        $TunnelType| Should -Be "VLAN"

        $TunnelMediumType = $AttributesAdd | ? Name -EQ "Tunnel-Medium-Type" | Select-Object -ExpandProperty value

        $TunnelMediumType| Should -Be "IEEE-802"

        $TunnelPrivateGroupID = $AttributesAdd | ? Name -EQ "Tunnel-Private-Group-ID" | Select-Object -ExpandProperty value

        $TunnelPrivateGroupID| Should -Be $VLAN

        $Attr1Verify = $AttributesAdd | ? Name -EQ "Attr1Name" | Select-Object -ExpandProperty value

        $Attr1Verify| Should -Be $Attr1Value

        Remove-JCUserGroup -GroupName $NewGroup.Name -force

    }

    IT "Adds two custom radius attributes to a group" {

        $NewGroup = New-JCUserGroup -GroupName $(New-RandomStringLower)

        $Attr1Name = "Attr1Name"

        $Attr1Value = "Attr1Value"

        $Attr2Name = "Attr2Name"

        $Attr2Value = "Attr2Value"

        $AttributesAdd = Add-JCRadiusReplyAttribute -GroupName $NewGroup.Name -NumberOfAttributes 2 -Attribute1_name $Attr1Name -Attribute1_value $Attr1Value -Attribute2_name $Attr2Name -Attribute2_value $Attr2Value

        $Attr1Verify = $AttributesAdd | ? Name -EQ "Attr1Name" | Select-Object -ExpandProperty value

        $Attr1Verify| Should -Be $Attr1Value

        $Attr2Verify = $AttributesAdd | ? Name -EQ "Attr2Name" | Select-Object -ExpandProperty value

        $Attr2Verify| Should -Be $Attr2Value

        Remove-JCUserGroup -GroupName $NewGroup.Name -force

    }

    IT "Adds two custom radius attributes to a group and VLAN attributes" {

        $NewGroup = New-JCUserGroup -GroupName $(New-RandomStringLower)

        $VLAN = Get-Random -Minimum 1 -Maximum 4064

        $Attr1Name = "Attr1Name"

        $Attr1Value = "Attr1Value"

        $Attr2Name = "Attr2Name"

        $Attr2Value = "Attr2Value"

        $AttributesAdd = Add-JCRadiusReplyAttribute -GroupName $NewGroup.Name -NumberOfAttributes 2 -Attribute1_name $Attr1Name -Attribute1_value $Attr1Value -Attribute2_name $Attr2Name -Attribute2_value $Attr2Value -VLAN $VLAN

        $TunnelType = $AttributesAdd | ? Name -EQ "Tunnel-Type" | Select-Object -ExpandProperty value

        $TunnelType| Should -Be "VLAN"

        $TunnelMediumType = $AttributesAdd | ? Name -EQ "Tunnel-Medium-Type" | Select-Object -ExpandProperty value

        $TunnelMediumType| Should -Be "IEEE-802"

        $TunnelPrivateGroupID = $AttributesAdd | ? Name -EQ "Tunnel-Private-Group-ID" | Select-Object -ExpandProperty value

        $TunnelPrivateGroupID| Should -Be $VLAN

        $Attr1Verify = $AttributesAdd | ? Name -EQ "Attr1Name" | Select-Object -ExpandProperty value

        $Attr1Verify| Should -Be $Attr1Value

        $Attr2Verify = $AttributesAdd | ? Name -EQ "Attr2Name" | Select-Object -ExpandProperty value

        $Attr2Verify| Should -Be $Attr2Value

        Remove-JCUserGroup -GroupName $NewGroup.Name -force

    }

    IT "Adds three custom radius attributes to a group" {

        $NewGroup = New-JCUserGroup -GroupName $(New-RandomStringLower)

        $Attr1Name = "Attr1Name"

        $Attr1Value = "Attr1Value"

        $Attr2Name = "Attr2Name"

        $Attr2Value = "Attr2Value"

        $Attr3Name = "Attr3Name"

        $Attr3Value = "Attr3Value"

        $AttributesAdd = Add-JCRadiusReplyAttribute -GroupName $NewGroup.Name -NumberOfAttributes 3 -Attribute1_name $Attr1Name -Attribute1_value $Attr1Value -Attribute2_name $Attr2Name -Attribute2_value $Attr2Value -Attribute3_name $Attr3Name -Attribute3_value $Attr3Value

        $Attr1Verify = $AttributesAdd | ? Name -EQ "Attr1Name" | Select-Object -ExpandProperty value

        $Attr1Verify| Should -Be $Attr1Value

        $Attr2Verify = $AttributesAdd | ? Name -EQ "Attr2Name" | Select-Object -ExpandProperty value

        $Attr2Verify| Should -Be $Attr2Value

        $Attr3Verify = $AttributesAdd | ? Name -EQ "Attr3Name" | Select-Object -ExpandProperty value

        $Attr3Verify| Should -Be $Attr3Value

        Remove-JCUserGroup -GroupName $NewGroup.Name -force

    }
 
    IT "Adds a custom attribute to a group that already has VLAN attributes" {

        $NewGroup = New-JCUserGroup -GroupName $(New-RandomStringLower)

        $VLAN = Get-Random -Minimum 1 -Maximum 4064

        $InitialAttributesAdd = Add-JCRadiusReplyAttribute -VLAN $VLAN -GroupName $NewGroup.Name

        $Attr1Name = "Attr1Name"

        $Attr1Value = "Attr1Value"

        $AttributesAdd = Add-JCRadiusReplyAttribute -GroupName $NewGroup.Name -NumberOfAttributes 1 -Attribute1_name $Attr1Name -Attribute1_value $Attr1Value

        $TunnelType = $AttributesAdd | ? Name -EQ "Tunnel-Type" | Select-Object -ExpandProperty value

        $TunnelType| Should -Be "VLAN"

        $TunnelMediumType = $AttributesAdd | ? Name -EQ "Tunnel-Medium-Type" | Select-Object -ExpandProperty value

        $TunnelMediumType| Should -Be "IEEE-802"

        $TunnelPrivateGroupID = $AttributesAdd | ? Name -EQ "Tunnel-Private-Group-ID" | Select-Object -ExpandProperty value

        $TunnelPrivateGroupID| Should -Be $VLAN

        $Attr1Verify = $AttributesAdd | ? Name -EQ "Attr1Name" | Select-Object -ExpandProperty value

        $Attr1Verify| Should -Be $Attr1Value

        Remove-JCUserGroup -GroupName $NewGroup.Name -force

    }

    IT "Adds a VLAN attributes to a group that already has a custom attribute" {

        $NewGroup = New-JCUserGroup -GroupName $(New-RandomStringLower)

        $Attr1Name = "Attr1Name"

        $Attr1Value = "Attr1Value"

        $InitialAttributesAdd = Add-JCRadiusReplyAttribute -GroupName $NewGroup.Name -NumberOfAttributes 1 -Attribute1_name $Attr1Name -Attribute1_value $Attr1Value

        $VLAN = Get-Random -Minimum 1 -Maximum 4064

        $AttributesAdd = Add-JCRadiusReplyAttribute -VLAN $VLAN -GroupName $NewGroup.Name

        $TunnelType = $AttributesAdd | ? Name -EQ "Tunnel-Type" | Select-Object -ExpandProperty value

        $TunnelType| Should -Be "VLAN"

        $TunnelMediumType = $AttributesAdd | ? Name -EQ "Tunnel-Medium-Type" | Select-Object -ExpandProperty value

        $TunnelMediumType| Should -Be "IEEE-802"

        $TunnelPrivateGroupID = $AttributesAdd | ? Name -EQ "Tunnel-Private-Group-ID" | Select-Object -ExpandProperty value

        $TunnelPrivateGroupID| Should -Be $VLAN

        $Attr1Verify = $AttributesAdd | ? Name -EQ "Attr1Name" | Select-Object -ExpandProperty value

        $Attr1Verify| Should -Be $Attr1Value

        Remove-JCUserGroup -GroupName $NewGroup.Name -force

    }
}

Describe "Get-JCRadiusReplyAttribute" {

    It "Adds VLAN attributes to a group and uses Get-JCRadiusReplyAttributes to verify" {

        $NewGroup = New-JCUserGroup -GroupName $(New-RandomStringLower)

        $VLAN = Get-Random -Minimum 1 -Maximum 4064

        $AttributesAddition = Add-JCRadiusReplyAttribute -VLAN $VLAN -GroupName $NewGroup.Name

        $AttributesAdd = Get-JCRadiusReplyAttribute -GroupName $NewGroup.Name

        $TunnelType = $AttributesAdd | ? Name -EQ "Tunnel-Type" | Select-Object -ExpandProperty value

        $TunnelType| Should -Be "VLAN"

        $TunnelMediumType = $AttributesAdd | ? Name -EQ "Tunnel-Medium-Type" | Select-Object -ExpandProperty value

        $TunnelMediumType| Should -Be "IEEE-802"

        $TunnelPrivateGroupID = $AttributesAdd | ? Name -EQ "Tunnel-Private-Group-ID" | Select-Object -ExpandProperty value

        $TunnelPrivateGroupID| Should -Be $VLAN

        Remove-JCUserGroup -GroupName $NewGroup.Name -force

    }

    IT "Adds a single custom radius attribute to a group and uses Get-JCAttributes to verify" {

        $NewGroup = New-JCUserGroup -GroupName $(New-RandomStringLower)

        $Attr1Name = "Attr1Name"

        $Attr1Value = "Attr1Value"

        $AttributesAddition = Add-JCRadiusReplyAttribute -GroupName $NewGroup.Name -NumberOfAttributes 1 -Attribute1_name $Attr1Name -Attribute1_value $Attr1Value

        $AttributesAdd = Get-JCRadiusReplyAttribute -GroupName $NewGroup.Name

        $Attr1Verify = $AttributesAdd | ? Name -EQ "Attr1Name" | Select-Object -ExpandProperty value

        $Attr1Verify| Should -Be $Attr1Value

        Remove-JCUserGroup -GroupName $NewGroup.Name -force

    }

    IT "Adds a single custom radius attribute to a group and VLAN attributes and uses Get-JCRadiusReplyAttributes to verify" {

        $NewGroup = New-JCUserGroup -GroupName $(New-RandomStringLower)

        $VLAN = Get-Random -Minimum 1 -Maximum 4064

        $Attr1Name = "Attr1Name"

        $Attr1Value = "Attr1Value"

        $AttributesAddition = Add-JCRadiusReplyAttribute -VLAN $VLAN -GroupName $NewGroup.Name -NumberOfAttributes 1 -Attribute1_name $Attr1Name -Attribute1_value $Attr1Value

        $AttributesAdd = Get-JCRadiusReplyAttribute -GroupName $NewGroup.name

        $TunnelType = $AttributesAdd | ? Name -EQ "Tunnel-Type" | Select-Object -ExpandProperty value

        $TunnelType| Should -Be "VLAN"

        $TunnelMediumType = $AttributesAdd | ? Name -EQ "Tunnel-Medium-Type" | Select-Object -ExpandProperty value

        $TunnelMediumType| Should -Be "IEEE-802"

        $TunnelPrivateGroupID = $AttributesAdd | ? Name -EQ "Tunnel-Private-Group-ID" | Select-Object -ExpandProperty value

        $TunnelPrivateGroupID| Should -Be $VLAN

        $Attr1Verify = $AttributesAdd | ? Name -EQ "Attr1Name" | Select-Object -ExpandProperty value

        $Attr1Verify| Should -Be $Attr1Value

        Remove-JCUserGroup -GroupName $NewGroup.Name -force

    }

    IT "Adds two custom radius attributes to a group and uses Get-JCRadiusReplyAttributes to verify" {

        $NewGroup = New-JCUserGroup -GroupName $(New-RandomStringLower)

        $Attr1Name = "Attr1Name"

        $Attr1Value = "Attr1Value"

        $Attr2Name = "Attr2Name"

        $Attr2Value = "Attr2Value"

        $AttributesAddition = Add-JCRadiusReplyAttribute -GroupName $NewGroup.Name -NumberOfAttributes 2 -Attribute1_name $Attr1Name -Attribute1_value $Attr1Value -Attribute2_name $Attr2Name -Attribute2_value $Attr2Value

        $AttributesAdd = Get-JCRadiusReplyAttribute -GroupName $NewGroup.name

        $Attr1Verify = $AttributesAdd | ? Name -EQ "Attr1Name" | Select-Object -ExpandProperty value

        $Attr1Verify| Should -Be $Attr1Value

        $Attr2Verify = $AttributesAdd | ? Name -EQ "Attr2Name" | Select-Object -ExpandProperty value

        $Attr2Verify| Should -Be $Attr2Value

        Remove-JCUserGroup -GroupName $NewGroup.Name -force

    }

    IT "Adds two custom radius attributes to a group and VLAN attributes and uses Get-JCRadiusReplyAttributes to verify" {

        $NewGroup = New-JCUserGroup -GroupName $(New-RandomStringLower)

        $VLAN = Get-Random -Minimum 1 -Maximum 4064

        $Attr1Name = "Attr1Name"

        $Attr1Value = "Attr1Value"

        $Attr2Name = "Attr2Name"

        $Attr2Value = "Attr2Value"

        $AttributesAddition = Add-JCRadiusReplyAttribute -GroupName $NewGroup.Name -NumberOfAttributes 2 -Attribute1_name $Attr1Name -Attribute1_value $Attr1Value -Attribute2_name $Attr2Name -Attribute2_value $Attr2Value -VLAN $VLAN

        $AttributesAdd = Get-JCRadiusReplyAttribute -GroupName $NewGroup.Name

        $TunnelType = $AttributesAdd | ? Name -EQ "Tunnel-Type" | Select-Object -ExpandProperty value

        $TunnelType| Should -Be "VLAN"

        $TunnelMediumType = $AttributesAdd | ? Name -EQ "Tunnel-Medium-Type" | Select-Object -ExpandProperty value

        $TunnelMediumType| Should -Be "IEEE-802"

        $TunnelPrivateGroupID = $AttributesAdd | ? Name -EQ "Tunnel-Private-Group-ID" | Select-Object -ExpandProperty value

        $TunnelPrivateGroupID| Should -Be $VLAN

        $Attr1Verify = $AttributesAdd | ? Name -EQ "Attr1Name" | Select-Object -ExpandProperty value

        $Attr1Verify| Should -Be $Attr1Value

        $Attr2Verify = $AttributesAdd | ? Name -EQ "Attr2Name" | Select-Object -ExpandProperty value

        $Attr2Verify| Should -Be $Attr2Value

        Remove-JCUserGroup -GroupName $NewGroup.Name -force

    }

    IT "Adds three custom radius attributes to a group and uses Get-JCRadiusReplyAttributes to verify" {

        $NewGroup = New-JCUserGroup -GroupName $(New-RandomStringLower)

        $Attr1Name = "Attr1Name"

        $Attr1Value = "Attr1Value"

        $Attr2Name = "Attr2Name"

        $Attr2Value = "Attr2Value"

        $Attr3Name = "Attr3Name"

        $Attr3Value = "Attr3Value"

        $AttributesAddition = Add-JCRadiusReplyAttribute -GroupName $NewGroup.Name -NumberOfAttributes 3 -Attribute1_name $Attr1Name -Attribute1_value $Attr1Value -Attribute2_name $Attr2Name -Attribute2_value $Attr2Value -Attribute3_name $Attr3Name -Attribute3_value $Attr3Value

        $AttributesAdd = Get-JCRadiusReplyAttribute -GroupName $NewGroup.Name

        $Attr1Verify = $AttributesAdd | ? Name -EQ "Attr1Name" | Select-Object -ExpandProperty value

        $Attr1Verify| Should -Be $Attr1Value

        $Attr2Verify = $AttributesAdd | ? Name -EQ "Attr2Name" | Select-Object -ExpandProperty value

        $Attr2Verify| Should -Be $Attr2Value

        $Attr3Verify = $AttributesAdd | ? Name -EQ "Attr3Name" | Select-Object -ExpandProperty value

        $Attr3Verify| Should -Be $Attr3Value

        Remove-JCUserGroup -GroupName $NewGroup.Name -force

    }
 
    IT "Adds a custom attribute to a group that already has VLAN attributes and uses Get-JCRadiusReplyAttributes to verify" {

        $NewGroup = New-JCUserGroup -GroupName $(New-RandomStringLower)

        $VLAN = Get-Random -Minimum 1 -Maximum 4064

        $InitialAttributesAdd = Add-JCRadiusReplyAttribute -VLAN $VLAN -GroupName $NewGroup.Name

        $Attr1Name = "Attr1Name"

        $Attr1Value = "Attr1Value"

        $AttributesAddition = Add-JCRadiusReplyAttribute -GroupName $NewGroup.Name -NumberOfAttributes 1 -Attribute1_name $Attr1Name -Attribute1_value $Attr1Value

        $AttributesAdd = Get-JCRadiusReplyAttribute -GroupName $NewGroup.name

        $TunnelType = $AttributesAdd | ? Name -EQ "Tunnel-Type" | Select-Object -ExpandProperty value

        $TunnelType| Should -Be "VLAN"

        $TunnelMediumType = $AttributesAdd | ? Name -EQ "Tunnel-Medium-Type" | Select-Object -ExpandProperty value

        $TunnelMediumType| Should -Be "IEEE-802"

        $TunnelPrivateGroupID = $AttributesAdd | ? Name -EQ "Tunnel-Private-Group-ID" | Select-Object -ExpandProperty value

        $TunnelPrivateGroupID| Should -Be $VLAN

        $Attr1Verify = $AttributesAdd | ? Name -EQ "Attr1Name" | Select-Object -ExpandProperty value

        $Attr1Verify| Should -Be $Attr1Value

        Remove-JCUserGroup -GroupName $NewGroup.Name -force

    }

    IT "Adds a VLAN attributes to a group that already has a custom attribute and uses Get-JCRadiusReplyAttributes to verify" {

        $NewGroup = New-JCUserGroup -GroupName $(New-RandomStringLower)

        $Attr1Name = "Attr1Name"

        $Attr1Value = "Attr1Value"

        $InitialAttributesAdd = Add-JCRadiusReplyAttribute -GroupName $NewGroup.Name -NumberOfAttributes 1 -Attribute1_name $Attr1Name -Attribute1_value $Attr1Value

        $VLAN = Get-Random -Minimum 1 -Maximum 4064

        $AttributesAddition = Add-JCRadiusReplyAttribute -VLAN $VLAN -GroupName $NewGroup.Name

        $AttributesAdd = Get-JCRadiusReplyAttribute -GroupName $NewGroup.Name

        $TunnelType = $AttributesAdd | ? Name -EQ "Tunnel-Type" | Select-Object -ExpandProperty value

        $TunnelType| Should -Be "VLAN"

        $TunnelMediumType = $AttributesAdd | ? Name -EQ "Tunnel-Medium-Type" | Select-Object -ExpandProperty value

        $TunnelMediumType| Should -Be "IEEE-802"

        $TunnelPrivateGroupID = $AttributesAdd | ? Name -EQ "Tunnel-Private-Group-ID" | Select-Object -ExpandProperty value

        $TunnelPrivateGroupID| Should -Be $VLAN

        $Attr1Verify = $AttributesAdd | ? Name -EQ "Attr1Name" | Select-Object -ExpandProperty value

        $Attr1Verify| Should -Be $Attr1Value

        Remove-JCUserGroup -GroupName $NewGroup.Name -force

    }

}

Describe "Set-JCRadiusReplyAttribute" {

    IT "Updates VLAN attributes on a group" {

        $NewGroup = New-JCUserGroup -GroupName $(New-RandomStringLower)

        $VLAN = Get-Random -Minimum 1 -Maximum 4064

        $AttributesAdd = Add-JCRadiusReplyAttribute -VLAN $VLAN -GroupName $NewGroup.Name

        $UpdateVLAN = Get-Random -Minimum 1 -Maximum 4064

        $AttributeUpdate = Set-JCRadiusReplyAttribute -VLAN $UpdateVLAN -GroupName $NewGroup.name

        $TunnelType = $AttributeUpdate | ? Name -EQ "Tunnel-Type" | Select-Object -ExpandProperty value

        $TunnelType| Should -Be "VLAN"

        $TunnelMediumType = $AttributeUpdate | ? Name -EQ "Tunnel-Medium-Type" | Select-Object -ExpandProperty value

        $TunnelMediumType| Should -Be "IEEE-802"

        $TunnelPrivateGroupID = $AttributeUpdate | ? Name -EQ "Tunnel-Private-Group-ID" | Select-Object -ExpandProperty value

        $TunnelPrivateGroupID| Should -Be $UpdateVLAN

        Remove-JCUserGroup -GroupName $NewGroup.name -force

    }

    IT "Updates VLAN attributes with tags on a group" {

        $NewGroup = New-JCUserGroup -GroupName $(New-RandomStringLower)

        $VLAN = Get-Random -Minimum 1 -Maximum 4064

        $VLANTag = Get-Random -Minimum 0 -Maximum 31

        $AttributesAdd = Add-JCRadiusReplyAttribute -VLAN $VLAN -GroupName $NewGroup.Name -VLANTag $VLANTag

        $UpdateVLAN = Get-Random -Minimum 1 -Maximum 4064

        $UpdateVLANTag = Get-Random -Minimum 0 -Maximum 31

        $AttributeUpdate = Set-JCRadiusReplyAttribute -VLAN $UpdateVLAN -GroupName $NewGroup.name -VLANTag $UpdateVLANTag

        $TunnelType = $AttributeUpdate | ? Name -EQ "Tunnel-Type:$UpdateVLANTag" | Select-Object -ExpandProperty value

        $TunnelType| Should -Be "VLAN"

        $TunnelMediumType = $AttributeUpdate | ? Name -EQ "Tunnel-Medium-Type:$UpdateVLANTag" | Select-Object -ExpandProperty value

        $TunnelMediumType| Should -Be "IEEE-802"

        $TunnelPrivateGroupID = $AttributeUpdate | ? Name -EQ "Tunnel-Private-Group-ID:$UpdateVLANTag" | Select-Object -ExpandProperty value

        $TunnelPrivateGroupID| Should -Be $UpdateVLAN

        Remove-JCUserGroup -GroupName $NewGroup.name -force

    }

    IT "Updates two custom radius attributes on a group" {

        $NewGroup = New-JCUserGroup -GroupName $(New-RandomStringLower)

        $Attr1Name = "Attr1Name"

        $Attr1Value = "Attr1Value"

        $Attr2Name = "Attr2Name"

        $Attr2Value = "Attr2Value"

        $AttributesAdd = Add-JCRadiusReplyAttribute -GroupName $NewGroup.Name -NumberOfAttributes 2 -Attribute1_name $Attr1Name -Attribute1_value $Attr1Value -Attribute2_name $Attr2Name -Attribute2_value $Attr2Value 

        $Attr1UpdatedVal = "Attr1ValueUp"

        $Attr2UpdatedValue = "Attr2ValueUp"

        $AttributesUpdate = Set-JCRadiusReplyAttribute -GroupName $NewGroup.Name -NumberOfAttributes 2 -Attribute1_name $Attr1Name -Attribute1_value $Attr1UpdatedVal -Attribute2_name $Attr2Name -Attribute2_value $Attr2UpdatedValue

        $Attr1Verify = $AttributesUpdate | ? Name -EQ "Attr1Name" | Select-Object -ExpandProperty value

        $Attr1Verify| Should -Be $Attr1UpdatedVal

        $Attr2Verify = $AttributesUpdate | ? Name -EQ "Attr2Name" | Select-Object -ExpandProperty value

        $Attr2Verify| Should -Be $Attr2UpdatedValue

        Remove-JCUserGroup -GroupName $NewGroup.name -force
    
    }

    IT "Updates two custom radius attributes on a group and updates VLAN attributes" {

        $NewGroup = New-JCUserGroup -GroupName $(New-RandomStringLower)

        $Attr1Name = "Attr1Name"

        $Attr1Value = "Attr1Value"

        $Attr2Name = "Attr2Name"

        $Attr2Value = "Attr2Value"

        $VLAN = Get-Random -Minimum 1 -Maximum 4064

        $AttributesAdd = Add-JCRadiusReplyAttribute -GroupName $NewGroup.Name -NumberOfAttributes 2 -Attribute1_name $Attr1Name -Attribute1_value $Attr1Value -Attribute2_name $Attr2Name -Attribute2_value $Attr2Value -VLAN $VLAN

        $Attr1UpdatedVal = "Attr1ValueUp"

        $Attr2UpdatedValue = "Attr2ValueUp"

        $UpdateVLAN = Get-Random -Minimum 1 -Maximum 4064


        $AttributesUpdate = Set-JCRadiusReplyAttribute -GroupName $NewGroup.Name -NumberOfAttributes 2 -Attribute1_name $Attr1Name -Attribute1_value $Attr1UpdatedVal -Attribute2_name $Attr2Name -Attribute2_value $Attr2UpdatedValue -VLAN $UpdateVLAN

        $Attr1Verify = $AttributesUpdate | ? Name -EQ "Attr1Name" | Select-Object -ExpandProperty value

        $Attr1Verify| Should -Be $Attr1UpdatedVal

        $Attr2Verify = $AttributesUpdate | ? Name -EQ "Attr2Name" | Select-Object -ExpandProperty value

        $Attr2Verify| Should -Be $Attr2UpdatedValue

        $TunnelType = $AttributesUpdate | ? Name -EQ "Tunnel-Type" | Select-Object -ExpandProperty value

        $TunnelType| Should -Be "VLAN"

        $TunnelMediumType = $AttributesUpdate | ? Name -EQ "Tunnel-Medium-Type" | Select-Object -ExpandProperty value

        $TunnelMediumType| Should -Be "IEEE-802"

        $TunnelPrivateGroupID = $AttributesUpdate | ? Name -EQ "Tunnel-Private-Group-ID" | Select-Object -ExpandProperty value

        $TunnelPrivateGroupID| Should -Be $UpdateVLAN

        Remove-JCUserGroup -GroupName $NewGroup.name -force

    }
}

Describe "Remove-JCRadiusReplyAttributes" {

    IT "Removes a single custom radius attribute from a group" {

        $NewGroup = New-JCUserGroup -GroupName $(New-RandomStringLower)

        $Attr1Name = "Attr1Name"

        $Attr1Value = "Attr1Value"

        $Attr2Name = "Attr2Name"

        $Attr2Value = "Attr2Value"

        $AttributesAdd = Add-JCRadiusReplyAttribute -GroupName $NewGroup.Name -NumberOfAttributes 2 -Attribute1_name $Attr1Name -Attribute1_value $Attr1Value -Attribute2_name $Attr2Name -Attribute2_value $Attr2Value

        $AttributesRemove = Remove-JCRadiusReplyAttribute -GroupName $NewGroup.Name -AttributeName $Attr1Name

        $Attr1Verify = $AttributesRemove | ? Name -EQ "Attr1Name" | Select-Object -ExpandProperty value

        $Attr1Verify| Should -Be $null

        $Attr2Verify = $AttributesRemove | ? Name -EQ "Attr2Name" | Select-Object -ExpandProperty value

        $Attr2Verify| Should -Be $Attr2Value

        Remove-JCUserGroup -GroupName $NewGroup.Name -force

    }

    IT "Removes two custom radius attributes from a group" {

        $NewGroup = New-JCUserGroup -GroupName $(New-RandomStringLower)

        $Attr1Name = "Attr1Name"

        $Attr1Value = "Attr1Value"

        $Attr2Name = "Attr2Name"

        $Attr2Value = "Attr2Value"

        $AttributesAdd = Add-JCRadiusReplyAttribute -GroupName $NewGroup.Name -NumberOfAttributes 2 -Attribute1_name $Attr1Name -Attribute1_value $Attr1Value -Attribute2_name $Attr2Name -Attribute2_value $Attr2Value

        $AttributesRemove = Remove-JCRadiusReplyAttribute -GroupName $NewGroup.Name -AttributeName $Attr1Name, $Attr2Name

        $Attr1Verify = $AttributesRemove | ? Name -EQ "Attr1Name" | Select-Object -ExpandProperty value

        $Attr1Verify| Should -Be $null

        $Attr2Verify = $AttributesRemove | ? Name -EQ "Attr2Name" | Select-Object -ExpandProperty value

        $Attr2Verify| Should -Be $null

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