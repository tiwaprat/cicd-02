This project is about basic set up on ec2 to push code from local git repo (on ec2) to GitHub. Here are the steps. This code is java spring boot based simple application that will use maven as build tool. This application have a html form which will take name, age of student and backend java code  will same data into AWS MySQL data base. 

Steps: 
1. Create a public repo on GitHub (May be empty) 
2. Provision ec2 and install git 
3. Clone the repository with command (for ex)
  git clone https://github.com/tiwaprat/cicd-02.git
and files to repo and commit using git commands 
4. At this point we will not be able to push code to GitHub as we have not configured ec2 to connect to github securely using ssh key pair. lets do a simple seet up
5.  generate key pair on ec2 for login user ec2-user
    ssh-keygen -t ed25519 -C "awsaug2021@gmail.com"

6. go to ~/.ssh/ 
7. search for 
   .pub 
8. copy the content of .pub file 
9. login to GitHub and goto settings and create new key pair. 
 
give a name and copy content of .pub 
10. Try pushing code now 
11. If it is asking password. 

git remote -v 
12. run git remote set-url origin git@github.com:tiwaprat/cicd-02.git
13. Try to push again : it will work now.  

Note: So its clear any sever which have this same private key will be able to push code to git so to secure even private key we could have added passphrase (during configuration)So every time when we try to push code to GitHub we have to provide passphrase too. And incase we want to use passphrase but every time adding passphrase feels annoying we can use ssh-agent and can add passphrase to ssh-agent. This will automate 2nd layer authentication.     

Important: The ec2 server from where code is pushed to GitHub is terminated now. now we will have a fresh setup for CI-CD. I am using same Jenkins server from project cicd-01. On the same Jenkins server I will install and configure maven as build tool. in this new ec2 instance we dont have MySQL driver installed this will get installed at the time of build using pom.xml. 
 

Now we have code available on GitHub. Going forward we might need to edit pom.xml as per maven and JDK version installed on build server. For simplicity , I will use Jenkins server as build server too. 

Steps: 

1.Install maven on ec2 server (same server where Jenkins in installed in cicd-01)
  login to Jenkins.
  server.sudo  -  
  go to /opt/
    
  wget https://dlcdn.apache.org/maven/maven-3/3.9.10/binaries/apache-maven-3.9.10-bin.tar.gz
  tar -xvf apache-maven-3.9.10-bin.tar.gz 
  mv apache-maven-3.9.10 maven 
  so basically copying of binary is installation.

2.we will set env path so that mvn command is runnable from anywhere.
  
3.Set env variavles and path in /root/.bash_profile as 

# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
        . ~/.bashrc
fi

# User specific environment and startup programs

export PATH=$PATH:$HOME/bin
export JAVA_HOME=/usr/lib/jvm/java-17-amazon-corretto
export PATH=$JAVA_HOME/bin:$PATH
export M2_HOME=/opt/maven
export M2=/opt/maven/bin
export PATH=$M2_HOME:$M2:$PATH

save and run 

source /root/.bash_profile

3. Install and configure maven plugin in Jenkins 

Login to Jenkins (password location is /var/lib/Jenkins/secretes/initialPasswords)-> manage Jenkins -> available plugin-> maven (This plugin provides a deep integration between Jenkins and Maven. It adds support for automatic triggers between projects depending on SNAPSHOTs as well as the automated configuration of various Jenkins publishers such as Junit.)-> 

4. Configure maven in Jenkins 
manage jenkins-> tools-> set JAVA_HOME as /usr/lib/jvm/java-17-amazon-corretto and MAVEN_HOME as /opt/maven -> apply and save 

5. Create a new Jenkins job. 
new item -> name-> maven project-> ok-> description-> source code git : https://github.com/tiwaprat/cicd-02.git -> Goals: clean install-> apply save.

Build got failed as we have no git installed on Jenkins server, lets install one. I have checked git is installed (git version 2.47.1)lets configure on Jenkins. 

6. No need to install any plugin for git tool 
7. manage jenkins-> tools-> path to git executables /usr/bin/git
8. create new item(job) name StudentApp-> maven project-> ok-> descrribe-> git repo https://github.com/tiwaprat/cicd-02.git -> branch specifier : */main -> goals : clean install -> apply ok-> build now 
9. This time build is successful and jar file is created at workspace in target dir 
10. let go to workspace /var/lib/jenkins/workspace/StudentApp/target  and run 
    java -jar studentapp-1.0.0.jar     to start app 
    Got error  that port 8080 port is already in use as my Jenkins is using this port 
11. Lets manually configure diffrent port for application 
    java -jar studentapp-1.0.0.jar --server.port=9090

12. Security group rules open port 9090
13. access application using public url 
    http://ec2-35-173-200-93.compute-1.amazonaws.com:9090/ 

14. Able to access application but not able to connect database server as aws rds MySQL instance is configured for different ec2 instance. 
15. lets fix it 
Login to aws console -> RDS databases-> select the MySQL database(Check in code for database name ) -> go to action-> configure ec2 -> select ec2 where app is running in this case it is the same where Jenkins is running. 
16. once again run java -jar studentapp-1.0.0.jar --server.port=9090    from project target dir 
17. Now access app and try to add records. 
18. To verify if the records are add we need MySQL install on ec2 

19. Lets verify if the data is stored in database table or not 

    install MySQL client [I have already verified using previous instance where MySQL command line utility was already installed.]


   Later we can do put up steps 
20. Note: MySQL connector driver in already installed as dependency using pom.xml 
21. Till now after build we have to login to ec2 and start app lets do that part automated in Jenkins to 
22 Created a scripts appStart.sh and placed in project dir. This script will run in side Jenkins shell and let Jenkin know that it is not expected to get killed right after Jenkins job get finished. It checks if any processes is already running on port 9090 which we have chosen for app. if anything run on that it will get killed and fresh process will initiated.By default all in side workspace get run with Jenkins job. 
 
23.In Jenkins job also we need to setup a little.

New item-> name -> maven project-> description -> git URL -> main branch -> Build trigger : Build whenever a SNAPSHOT dependency is built
-> Post step run only build success -> execute shell :

chmod +x appStart.sh
bash -ex appStart.sh  

apply save 

24: In case we want git push to be build trigger here are steps : 
    For that we will create a webhook for push evet on GitHub and mention that in triggers. I will put steps later. 





 



 
  









