# Image publishing (for future reference)

## Linux 
Just create a cron tab for build-and-publish.sh

0 2 * * * $kudu_dev_velocity_root/docker/build-and-publish.sh 

## macOS
A short setup, to wake your mac up in the middle of the night to publish the image.

macOS has launchd, a good getting started page is https://www.launchd.info/[this one].

* kudu_image_publish.plist is the job definition. 
* chown root kudu_image_publish.plist
* load the job: sudo launchctl load kudu_image_publish.plist
    * need to use sudo, else it becomes a user agent which requires login
* go to preferences -> battery ->  Schedule -> "Start up or wake".
    * I set it for 1 AM every day. The job is then scheduled for 1:02 AM.

You just put your macbook to sleep. But in my case I had to keep the lid open, to make the job start. Since it is global/system agent it wont require login to kick off.

If you want to try out, that the job definitions works etc, you can manually kick off the job with: sudo launchctl start com.mgreber.kudu

To uninstall the job, you have to execute:
sudo launchctl stop com.mgreber.kudu
sudo launchctl unload kudu_image_publish.plist

To check to status of the job, you can run: sudo launchctl list | grep com.mgreber.kudu