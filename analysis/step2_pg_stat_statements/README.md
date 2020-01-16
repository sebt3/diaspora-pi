# Diaspora* database performance analysis

## Second step

You need over 100k posts in the database before attempting this step.

Enable pg_stat_statements using the `enable.sh` script
Then use your pod a little. And finally use the `report.sh` script to find out the top 10 "worst" queries.
At this point there's no automation possible, you're own your own.
