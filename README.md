
# Azure resources for Wiz-Sentinel integration

This project contains bicep code to deploy the Azure resources required in the Wiz to Sentinel integration. The resources are defined using Azure Verified Modules.

The code is based on the ARM template provided in by Wiz in the Sentinel Content hub (https://downloads.wiz.io/customer-files/azure/integrations/sentinel/azuredeploy_Connector_WizIssues_API_AzureFunction.json)

## Expected variables

See the file "prod.bicepparam" for expected environment variables during deployment. A description of each required variable can be found in the Wiz docs (link below) under "Deploy Wiz Solution" - "ARM template required parameters".

Sentinel - Wiz integration: 
https://docs.wiz.io/wiz-docs/docs/azure-sentinel-native-integration?lng=en (requires auth)