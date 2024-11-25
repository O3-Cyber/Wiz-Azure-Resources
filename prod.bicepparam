using './main.bicep'

param wiz_auth_url = readEnvironmentVariable('WizAuthUrl', 'https://auth.app.wiz.io/oauth/token')
param wiz_endpoint_url = readEnvironmentVariable('WizEndpointUrl', '')
param wiz_client_id = readEnvironmentVariable('WizClientId', '')
param wiz_client_secret = readEnvironmentVariable('WizClientSecret', '')
param azure_loganalytics_workspace_id = readEnvironmentVariable('AzureLogAnalyticsWorkspaceId', '')
param azure_loganalytics_workspace_sharedkey = readEnvironmentVariable('AzureLogAnalyticsWorkspaceSharedKey', '')
param azure_loganalytics_resource_id = readEnvironmentVariable('AzureLogAnalyticsResourceId', '')
param enable_issues_sending = 'true'
param enable_vulnerabilities_sending = 'true' 
param enable_auditlogs_sending = 'true'
param issues_query_filter = '{"severity": ["CRITICAL", "HIGH"], "status": ["OPEN", "IN_PROGRESS"]}'
param vulnerabilities_query_filter = ''
param auditlogs_query_filter = ''
