# Diaspora* database performance analysis

## First step

The goal is to load as much posts as possible as fast as possible.
One option would have been to insert lines manually, but then, it wouldnt be real-world data. Same goes with automatic posting. 

So the solution was to collect post from real users.
To do so, the idea is to "follow" as much users as possible.
Once a D* user interact with a collected post, it become known in the database.
The script `import.sh` look for users known but not yet followed and set a friend request.
The `grow_report.sh` generate a post with some statistics about the current status of the process.

Both scripts depend on having [chromedriver](https://chromedriver.chromium.org/) installed and started on localhost.
arguments are :
- pod url
- username
- password
- host to connect to (should be your pi, ssh-copy-id is expected to have been done previously)


It took about a month to load enough data to start step 2.
At first, the data load rate seems very low, but as you discover more and more users, dayly posts count increase exponantialy.
