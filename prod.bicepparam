using './main.bicep'

param wiz_auth_url = readEnvironmentVariable('wiz_auth_url', 'https://auth.app.wiz.io/oauth/token')
param wiz_endpoint_url = readEnvironmentVariable('wiz_endpoint_url', '')
param wiz_client_id = readEnvironmentVariable('wiz_client_id', '')
param wiz_client_secret = readEnvironmentVariable('wiz_client_secret', '')
param azure_loganalytics_workspace_id = readEnvironmentVariable('azure_loganalytics_workspace_id', '')
param azure_loganalytics_workspace_sharedkey = readEnvironmentVariable('azure_loganalytics_workspace_sharedkey', '')
param azure_loganalytics_resource_id = readEnvironmentVariable('azure_loganalytics_resource_id', '')
param enable_issues_sending = 'true'
param enable_vulnerabilities_sending = 'true' 
param enable_auditlogs_sending = 'true'
param issues_query_filter = '{"severity": ["CRITICAL", "HIGH"], "status": ["OPEN", "IN_PROGRESS"]}'
param vulnerabilities_query_filter = ''
param auditlogs_query_filter = ''
