# TODO - Automated test script in progress

# Jenkins CI Automation for Unreal Engine 4 Projects

This tutorial and repository provides documentation and resources on how to configure a Jenkins CI installation to build and compile an Unreal Engine 4 project.

This fork is modified mainly in three aspects:
- **Step0_DeleteAutoGenerated.bat**: This is an optional script, it will remove autogenerated files from a UE4 Project. This is the only script that needs to be inside the directory of the UE4 Project (at the same level of the .uproject). I usually place this script in all my projects.
- **Step2_CompileScripts.bat**: Now it uses the Unreal Batch Builder instead of the MSBuild.exe from Visual Studio.
- **Step2.5_RunTests.bat**: Script for running functional tests using the Unreal Automation System. 

Created by [Zack Devine](https://zdevine.me) for [Skymap Games](https://skymapgames.com).

Modified by [Kevin Yabar](https://cronofear.com) for [Cronofear Softworks](https://cronofear.com).

## Considerations

 - How automated tests should look https://www.youtube.com/watch?v=ivLFP2eApto
 - How to make functional automated tests in UE4: https://www.youtube.com/watch?v=f4LpDXjFgVQ
 - How to make better automated tests (high level scripting) in UE4: http://forum.skookumscript.com/t/about-automated-tests-using-sk/1510
 - How to connect the builds from Jenkins to the releases manager in Visual Studio Team Services (upload .zip files and i think, log results, to VSTS): https://www.youtube.com/watch?v=rCZ5ICkwarQ
 - How to generate custom poll scripts for Jenkins: https://crontab.guru/
 - Sometimes, after Jenkins build your projecs, for some reason if you try to generate files in any UE4 project. (Right click,  Generate VS File) there will appear an error saying that you don't have permissions. Also, if you open a .sln project and try to build a UE4 project, there will appear the same error. It's annoying and i didn't found a perfect solution. But you can do the following to solve this problem:
   - Always run .sln as administrator: https://stackoverflow.com/questions/22672072/how-do-i-add-a-default-run-as-administrator-when-i-open-a-sln-file-from-the-comm check the answer from "Prasanth Louis"
   - Execute **"Step1_StartBuild.bat"** as admin in any UE4 project. This will "unlock" the permissions and you'll be able to generate VS files in any UE4 Project.
 
## What's the goal of this

If you're like me and didn't hear about devOps in your entire life (even tho, i'm a system engineer student) then you might be wondering why you need this. 

The point of using Jenking to automate your builds (and your tests) is to give you confidence that your project is going well. If someone in your team makes a mistake and send a commit to the master repo that breaks the game (test fail or build fail), then Jenkins can send an alert so the issue can be solved the moment it happens and not two weeks before the release of the game. Bugs are waaaaaaaaay easier to solve in a code/commit you've made some hours ago than several weeks ago.

Also, if you're developing a project that needs continous releases (MMORPG, FreeToPlay, etc) then this system is perfect for you.

The nice thing about all this is that once you've set everything up. The builds and tests will run automatically, potentially saving you and your team lots of hours! 

---

### Prerequisites

**Before you begin:** This documentation is solely meant for Jenkins running on Windows servers and desktops. This *may* also work on GNU/Linux build servers, however the included build scripts have only been tested for Windows installations.

To get started, please first download and install [Jenkins](https://jenkins.io/download/) on the computer you wish to use as a build server. ([Jenkins Installation Docs](https://jenkins.io/doc/pipeline/tour/getting-started/#getting-started-with-the-guided-tour))

Clone or download this repository to your CI server to access the required build files for the final steps of the tutorial.

You will also need to download [cURL](http://www.confusedbycode.com/curl/) (only if posting notifications to Slack), Unreal Engine 4, as well as install MSBuild v14.0.

For giving you an example. My setup is like this:
Note: This is not the ideal setup, Jenkins should be running on a different computer (or a hosted server in the cloud).

- I've created a git repo in VSTS named Project that includes a .gitignore file for UE4 projects (you can select one in VSTS).
- I've used a git Client to clone my repo to C:/_MyGameName/ so git creates a Project/ directory inside /_MyGameName/
- I've created a UE4 c++ project named "Project" and i'm placing the files inside C:/_MyGameName/Project/ This is my local repo, where i can work and commit my changes to VSTS.
- I've created a /Jenkins/ folder inside C:/_MyGameName/ , this folder has the following structure:
  - C:/_MyGameName/Jenkins/Builds/     This is where the scripts will create the build and the .zip file of the build.
  - C:/_MyGameName/Jenkins/Project/    This is where Jenkins will download the master repo from my VSTS git repo.
  - C:/_MyGameName/Jenkins/scripts/    This is where i'm placing the scripts from this github repo.

>> A picture of what i just said: https://imgur.com/a/QlPotv8 - Project@Temp is created automatically by Jenkins.

So, for example. Let's say that i'm working with 3 people. Only one need to setup a Jenkins server. Everyone else should work using git as always. When a commit is made to the master repo, Jenkins will download the changes, run the scripts (tests and build). If everything went right, Jenkins will upload my .zip file to VSTS (see considerations) and will send a confirmation message to the team (using slack or any other method). If something went wrong, Jenkins will send an error message to the team.
In my case, i've setup Jenkins so it test/build the master repo once a day.

---

### Step 1: Create a new Jenkins Project

This first step is pretty straightforward. Once Jenkins is configured, start by creating a new Freestyle project.

#### General

Under **General > Advanced** check **Use custom workspace** and put the directory on the root of your drive, to prevent issues with long filenames during the build. Something like `C:\Source\<project name>` or similar should do the job.

#### Source Code Management

Set up your source control repository as normal.

#### Build Triggers

For our configuration, we poll the SCM every 3 minutes for changes, and build only if a certain keyword is present in the commit message. To do so, enter `H/3 * * * *` within the **Schedule** textbox. To trigger on commit messages, scroll back up to **Source Code Management**, click **Advanced**, and under **Excluded Commit Messages** enter `^((?!KEYWORD).)*$`, replacing `KEYWORD` with your own keyword to check for.

---

### Step 2: Configure Build Scripts

Locate the directory where you downloaded the build scripts to. If you plan on posting to a [Slack](https://slack.com) channel during the build process, you will need to configure an incomming webhook integration, and replace `WEBHOOK_URL` with the URL of the integration in `PostToSlack.bat`.

In each of the build scripts, make sure to replace `PROJECT_NAME` with the name of your project.

---

### Step 3: Add Build Steps to your Jenkins Project
Finally, add the build commands to Jenkins. At this point, you should have the build scripts somewhere on your server. Take note of the directory they reside in. For our setup, we post to a [Slack](https://slack.com) channel during each step of the build. If you would also like to do this, make sure to include the `PostToSlack.bat` files during each step, as laid out below:

Make sure to replace `C:\path\to\scripts\` with the actual path of your build scripts!

###### Build Step 1
```batch
call C:\path\to\scripts\PostToSlack.bat ":heavy_check_mark: Starting %JOB_NAME% Build -- Revision %SVN_REVISION%"
"C:\path\to\scripts\Step1_StartBuild.bat"
```
###### Build Step 2
```batch
call C:\path\to\scripts\PostToSlack.bat ":gear: Compiling game scripts..."
"C:\path\to\scripts\Step2_CompileScripts.bat"
```
###### Build Step 3
```batch
call C:\path\to\scripts\PostToSlack.bat ":hammer: Building project files..."
"C:\path\to\scripts\Step3_BuildFiles.bat"
```
###### Build Step 4
```batch
call C:\path\to\scripts\PostToSlack.bat ":fire: Cooking project..."
"C:\path\to\scripts\Step4_CookProject.bat"
```
###### Build Step 5 (Optional - Used to archive UE4 build)
```batch
call C:\path\to\scripts\PostToSlack.bat ":package: Archiving build..."
C:\path\to\scripts\Step5_Archive.bat "%SVN_REVISION%"
```
###### Build Step 6 (Optional - Notifies in Slack when project is complete)
```batch
C:\path\to\scripts\PostToSlack.bat ":tada: Done!"
```

---

...and that should be it! Feel free to run a test build to see if everything builds and compiles correctly. The first build will take longer than normal, as Jenkins has to download all of the files from the repository specified.
