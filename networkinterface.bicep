param namePrefix string = 'unique'
param location string = resourceGroup().location
param subnetId string
param privateIPAddress string

var interfaceName = '${namePrefix}${uniqueString(resourceGroup().id)}'

resource pip 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
  name: interfaceName
  location: location
  sku: {
    name: 'Basic'
    tier: 'Regional'
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2020-08-01' = {
  name: interfaceName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAddress: privateIPAddress
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetId
          }
          publicIPAddress: {
            id: pip.id
          }
          primary: true
          privateIPAddressVersion: 'IPv4'
        }
      }
    ]
    dnsSettings: {
      dnsServers: []
    }
    enableAcceleratedNetworking: false
    enableIPForwarding: false
  }
}


output nicId string = nic.id
