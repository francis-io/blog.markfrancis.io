+++
title = "Updating a Supermicro X10 with the latest BIOS, IPMI and flashing the LSI 2308 controller into IT mode in 2022"
date = "2022-01-23"
+++

My server OS disk has decided to die finally. This has prompted me to rethink my server setup. I've been meaning to update and enable a few things, like the IPMI interface, for a while now. It's now a great time to do that before replacing my OS disk.

My goals are:

* Enable the IPMI web management interface for updates and management
* Update the BIOS to the latest version (even though Supermicro expressly recommends against this unless you have an issue)
* Update the IPMI BMC firmware to the latest version
* Flash the LSI 2308 SAS controller to IT mode

I will be doing all of this from a Linux desktop but use OS-agnostic methods where possible.

With the Supermicro X10 boards, you can flash the LSI 2308 controller to turn the SAS ports into standard SATA ports. This is vital for my plans to increase my ZFS storage array to 10 disks.

A lot of the credit for this guide goes to [PenalunWil](https://www.truenas.com/community/threads/flashing-the-lsi2308-firmware-on-a-supermicro-x10sl7-f-motherboard.38884/) on the FreeNAS/TrueNAS forums. I've used Ubuntu 20.04 with [ZFS on Linux](https://zfsonlinux.org/) for a while now, but this forum is always an excellent resource for ZFS hardware recommendations and information.

I was confused by the guide [PenalunWil](https://www.truenas.com/community/threads/flashing-the-lsi2308-firmware-on-a-supermicro-x10sl7-f-motherboard.38884/) posted in some areas, along with running into dead driver links, so I've chosen to rewrite this for 2022.

I've had the [X10SL7-F](https://www.supermicro.com/en/products/motherboard/X10SL7-F) board for a while now. It's starting to show its age a little with its DDR3 RAM and LGA 1150 socket but is more than enough for my usage (10TB of ZFS storage and ~10-20 docker containers).

## Hardware Recommendations

If you have found this post because you also want to run a good-sized storage server with 14 possible SATA ports, here's what I've learned over the years of owning this board. I might turn this into a dedicated post and expand this information.

* Max out the 4x 8GB of DDR3 ECC RAM for 32GB of RAM, or at least buy 8GB modules of RAM to enable future expansion.
* Get the best LGA1150 CPU you can that supports [ECC RAM](https://ark.intel.com/content/www/us/en/ark/search/featurefilter.html?productType=873&1_Filter-SocketsSupported=3635&0_ECCMemory=True). You might be able to get a great deal on a refurbished Xeon CPU, which has four cores (I would personally go for more cores over total clock speed because my server idles a lot of the time). A solid two core budget option is the i3-4170. As far as I can tell, the i3 `T` variants are the same as the non-T versions but capped at a specific TDP of 35 watts. This might be beneficial in a limited cooling situation. Not all CPUs have integrated graphics, like the [E3-1241 v3](https://ark.intel.com/content/www/us/en/ark/products/80909/intel-xeon-processor-e31241-v3-8m-cache-3-50-ghz.html). This would require a dedicated graphics card to view the terminal if you ever needed to. Still, IPMI does lessen this requirement because (at least my board) has IPMI with integrated graphics.
* If you have a switch that can support [Link Aggregation](https://kb.netgear.com/21632/What-are-Link-Aggregation-Groups-LAGs-and-how-do-they-work-with-my-managed-switch)/[IEEE 802.3ad LACP](https://en.wikipedia.org/wiki/Link_aggregation) (which is usually only supported on managed switches). You could install network cards in unused PCI-E ports and "bond" multiple links to improve network throughput. For Linux/FreeNAS/FreeBSD/OpenBSD, Intel is usually a safe bet for networking. An Intel-based two-port PCI-E network card can be picked up on Amazon for around £45 each, but eBay is an excellent option for older hardware. Keep an eye on the PCI-E version and slot size. 4 port network cards are also available but tend to be expensive. The [Zyxel GS1900 series switches](https://www.zyxel.com/uk/en/products_services/8-10-16-24-48-port-GbE-Smart-Managed-Switch-GS1900-Series/) look like a good choice for a cheap, quiet, managed switch. You will still be limited to the slowest link between the server and client and the disk throughput, which likely won't saturate a 1 Gbps network interface. My board has 2x 1 Gbps network ports and a dedicated IPMI port. In the future, I plan to add two duel port network cards in bonded mode (for redundancy) and keep an onboard port as a "management" port for SSH, along with the dedicated IPMI port.
* Fan management has been a problem for me in the past. Noctua specifically mentions fan stall issues with Supermicro boards on the [FAQ](https://noctua.at/en/nf-f12-pwm/faq#127). My current recommendation is to use PWM fans connected directly to the motherboard and avoid external fan controllers or low power cables. Turn off automatic fan speed management and set an on-boot/cron script to manage fan speed based on temp. I use a Perl script found online for x10 boards that uses `ipmitool`.

## Enable IPMI Management

Intelligent Platform Management Interface (IPMI) is a way to remotely manage "low level" server tasks. Think things like BIOS updates, fan management, rebooting and even mounting ISOs. My X10 board has integrated IPMI with a KVM, letting me connect over a network to a shell if my OS does not boot correctly. The IPMI module can be thought of as its dedicated computer, so even network issues with the OS can be fixed using this. You will need a license to use this feature, but it's very approachable for a home user on a budget—just Google `supermicro ipmi license` for options.

The [IPMI](https://www.supermicro.com/manuals/other/IPMI_Users_Guide.pdf) documentation on the Supermicro site is quite good but very extensive. The main reason I want to enable this is to do remote BIOS updates. The Supermicro docs suggest not updating the BIOS unless I need to, but since it has never been updated in maybe eight years, and I plan to keep this board for many more years, it makes sense to update this.

1) Set the BIOS to UEFI: Press <del> to enter UEFI BIOS during system boot.
2) (Possibly optional) Select Advanced and enable Serial port console redirection and Console redirection under COM2/SOL.
3) Enable all onboard USB ports: Advanced > Chipset configuration. Select `South Bridge` and Highlight `USB 3.0 support` and press `enter`.
4) Configure IPMI with an IP address: Select `IPMI` > `BMC Network Configuration` > `Update IPMI LAN Configuration`. You can set a static IP here, but I recommend using DHCP and setting a long-lived, static lease on your DHCP server.
5) Plug an ethernet cable into the IPMI port (mine was the single port, not one of two next to each other). Check the DHCP leases using DHCP and put the IP in your browser. A login screen should greet you. The default username and password are `ADMIN/ADMIN`.

## Updating IPMI

You might notice you are prompted to install Java for some functionality. This is not cool in 2022, so let's update the IPMI firmware to use HTML5.

I'm currently on Firmware Revision: 01.92 03/16/2015.

1) Enter the board model you have [here](https://www.supermicro.com/support/resources/) and download the "BMC Firmware". Take note of the MD5 checksum. The file will be called something like `REDFISH_X10_388_20200221_unsigned.zip`.
2) Extract the zip files and run a md5sum check on the zip file. Make sure it matches. You don't want to upload a corrupted file.
3) In the IPMI interface, go to `Maintenance` > `Firmware update` and `Enter update mode`.
4) When prompted, upload the `.bin` file extracted from the zip. Make sure to keep all boxes ticked if prompted to preserve config.
5) Click `Start upgrade`. This will take a few minutes. Log back into the IPMI web interface and check the firmware version when it's done.

