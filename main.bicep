var keyvaultname = 'Wiz2Sentkv${uniqueString(resourceGroup().id)}'
var functionappname = 'Wiz2SentinelCust'
var insightsname = 'Wiz2Sentins-${uniqueString(resourceGroup().id)}'

param wiz_auth_url string
param wiz_endpoint_url string
@secure()
param wiz_client_id string
@secure()
param wiz_client_secret string
@secure()
param azure_loganalytics_workspace_sharedkey string
param azure_loganalytics_workspace_id string
param azure_loganalytics_resource_id string
param enable_issues_sending string
param enable_vulnerabilities_sending string
param enable_auditlogs_sending string
param issues_query_filter string
param vulnerabilities_query_filter string
param auditlogs_query_filter string

@description('User assigned managed identity for the function app')
module userAssignedIdentity 'br/public:avm/res/managed-identity/user-assigned-identity:0.4.0' = {
  name: 'userAssignedIdentityDeployment'
  params: {
    // Required parameters
    name: functionappname
    // Non-required parameters
    location: resourceGroup().location
  }
}

@description('Storage account for Function App')
module storage 'br/public:avm/res/storage/storage-account:0.14.3' = {
  name: 'storageModule'
  params: {
    name: toLower(functionappname)
    skuName: 'Standard_LRS'
    location: resourceGroup().location
    publicNetworkAccess: 'Enabled'
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
    secretsExportConfiguration: {
      keyVaultResourceId: vault.outputs.resourceId
      connectionString1: 'StorageConnectionString'
    }
    blobServices: {
      containers: [
        {
          name: 'azure-webjobs-hosts'
        }
        {
          name: 'azure-webjobs-secrets'
        }
      ]
    }
    fileServices:{

      shares: [
        {
          name: toLower(functionappname)
          properties: {
            shareQuota: 5120
          }
        }

      ]
    }
  }
  dependsOn: [
    vault
  ]
}
module insights 'br/public:avm/res/insights/component:0.3.0' = {
  name: 'Wiz2SentInsights'
  params: {
    name: insightsname
    workspaceResourceId: azure_loganalytics_resource_id
  }
}

@description('Application Service Plan for Function App')
module appServicePlan 'br/public:avm/res/web/serverfarm:0.3.0' = {
  name: 'appServicePlanModule'
  params: {
    name: 'funcAppPlan${uniqueString(resourceGroup().id)}'
    location: resourceGroup().location
    skuName: 'Y1'
    kind: 'Linux'
  }
}

