# Load in pygtk and gtk

import pygtk
import sys
pygtk.require('2.0')
import gtk, gobject
import subprocess
import os
import datetime

from os.path import join, getsize


# Define the main window

class Whc:
    def __init__(self):
        # Window and framework
        self.window = gtk.Window(gtk.WINDOW_TOPLEVEL)
        self.window.connect("destroy", self.destroy)
        self.window.set_resizable(True)
        self.window.set_title("DVDBackup")

        vbox = gtk.VBox(False, 5)
        vbox.set_border_width(10)
        self.window.add(vbox)
        vbox.show()
 
        # Create a centering alignment object
        align = gtk.Alignment(0.5, 0.5, 0, 0)
        vbox.pack_start(align, False, False, 5)
        align.show()

        #
        # box to display or change the  device
        #
        self.deviceTextEntry = gtk.Entry(max=0)
        self.deviceTextEntry.set_text("/media/cdrom0")
        vbox.add(self.deviceTextEntry)
        self.deviceTextEntry.show()

        #
        # box to display the MakeMKV format for the Device name
        #
        self.makemkvDeviceTextEntry = gtk.Entry(max=0)
        self.makemkvDeviceTextEntry.set_text("disc:0")
        vbox.add(self.makemkvDeviceTextEntry)
        self.makemkvDeviceTextEntry.show()


        #
        # box to display or change the  directory for output
        #
        self.directoryNameTextEntry = gtk.Entry(max=0)
        self.directoryNameTextEntry.set_text(os.getcwd())
        vbox.add(self.directoryNameTextEntry)
        self.directoryNameTextEntry.show()

        #
        # box to display or change the  dvd backup name
        #
        self.dvdTitleTextEntry = gtk.Entry(max=32)
        if len(sys.argv) == 2:
            self.dvdTitleTextEntry.set_text(sys.argv[1])
        else:
            self.dvdTitleTextEntry.set_text("_Name_Of_DVD")
        vbox.add(self.dvdTitleTextEntry)
        self.dvdTitleTextEntry.show()

        #
        # our progress bar
        self.progress = gtk.ProgressBar(adjustment=None)
        align.add(self.progress)
        self.progress.show()

        # A Button, with an action
        # Add it to the geometry
        # show the button
        self.button = gtk.Button("Backup DVD")
        self.button.connect("clicked", self.runDvdBackup, None)
        vbox.add(self.button)
        self.button.show()

        #
        # status bar
        #
        self.statusBar = gtk.Statusbar()
        vbox.add(self.statusBar)
        self.statusBar.show()
        self.timer = 0 

        # Show the window
        self.window.show()

    def getDirectorySizeInBytes(self,directory):
        #for root, dirs, files in os.walk(directory):
        #    (bytes,) = sum(getDirectorySizeInBytes(join(root, name)) for name in files),
        #    return bytes
        # print directory
        p1 = subprocess.Popen(["/usr/bin/du","-s","-B","1",directory], stdout=subprocess.PIPE)
        return subprocess.Popen(["/usr/bin/cut","-f","1"], stdin=p1.stdout, stdout=subprocess.PIPE).communicate()[0]
        

    def updateProgress(self, data=None):
        currentAmount = self.getCurrentCompleteAmount()
        percComplete = float(currentAmount) / float(self.totalSize) 
        if percComplete > 1: percComplete =  1 
        self.progress.set_fraction(percComplete)
        self.progress.set_text(str( round(percComplete * 100,1) )  + "%")
        
        # has it finished ?
        self.dvdbackupProcess.poll()
        if self.dvdbackupProcess.returncode != None and self.progress.get_text() != "Completed!":
            self.dtEnd = datetime.datetime.now()
            subprocess.Popen(["eject",self.device])
            self.progress.set_fraction(0)
            self.progress.set_text("Completed!")
            self.timer = 0 
            self.statusBar.push(1,"Started: " + str(self.dtStart) + "\nEnded: " + str(self.dtEnd))
            return False
        return True


# get the current amount completed
    def getCurrentCompleteAmount(self, data=None):
        dvdBackupDir = self.directoryName + "/" + self.dvdTitle
        size = self.getDirectorySizeInBytes(dvdBackupDir) or 0
        # print "Calculate the current amount :" + dvdBackupDir + " - " + str(size)
        return int(size)

# calculate the size of the DVD
    def getDvdSize(self):
        p1 = subprocess.Popen(["/bin/df","-B","1",self.device], stdout=subprocess.PIPE)
        p2 = subprocess.Popen(["tail", "-1"], stdin=p1.stdout, stdout=subprocess.PIPE)
        p3 = subprocess.Popen(["awk", "{print $2;}"], stdin=p2.stdout, stdout=subprocess.PIPE)
        size = p3.communicate()[0]
        return int(size)

        #consume header from df

# calculate the size of the DVD
    def locateTitle(self):
	p1 = subprocess.Popen(["/usr/bin/makemkvcon","info","-r",self.makemkvDevice], stdout=subprocess.PIPE)
	p2 = subprocess.Popen(["perl","-e","$g=0;while (<>) { if (/TINFO:(.*?),9,.*,\\"(\d\d?):(\d\d?):(\d\d?)\\"/) {$x=($2*3600)+($3*60)+$4;if($x>$g){$g=$x;$t=$1} } } print \"$t\n\""], stdin=p1.stdout, stdout=subprocess.PIPE)
        title = p2.communicate()[0]
        return title


# Callback function for use when the button is pressed
    def runDvdBackup(self, widget, data=None):
        # print "Backing up"
        self.dtStart = datetime.datetime.now()
        self.statusBar.push(0,"Started: " + str(self.dtStart))
        self.device = self.deviceTextEntry.get_text()
        self.makemkvDevice = makemkvDeviceTextEntry.get_text()
        self.directoryName = self.directoryNameTextEntry.get_text()
        self.dvdTitle = self.dvdTitleTextEntry.get_text()
        self.totalSize = self.getDvdSize()  
        self.titleToCapture = self.locateTitle()

        # Add a timer callback to update the value of the progress bar
        self.timer = gobject.timeout_add (2000, self.updateProgress, self)
        self.dvdbackupProcess = subprocess.Popen(["/usr/bin/makemkvcon","mkv",self.makemkvDevice,self.directoryName,"-n",self.dvdTitle])
        

# Destroy method causes appliaction to exit
# when main window closed

    def destroy(self, widget, data=None):
        gobject.source_remove(self.timer)
        self.timer = 0
        gtk.main_quit()

# All PyGTK applicatons need a main method - event loop

    def main(self):
        gtk.main()

if __name__ == "__main__":
    base = Whc()
    base.main()

