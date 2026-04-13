using '../main.bicep'

// 1. Regional Settings
param location = 'eastus2'

// 2. Identity Settings
param adminUsername = 'studentadmin'

// 3. Security Settings
// NOTE: Since this is @secure in main.bicep, providing it here 
// prevents the CLI from prompting you manually during deployment.
param adminPassword = 'ComplexPassword123!'
