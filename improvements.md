# Improvements

this markdown will track and document flaws and inconsistencies and the resolution.

#### terraform-apply job has no dependency on the if_merged

the terraform-apply job only has an if statement which checks if a condition is true. or false, for the job to have dependency a "needs" statement is required.

yes, terraform can still apply because there is a workflow dispatch which enables manual triggering

no, continue-on-error is not appropriate, it masks validation failures 

