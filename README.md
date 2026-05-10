OIDC:
old way: you create environment variables for the "key" to hold (Access Key ID/Secret)

new way:
cloud provider issues a short-lived access token that is only valid for a single job, and then automatically expires.

Terraform tfstate:
if Terraform tf state is deleted, terraform will not be able to use persisted state data to keep track of the resources it manages.

Plan either use s3 bucket to manage tf state.


