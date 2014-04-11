### DVD Ripping Scripts

We only buy DVD's. (I used to get a lot of fines when I forgot to return Vidoes to the Video rental store, so I decided never to rent again.. that was the 90's)

So I am all ripped up now, but it is fair to say I had a lot to do.

#### Versions from 2007
I setup four desktops running Ubuntu desktop.

In the older-scripts folder is a Python GUI app I used that basically opened the DVD drive, 
Ran a rip and ejected the disk, also estimating on the GUI when it was complete.

``` 
older-scripts/py-dvdbackup.py
```
I have not used this for some time .. because I lost it on a bacxkup.. but I found it (after I wrote makemkv-extractor.sh)


#### Versions from 2013

Now I run two commands.. 

```
makemkv-extractor.sh /dev/sr1 path/where/makemkv/writes/files NameOfDVD
```

this can be on all machines that have DVD or Bluray drives
   It needs a folder access to the same folder (mount / network driv) that 

```
handbrake-server.pl -s path/where/makemkv/writes/files -d path/where/you/want/m4vs
```

This is some other stuff in there - enjoy.



### Improvements

These are very rough and ready - they work well .. 
If anyone has ideas .. I will happily update and maintain them.. A friend suggested auto-gleaning the name of the DVD from the interweb.
