// Global params
var location = 'koreacentral'

//VNET
resource v_net 'Microsoft.Network/virtualNetworks@2020-07-01' = {
  name: 'vnet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'snet-a'
        properties: {
          addressPrefix: '10.0.1.0/24'
          serviceEndpoints: [
              {
                service: 'Microsoft.Storage'
                locations:[
                  '*'
                ]
              }
            ]
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Disabled'
        }
      }
      {
        name: 'snet-b'
        properties: {
          addressPrefix: '10.0.2.0/24'
          serviceEndpoints: [
            ]
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Disabled'
        }
      }
    ]
  }   
}

// VM Settings
param ubuntuOsVersion string = '18.04-LTS'
param osDiskType string = 'Standard_LRS'
param vmSize string = 'Standard_B1s'
param username string
@secure()
param password string

// VM 1
param vm1name string = 'vm1' 

module nicvm1 './networkinterface.bicep' = {
  name: '${vm1name}-nic'
  params: {
    namePrefix: '${vm1name}-nic'
    subnetId: v_net.properties.subnets[0].id
    privateIPAddress: '10.0.1.6'
  }
}

resource vm1 'Microsoft.Compute/virtualMachines@2021-03-01' = {
  name: vm1name
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: osDiskType
        }
      }
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: ubuntuOsVersion
        version: 'latest'
      }
    }
    osProfile: {
      computerName: vm1name
      adminUsername: username
      adminPassword: password
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nicvm1.outputs.nicId
        }
      ]
    }
  }
  
}


// VM 2
param vm2name string = 'vm2' 

module nicvm2 './networkinterface.bicep' = {
  name: '${vm2name}-nic'
  params: {
    namePrefix: '${vm2name}-nic'
    subnetId: v_net.properties.subnets[1].id
    privateIPAddress: '10.0.2.6'
  }
}

resource vm2 'Microsoft.Compute/virtualMachines@2021-03-01' = {
  name: vm2name
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: osDiskType
        }
      }
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: ubuntuOsVersion
        version: 'latest'
      }
    }
    osProfile: {
      computerName: vm2name
      adminUsername: username
      adminPassword: password
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nicvm2.outputs.nicId
        }
      ]
    }
  }
  
}

// Storage
var storagename = 'lala${uniqueString(resourceGroup().id)}'

resource storage 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  dependsOn: [
    nicvm1
    nicvm2
    v_net
  ]
  name: storagename
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    allowBlobPublicAccess: false
    supportsHttpsTrafficOnly: true 
    networkAcls: {
      defaultAction: 'Deny'
      // not possible to do references here
      // see https://github.com/Azure/azure-cli/issues/14404 still open on 2021-07-06
      // ipRules: [
      //   {
      //     action: 'Allow'
      //     value:
      //   }
      // ]

      // virtualNetworkRules: [
      //   {
      //     action: 'Allow'
      //     id: v_net.properties.subnets[0].id
      //   }
      // ]
    }
  }
}
