

<td>

<div class="smallfont">**Fedora 25 - Kernel 4.10.x - NVIDIA driver issues and fix**</div>

* * *

<div id="post_message_1784978">Hi everyone,

I know that this issue has been solved partially, but I'd like to write down a short summary of the steps I went through.

**The problem:**

After the recent kernel update to 4.10.x (on my machine currently 4.10.8-200.fc25.x86_64), the NVIDIA driver refused to rebuild (through _dkms_) and run. Previous kernel 4.9.x versions did run the NVIDIA driver compiled through dkms.

**The precondition:**

I am running Fedora 25 on an up-to-date DELL Precision Notebook. Through the last kernel updates in the past months, I was using the **proprietary** (!) NVIDIA driver package here: [http://www.nvidia.com/object/unix.html](http://www.nvidia.com/object/unix.html)

I was using the 64Bit Long Lived Branch version (recent 375.39), with this recent fix I switched over to the 64Bit Short Lived Branch version (378.13).

I think that maybe parts of this could also help out those, using the RPM Fusion driver package.

**The trial and error:**

After upgrading to kernel version 4.10.6 and also today's 4.10.8, my Fedora installation didn't boot up anymore and got stuck in boot process, when attempting to start the Gnome display manager. After the last kernel update a few weeks ago, when SELinux broke a lot installations while preventing NVIDIA drivers (and some other drivers) to be loaded, my fix there was to simply reinstall the NVIDIA driver package.

Running the recent NVIDIA installer package, which I use to keep in both last versions on my machine as backups, led to the following errors:

<div style="margin:20px; margin-top:5px">

<div class="smallfont" style="margin-bottom:2px">Code:</div>

<pre class="alt2" dir="ltr" style="
		margin: 0px;
		padding: 6px;
		border: 1px inset;
		width: 860px;
		height: 130px;
		text-align: left;
		overflow: auto">Failed to run /usr/sbin/dkms build -m nvidia -v 378.13 -k 4.10.8-200.fc.x86_64: Kernel preparation unnecessary for this kernel. Skipping...

Building module:
cleaning build area...
'make' -j8 NV_EXCLUDE_BUILD_MODULES='' KERNEL_UNAME=4.10.8-200.fc25.x86_64 modules... (bad exit status: 2)
Error! Bad return status for module build on kernel: 4.10.8-200.fc25.x86_64 (x86_64)
Consult /var/lib/dkms/nvidia/378.13/build/make.log for more information</pre>

</div>

Following:

<div style="margin:20px; margin-top:5px">

<div class="smallfont" style="margin-bottom:2px">Code:</div>

<pre class="alt2" dir="ltr" style="
		margin: 0px;
		padding: 6px;
		border: 1px inset;
		width: 860px;
		height: 34px;
		text-align: left;
		overflow: auto">ERROR: Failed to install the kernel module through DKMS. No kernel module was installed: please try installing again without DKMS, or check the DKMS logs for information.</pre>

</div>

When trying to compile and run the driver without DKMS, the result is a longer list of compile debug output, referencing _linux/fence.h_ with a fatal error.

So what I did next, was to remove the NVIDIA driver package using the

<div style="margin:20px; margin-top:5px">

<div class="smallfont" style="margin-bottom:2px">Code:</div>

<pre class="alt2" dir="ltr" style="
		margin: 0px;
		padding: 6px;
		border: 1px inset;
		width: 860px;
		height: 34px;
		text-align: left;
		overflow: auto">nvidia-uninstaller</pre>

</div>

command. I also followed the RPM Fusion notes ([https://rpmfusion.org/Howto/nVidia](https://rpmfusion.org/Howto/nVidia)) and manually removed the libs mentioned there:

<div style="margin:20px; margin-top:5px">

<div class="smallfont" style="margin-bottom:2px">Code:</div>

<pre class="alt2" dir="ltr" style="
		margin: 0px;
		padding: 6px;
		border: 1px inset;
		width: 860px;
		height: 82px;
		text-align: left;
		overflow: auto">rm -f /usr/lib{,64}/libGL.so.* /usr/lib{,64}/libEGL.so.*
rm -f /usr/lib{,64}/xorg/modules/extensions/libglx.so
dnf re-install xorg-x11-server-Xorg mesa-libGL mesa-libEGL
mv /etc/X11/xorg.conf /etc/X11/xorg.conf.saved</pre>

</div>

After a clean state, I tried to install the RPM Fusion NVIDIA drivers like mentioned on their site:

<div style="margin:20px; margin-top:5px">

<div class="smallfont" style="margin-bottom:2px">Code:</div>

<pre class="alt2" dir="ltr" style="
		margin: 0px;
		padding: 6px;
		border: 1px inset;
		width: 860px;
		height: 50px;
		text-align: left;
		overflow: auto">dnf install xorg-x11-drv-nvidia akmod-nvidia "kernel-devel-uname-r == $(uname -r)"
dnf update -y</pre>

</div>

The installation ran through and but I wasn't able to boot up my Fedora installation as it would again got stuck in the boot process.

The output of _cat /var/log/Xorg.0.log_ did mention the shutdown of the xorg server but this seemed to be an old log. I removed the logs and after reboot no new log was created.

Next I did was disabling SELinux. In _/etc/selinux/config_:

<div style="margin:20px; margin-top:5px">

<div class="smallfont" style="margin-bottom:2px">Code:</div>

<pre class="alt2" dir="ltr" style="
		margin: 0px;
		padding: 6px;
		border: 1px inset;
		width: 860px;
		height: 34px;
		text-align: left;
		overflow: auto">SELINUX=disabled</pre>

</div>

After rebooting, nothing changed. **Secure Boot** was also disabled.

I also checked _dmesg_ output as usually and couldn't find anything related. After removing and reinstalling the related RPM Fusion packages (akmod-nvidia, mesa-libGLES, ect.) I checked for my _xorg.conf_ file and found a _nvidia-xorg.conf_ file, created by the RPM Fusion driver package which seemed to be ok.

**The fix:**

After digging around I eventually found the solution in mentions on different sites and threads.

Originally from here [http://www.forums.fedoraforum.org/sh...d.php?t=313777](http://www.forums.fedoraforum.org/showthread.php?t=313777) I found out, there is a patch available which fixes the

<div style="margin:20px; margin-top:5px">

<div class="smallfont" style="margin-bottom:2px">Code:</div>

<pre class="alt2" dir="ltr" style="
		margin: 0px;
		padding: 6px;
		border: 1px inset;
		width: 860px;
		height: 34px;
		text-align: left;
		overflow: auto">fence.h</pre>

</div>

erros for the driver compilation.

Here is the original source for the solution, which worked for me: [https://devtalk.nvidia.com/default/t...th-kernel-4-10](https://devtalk.nvidia.com/default/topic/995429/failed-installed-nvidia-with-kernel-4-10)

I'll write down the steps I did here for anyone, which are related to those in the NVIDIA forum:

Getting the NVIDIA display driver package (if you don't have it on your machine, already):

<div style="margin:20px; margin-top:5px">

<div class="smallfont" style="margin-bottom:2px">Code:</div>

<pre class="alt2" dir="ltr" style="
		margin: 0px;
		padding: 6px;
		border: 1px inset;
		width: 860px;
		height: 34px;
		text-align: left;
		overflow: auto">$ wget http://us.download.nvidia.com/XFree86/Linux-x86_64/378.13/NVIDIA-Linux-x86_64-378.13.run</pre>

</div>

I am using the mentioned 378.13 driver version (Short Lived Branch).

Making the installer package executable:

<div style="margin:20px; margin-top:5px">

<div class="smallfont" style="margin-bottom:2px">Code:</div>

<pre class="alt2" dir="ltr" style="
		margin: 0px;
		padding: 6px;
		border: 1px inset;
		width: 860px;
		height: 34px;
		text-align: left;
		overflow: auto">$ sudo chmod +x NVIDIA-Linux-x86_64-378.13.run</pre>

</div>

Extracting the contents of the driver package to a folder:

<div style="margin:20px; margin-top:5px">

<div class="smallfont" style="margin-bottom:2px">Code:</div>

<pre class="alt2" dir="ltr" style="
		margin: 0px;
		padding: 6px;
		border: 1px inset;
		width: 860px;
		height: 34px;
		text-align: left;
		overflow: auto">$ ./NVIDIA-Linux-x86_64-378.13.run -x</pre>

</div>

Change into this directory. Then download the patch file:

<div style="margin:20px; margin-top:5px">

<div class="smallfont" style="margin-bottom:2px">Code:</div>

<pre class="alt2" dir="ltr" style="
		margin: 0px;
		padding: 6px;
		border: 1px inset;
		width: 860px;
		height: 34px;
		text-align: left;
		overflow: auto">$ wget https://pkgs.rpmfusion.org/cgit/nonfree/nvidia-kmod.git/plain/kernel_4.10.patch</pre>

</div>

...and run the patch against the module:

<div style="margin:20px; margin-top:5px">

<div class="smallfont" style="margin-bottom:2px">Code:</div>

<pre class="alt2" dir="ltr" style="
		margin: 0px;
		padding: 6px;
		border: 1px inset;
		width: 860px;
		height: 34px;
		text-align: left;
		overflow: auto">$ patch -p1 < kernel_4.10.patch</pre>

</div>

Stop the Gnome Display Manager if it's running:

<div style="margin:20px; margin-top:5px">

<div class="smallfont" style="margin-bottom:2px">Code:</div>

<pre class="alt2" dir="ltr" style="
		margin: 0px;
		padding: 6px;
		border: 1px inset;
		width: 860px;
		height: 34px;
		text-align: left;
		overflow: auto">$ sudo service gdm stop</pre>

</div>

Run the NVIDIA installer from inside the directory:

<div style="margin:20px; margin-top:5px">

<div>Code:</div>

<pre>$ nvidia-installer</pre>

</div>

After the installation, where registering the kernel module with DKMS should run again without problems, start the Gnome Display manager again:

<div style="margin:20px; margin-top:5px">

<div class="smallfont" style="margin-bottom:2px">Code:</div>

<pre>$ sudo service gdm start</pre>

</div>

Reboot.

From here on, my installation boots up again and is running flawless.

Credits belong to these sites for the important information and mentions:

[https://devtalk.nvidia.com/default/t...th-kernel-4-10](https://devtalk.nvidia.com/default/topic/995429/failed-installed-nvidia-with-kernel-4-10)
[https://devtalk.nvidia.com/default/topic/995636](https://devtalk.nvidia.com/default/topic/995636)
[https://ask.fedoraproject.org/en/que...etary-drivers/](https://ask.fedoraproject.org/en/question/103607/kernel-410-patch-for-nvidia-37813-proprietary-drivers/)
[https://ask.fedoraproject.org/en/que...th-kernel-410/](https://ask.fedoraproject.org/en/question/103665/patch-for-proprietary-nvidia-37539-drivers-with-kernel-410/)
