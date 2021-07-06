# Short test on storage account access control behavior

## Create Resource Group

```bash
az group create --location koreacentral --resource-group storageaccess-test-rg
```

## Deploy services

```bash
az deployment group create --resource-group storageaccess-test-rg -f ./storageaccesstest.bicep --name storage_test
```

## Additional manual configuration

Go to Storage Account -> Networking

- Add VM2 public IP
- Add Subnet A

Storage Explorer

- Create a blob container
- Upload any file
- Create SAS URI for file

## Execute Test

- Log into VM2 and do a `wget <SAS URI OF FILE>` -> Access Denied
  - VM2 will route through internal network and not authorize with given PublicIP
- Log into VM1 and do a `wget <SAS URI OF FILE>` -> Access Granted
  - Storage IP Firewall Settings and Network Access are not combined (due to mismatch in internal network and public network configuration - I guess)

## Cleanup

```bash
az group delete --resource-group storageaccess-test-rg
```
