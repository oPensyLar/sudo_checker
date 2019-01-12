
How to use it
-------






First make sure you’re root

```
# id

uid=0(root) gid=0(root) groups=0(root),1(bin),2(daemon),3(sys),4(adm),6(disk),10(wheel),19(log)

```


Second make sure you’ve the execution bit enabled


```
chmod +x sudo_checker.sh
```



CSV files
-------




**/tmp/sudoers_groups.csv** Contains groups that can use sudo in CSV format.

Possible values:

|                       group_name                       |
|:------------------------------------------------------:|
| Name of the groups that allow you access to sudo |
|                                                        |
|                                                        |



**/tmp/sudoers_svc.csv** Will contain running processes that have svc_* privileges

Possible values:

|                           pid                           |  proc_name                                        |  account_name                                               |
|:-------------------------------------------------------:|---------------------------------------------------|-------------------------------------------------------------|
| Value that will refer to the "Process Identifier" | Value that will refer to the "Process name" |  Name of the user account who initiated the process |



**/tmp/sudoers_home.csv** It will contain the names of users that are allowed access to sudo from the enumeration of the folder in /home



Possible values:



|                                                        account_name                                                       |
|:-------------------------------------------------------------------------------------------------------------------------:|
| Value that refers to the username that allows access to sudo, detected from the directory /home/ |
|                                                                                                                           |





Q & A
-------





* Q) Because not a single CSV file is generated?

* A) The result is not very good, this generates a lot of non-aligned data.





** Example: **



![](https://i.imgur.com/bukCAzu.png)
**INFO:** Process filter with root privileges. The filters can be configured by changing global variables, this is a file overview **/tmp/sudoers_svc.csv**

![](https://i.imgur.com/t7jo8LV.png)

**INFO:** Example of the file generated in ** /tmp/ sudoers_home.csv ** only shows the users that have permission to sudo from the directories found on /home/


![](https://i.imgur.com/yNApOFo.png)

**INFO:** Example of the generated file in ** /tmp/sudoers_groups.csv ** only shows the groups with permission to enter sudo environment



![](https://i.imgur.com/j3C5ztZ.png)

**INFO:** Note that they generate several unnecessary empty fields at the end, which makes it difficult to interpret the information





Tested on
-------






* **ArchLinux (bash 4.4, gawk 4.2, grep 3.3)**

* **Centos v7**


-------------


