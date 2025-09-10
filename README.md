Setup repo
Simple steps to setup the repository

Requirements
Download Git here
Create a GitHub account here
Download Unity here
Clone repository
Open up CMD
Navigate to the root folder where you want to clone the repository, no need to create a subfolder
Use the following commands to setup Git
git config --global user.email "you@example.com"
git config --global user.name "UsernameExample"
Clone the repository with the following command
git clone https://github.com/bakabaizuo/FracturedMind.git
Getting the latest version
git pull
Branches
By default we have the master branch, which we call the "main" branch. This branch will hold the latest version of our code. We will not directly commit to the main branch, we will create working branches and later merge those to the main branch To create a new branch, use the following command

git checkout -b branchName
To commit your changes to the git repo online, use the following command and add a meaningful message

git commit -a -m "Please use a descriptive message for the kind of work you commit"
git push
Merge working branch to the Main branch
This will be done through the process of a "Pull Request" in the GitHub UI

Open up "Unity Hub" and Import the Fractured Mind project