I'm now at v03.88 and can use the KVM without Java.

## Updating the BIOS

I'm currently on BIOS v3.0, built on 04/24/2015.

1) Do the same process as above to download the latest BIOS, run the MD5 checksum and extract the files.
2) In the IPMI web interface, go to `Maintenance` > `BIOS Update` and upload the file.
3) The update will take a few minutes. When complete, it will prompt you to reset. This will kill power right away, so you might want to shut down the system on your own gracefully.

I'm now at BIOS rev 3.4.

## Optional: Change the IPMI Password

Now we have an IPMI interface on the local network; you might want to change the `ADMIN` users default password. This can be done in `Configuration` > `Users` > `ADMIN` > `Modify User.

## Flashing the LSI controller to turn SAS ports into SATA

My board and many Supermicro boards have integrated SAS controllers from LSI/Broadcom. These can be flashed to support SATA drives using firmware [IT mode](https://www.broadcom.com/support/knowledgebase/1211161501344/flashing-firmware-and-bios-on-lsi-sas-hbas).

My original board did not want to recognize the SAS controller, so I replaced it with one on eBay for £85. Updating the BIOS seemed to make the board display the LSI splash screen.

I will be using the IPMI web interface we enabled earlier to do all of the upgrades.

Some instructions from someone in the community can be found [here](http://www.napp-it.org/doc/downloads/flash_lsi_sas.pdf)

You will first need the last nine digits of the SAS card. Reboot your server until you see the LSI SAS splash screen. Press CTRL-C to enter it. Press enter to select your SAS card and note down the SAS address. It will be two numbers separated by a colon. You will need the last nine digits, so that's all the digits marked with `X` `.......X:XXXXXXXX` (you can ignore the colon when trying it back in later).

You will also need a USB stick with the latest firmware driver from the Supermicro FTP server. Google your card model, but the driver file I needed was `PH20.00.07.00-IT.zip`. It should contain a file called `SMC2308T.NSH`. Extract these files locally and place the contents of the `UEFI` directory onto the USB stick.

Plug the USB into your server and reboot the BIOS `DEL`. Go to the end save menu, and at the bottom, pick the option to reboot into the UEFI shell.

Once in the UEFI shell, you should see your USB drive, usually called `fs0`. You can select this drive with the command `fs0:` and then type out the name of that file on the USB: `SMC2308T.NSH`. You will be prompted to enter those last nine digits of the SAS address you noted down earlier.

That's it; a reboot should show any SATA drives in SAS slots as attached inside your OS.