@description('Function App for Python 3.10')
module functionApp 'br/public:avm/res/web/site:0.11.1' = {
  name: functionappname
  params: {
    name: functionappname
    location: resourceGroup().location
    kind: 'functionapp,linux'
    serverFarmResourceId: appServicePlan.outputs.resourceId
    appInsightResourceId: insights.outputs.resourceId
    storageAccountResourceId: storage.outputs.resourceId
    storageAccountRequired: true
    managedIdentities: {
      userAssignedResourceIds: [userAssignedIdentity.outputs.resourceId]
    }
    keyVaultAccessIdentityResourceId: userAssignedIdentity.outputs.resourceId
    appSettingsKeyValuePairs: {
      FUNCTIONS_WORKER_RUNTIME: 'python'
      FUNCTIONS_EXTENSION_VERSION: '~4'
      APPINSIGHTS_INSTRUMENTATIONKEY: insights.outputs.instrumentationKey
      AzureWebJobsStorage: '@Microsoft.KeyVault(VaultName=${keyvaultname};SecretName=StorageConnectionString)'
      APPLICATIONINSIGHTS_CONNECTION_STRING: insights.outputs.connectionString
      WEBSITE_RUN_FROM_PACKAGE: 'https://aka.ms/sentinel-wiz-website-run-from-package'
      WEBSITE_CONTENTAZUREFILECONNECTIONSTRING: '@Microsoft.KeyVault(VaultName=${keyvaultname};SecretName=StorageConnectionString)'
      WEBSITE_CONTENTSHARE: toLower(functionappname)
      wiz_auth_url: '@Microsoft.KeyVault(VaultName=${keyvaultname};SecretName=WizAuthUrl)'
      wiz_api_endpoint: '@Microsoft.KeyVault(VaultName=${keyvaultname};SecretName=WizApiEndpointUrl)'
      wiz_client_id: '@Microsoft.KeyVault(VaultName=${keyvaultname};SecretName=WizClientId)'
      wiz_secret_key: '@Microsoft.KeyVault(VaultName=${keyvaultname};SecretName=WizClientSecret)'
      workspace_customer_id: '@Microsoft.KeyVault(VaultName=${keyvaultname};SecretName=AzureLogAnalyticsWorkspaceId)'
      workspace_shared_key: '@Microsoft.KeyVault(VaultName=${keyvaultname};SecretName=AzureLogAnalyticsWorkspaceSharedKey)'
      enable_issues_sending: '@Microsoft.KeyVault(VaultName=${keyvaultname};SecretName=EnableIssuesSending)'
      enable_vulnerabilities_sending: '@Microsoft.KeyVault(VaultName=${keyvaultname};SecretName=EnableVulnerabilitiesSending)'
      enable_audit_logs_sending: '@Microsoft.KeyVault(VaultName=${keyvaultname};SecretName=EnableAuditLogsSending)'
      issues_query_filter: '@Microsoft.KeyVault(VaultName=${keyvaultname};SecretName=IssuesQueryFilter)'
      vulnerabilities_query_filter: '@Microsoft.KeyVault(VaultName=${keyvaultname};SecretName=VulnerabilitiesQueryFilter)'
      audit_logs_query_filter: '@Microsoft.KeyVault(VaultName=${keyvaultname};SecretName=AuditLogsQueryFilter)'
      debug_level: '20'
    }
    siteConfig: {
      linuxFxVersion: 'PYTHON|3.11'
    }
  }
  dependsOn: [storage]
}

@description('Key Vault used to store function app secrets')
module vault 'br/public:avm/res/key-vault/vault:0.10.2' = {
  name: 'Wiz2Sent-${uniqueString(resourceGroup().id)}'
  params: {
    // Required parameters
    name: keyvaultname
    // Non-required parameters
    enablePurgeProtection: false
    location: resourceGroup().location
    publicNetworkAccess: 'Disabled'
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
    roleAssignments: [
      {
        principalId: userAssignedIdentity.outputs.principalId
        principalType: 'ServicePrincipal'
        roleDefinitionIdOrName: 'Key Vault Secrets User'
      }]
    secrets: [
      {
        name: 'KeyVaultName'
        value: keyvaultname
      }
      {
        name: 'FunctionName'
        value: functionappname
      }
      {
        name: 'WizAuthUrl'
        value: wiz_auth_url
      }
      {
        name: 'WizApiEndpointUrl'
        value: wiz_endpoint_url
      }
      {
        name: 'WizClientId'
        value: wiz_client_id
      }
      {
        name: 'WizClientSecret'
        value: wiz_client_secret
      }
      {
        name: 'AzureLogAnalyticsWorkspaceId'
        value: azure_loganalytics_workspace_id
      }
      {
        name: 'AzureLogAnalyticsWorkspaceSharedKey'
        value: azure_loganalytics_workspace_sharedkey
      }
      {
        name: 'EnableIssuesSending'
        value: enable_issues_sending
      }
      {
        name: 'EnableVulnerabilitiesSending'
        value: enable_vulnerabilities_sending
      }
      {
        name: 'EnableAuditLogsSending'
        value: enable_auditlogs_sending
      }
      {
        name: 'IssuesQueryFilter'
        value: issues_query_filter
      }
      {
        name: 'VulnerabilitiesQueryFilter'
        value: vulnerabilities_query_filter
      }
      {
        name: 'AuditLogsQueryFilter'
        value: auditlogs_query_filter
      }
    ]
  }
  dependsOn: [userAssignedIdentity]
}


