OIDC:
old way: you create environment variables for the "key" to hold (Access Key ID/Secret)

new way:
cloud provider issues a short-lived access token that is only valid for a single job, and then automatically expires.

